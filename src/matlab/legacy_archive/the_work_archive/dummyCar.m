function state_dot = dummyCar(state, input)
    % state = [x, y, psi, v_x, psi_dot, beta]
    % input = [alpha, delta]

    % Unpack the state and input variables
    x = state(1);
    y = state(2);
    psi = state(3);
    v_x = state(4);
    psi_dot = state(5);
    beta=states(6);

    alpha = input(1);
    delta = input(2);

    % Constants
    L = 0.15; % Wheelbase of the car

    % Compute the derivative of the states
    x_dot = v_x * cos(psi);
    y_dot = v_x * sin(psi);
    psi_dot = v_x * tan(delta) / L;
    v_x_dot = alpha;
    beta_dot=0;
    
    % Pack the derivative of the states into a single vector
    state_dot = [x_dot, y_dot, psi_dot, v_x_dot, beta_dot]';
end
