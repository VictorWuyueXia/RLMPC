function [u_opt, lambda_opt] = Optimize(track, x0, all_laps)
    % Model parameters
    N = 20;  % Prediction horizon
    R = diag([1, 1]);  % Input weights
    K = 5;  % K-nearest neighbors
    l = 3;  % Within l laps
    q_s = 1;  % Track progress weight
    q_n = 1;  % Track normal position weight

    % State and input constraints
    x_min = [-Inf; -Inf; -pi; 0; -Inf; -Inf];
    x_max = [Inf; Inf; pi; Inf; Inf; Inf];
    u_min = [-5; -0.5];
    u_max = [5; 0.5];

    % Define optimization variables
    x = sdpvar(6, N + 1);
    u = sdpvar(2, N);
    lambda = sdpvar(K, N);
    s = sdpvar(1, N);
    n = sdpvar(1, N);

    % Initialize constraints and cost
    constraints = [];
    cost = 0;

    % Set initial condition
    constraints = [constraints, x(:, 1) == x0];

    % Loop through the prediction horizon
    for k = 1:N
        % Apply constraints and cost for each time step
        constraints = [constraints, x_min <= x(:, k), x(:, k) <= x_max];
        constraints = [constraints, u_min <= u(:, k), u(:, k) <= u_max];
        constraints = [constraints, x(:, k + 1) == F1tenth(x(:, k), u(:, k))];
        constraints = [constraints, 0 <= lambda(:, k), sum(lambda(:, k)) == 1];
        nearest_neighbors = find_k_nearest_neighbors(x(1:2, k), all_laps, K, l);
        linear_combination = 0;
        for i = 1:K
            linear_combination = linear_combination + nearest_neighbors(i).J * lambda(i, k);
        end
        constraints = [constraints, linear_combination == x(1:2, k + 1)];
        constraints = [constraints, s(k) >= 0, n(k) >= 0];

        [s(k), n(k)] = track.xy_to_sn(x(1, k), x(2, k));

        linear_combination_cost = 0;
        for i = 1:K
            linear_combination_cost = linear_combination_cost + nearest_neighbors(i).J * lambda(i, k);
        end
        cost = cost + u(:, k)' * R * u(:, k) + s(k) * q_s + n(k) * q_n + linear_combination_cost;

    end

    % Solve the optimization problem
    options = sdpsettings('solver', 'gurobi', 'verbose', 0);
    sol = optimize(constraints, cost, options);

    % Check if the problem is solved successfully
    if sol.problem == 0
        u_opt = value(u);
        lambda_opt = value(lambda);
    else
        error('The optimization problem could not be solved');
    end
end
