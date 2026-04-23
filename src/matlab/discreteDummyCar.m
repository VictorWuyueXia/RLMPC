function newState = discreteDummyCar(x, u)
    % Time step;
    dt=0.1;
    
    % Has no meaning, just to comply with the format
    t=0;

    state_dot = dummyCar(t, x, u);

    newState=x+state_dot*dt;    % Euler's method
end
