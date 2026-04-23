function state_dot = dummyCar(t, state, input)
    global progress curvature
    
    % Extract state variables
    vx = state(1);
    vy = state(2);
    w = state(3);
    ea = state(4);
    s = state(5);
    ed = state(6);

    % Extract input variables
    d = input(1);
    a = input(2);

    % Interpolate the curvature at the current progress s
    localCurvature = interp1(progress, curvature, s, 'linear', 'extrap');

    % Compute the dynamic equations
    vx_dot = a;
    vy_dot = (vx * sin(ea) + vy * cos(ea)) * w;
    w_dot = d;
    ea_dot = w - ((vx * cos(ea) - vy * sin(ea)) / (1 - localCurvature * ed)) * localCurvature;
    s_dot = (vx * cos(ea) - vy * sin(ea))/(1-localCurvature);
    ed_dot = vy * cos(ea) + vx * sin(ea);

    % Combine the derivatives into a single vector
    state_dot = [vx_dot; vy_dot; w_dot; ea_dot; s_dot; ed_dot];
end
