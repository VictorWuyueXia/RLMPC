function [A, B, C, xPlus] = linearModel(x, u, travelHistory, inputHistory)
    %%Linear regression to find vector Gamma to fit the P nearst neighbor states
    
    % Hyper parameters
    % P Nearest Neighbors, with kernel Q
    global P Q totalDistance numSamplePoints h curvature progress dt

    %% Decode state from x
    vx=x(1);    % longitudinal velocity
    vy=x(2);    % lateral velocity
    w=x(3);     % yaw rate
    ea=x(4);    % yaw error
    s=x(5);     % distance along the path
    ed=x(6);    % lateral error

    alpha=u(1);     % longitudinal acceleration
    delta=u(2);     % steering angle
    
    %% Indices of P-nearest neighbors
    I=KNeighbors(x, travelHistory, P, Q);
    I=I(I<numSamplePoints);
    Iplus=I+1;
    
    % Extract P-nearest neighbor states, and one step forward
    X=travelHistory(:, I);
    Xplus=travelHistory(:, Iplus);

    Vx=X(1, :)';
    Vy=X(2, :)';
    W=X(3, :)';

    VxPlus=Xplus(1, Iplus)';
    VyPlus=Xplus(2, Iplus)';
    WPlus=Xplus(3, Iplus)';

    % Extract P-nearest neighbor inputs
    Alpha=inputHistory(1, I)';
    Delta=inputHistory(2, I)';

    %% Linear regression
    y_vx=@(gamma)abs(VxPlus-gamma*[Vx, Vy, W, Alpha, 1]');
    y_vy=@(gamma)abs(VyPlus-gamma*[Vx, Vy, W, Delta, 1]');
    y_w=@(gamma)abs(WPlus-gamma*[Vx, Vy, W, Delta, 1]');

    % Epanechnikov kernel function
    EpaKernel=@(u) 3/4*(1-u^2)*(abs(u)<1) + 0;
    Q_norm=0;
    for iter=I
        xk=X(:, iter);
        Q_norm=Q_norm+EpaKernel(x'*Q'*Q*x);
    end
    K=EpaKernel(Q_norm/h)

    % Cost function
    Gamma_vx=@(gamma)K*y_vx(gamma);
    Gamma_vy=@(gamma)K*y_vy(gamma);
    Gamma_w=@(gamma)K*y_w(gamma);

    GammaFunction=@(gamma)Gamma_vx(gamma(1,:))+Gamma_vy(gamma(2,:))+Gamma_w(gamma(3,:));

    % Find optimal gamma
    options = optimoptions('fminunc','Display','off');
    OptimalGamma=fminunc(GammaFunction, [0, 0, 0, 0, 0]', options);
    
    optimalGamma_vx=OptimalGamma(1,:);
    optimalGamma_vy=OptimalGamma(2,:);
    optimalGamma_w=OptimalGamma(3,:);
   
    % Find local curvature
    K=interp(progress,curvature,s);

    % velocity Kinematics
    s_dot=@(x)  (x(1)*cos(x(4))-x(2)*sin(x(4))) / (1-K*x(6));
    ea_dot=@(x) x(3) - K * s_dot(x);
    ed_dot=@(x) x(1)*sin(x(4))+x(2)*cos(x(4));

    F_ea = @(x) ea+dt*ea_dot;
    F_s = @(x)  s+dt*s_dot;
    F_ed = @(x) ed+dt*ed_dot;

    % Find gradient
    epsilon=1e-3;
    G_ea=[(F_ea(x+epsilon*[1, 0, 0, 0, 0, 0]')-F_ea(x))/epsilon, ...
       (F_ea(x+epsilon*[0, 1, 0, 0, 0, 0]')-F_ea(x))/epsilon, ...
       (F_ea(x+epsilon*[0, 0, 1, 0, 0, 0]')-F_ea(x))/epsilon, ...
       (F_ea(x+epsilon*[0, 0, 0, 1, 0, 0]')-F_ea(x))/epsilon, ...
       (F_ea(x+epsilon*[0, 0, 0, 0, 1, 0]')-F_ea(x))/epsilon, ...
       (F_ea(x+epsilon*[0, 0, 0, 0, 0, 1]')-F_ea(x))/epsilon]';
    G_s=[(F_s(x+epsilon*[1, 0, 0, 0, 0, 0]')-F_s(x))/epsilon, ...
         (F_s(x+epsilon*[0, 1, 0, 0, 0, 0]')-F_s(x))/epsilon, ...
         (F_s(x+epsilon*[0, 0, 1, 0, 0, 0]')-F_s(x))/epsilon, ...
         (F_s(x+epsilon*[0, 0, 0, 1, 0, 0]')-F_s(x))/epsilon, ...
         (F_s(x+epsilon*[0, 0, 0, 0, 1, 0]')-F_s(x))/epsilon, ...
         (F_s(x+epsilon*[0, 0, 0, 0, 0, 1]')-F_s(x))/epsilon]';
    G_ed=[(F_ed(x+epsilon*[1, 0, 0, 0, 0, 0]')-F_ed(x))/epsilon, ...
          (F_ed(x+epsilon*[0, 1, 0, 0, 0, 0]')-F_ed(x))/epsilon, ...
          (F_ed(x+epsilon*[0, 0, 1, 0, 0, 0]')-F_ed(x))/epsilon, ...
          (F_ed(x+epsilon*[0, 0, 0, 1, 0, 0]')-F_ed(x))/epsilon, ...
          (F_ed(x+epsilon*[0, 0, 0, 0, 1, 0]')-F_ed(x))/epsilon, ...
          (F_ed(x+epsilon*[0, 0, 0, 0, 0, 1]')-F_ed(x))/epsilon]';
    
    % A B C 
    A=[optimalGamma_vx(1:3) 0 0 0
       optimalGamma_vy(1:3) 0 0 0
       optimalGamma_w(1:3) 0 0 0
       G_ea'
       G_s'
       G_ed'];

    B=[optimalGamma_vx(4) 0
       0 optimalGamma_vy(4)
       0 optimalGamma_w(4)
       zeros(3,2)];

    C=[optimalGamma_vx(5)
       optimalGamma_vy(5)
       optimalGamma_w(5)
       f_ed(x)-G_ed'*x
       f_s(x)-G_s'*x
       f_ea(x)-G_ea'*x];

    % Discrete new state
    xPlus=A*x+B*u+C;
end