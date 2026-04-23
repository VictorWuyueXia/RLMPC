classdef LMPC_class
    properties
        N; % MPC time horizon
        F1tenth_model; % F1tenth kinematic bicycle model
        constraints; % Constraints for states, inputs, and lambda
        R; % Weighting matrix for control input u
        q_s; % Weighting matrix for slack variables s
        J_l; % Cost-to-go for the previous lap
        lambda; % Linear combination weights for previous lap cost-to-go
        x_min; % State lower bounds
        x_max; % State upper bounds
        u_min; % Input lower bounds
        u_max; % Input upper bounds
        b; % Track width
        track_constraints; % Function representing the track constraints
    end
    methods
        function obj = LMPC_class(N, F1tenth_model, R, q_s, J_l, x_min, x_max, u_min, u_max, b, track_constraints)
            obj.N = N;
            obj.F1tenth_model = F1tenth_model;
            obj.R = R;
            obj.q_s = q_s;
            obj.J_l = J_l;
            obj.x_min = x_min;
            obj.x_max = x_max;
            obj.u_min = u_min;
            obj.u_max = u_max;
            obj.b = b;
            obj.track_constraints = track_constraints;
        end
        
        function [u, lambda] = solve(obj, x0, t, j)
            % Define the decision variables
            x = sdpvar(repmat(obj.F1tenth_model.n, 1, obj.N+1), 1);
            u = sdpvar(repmat(obj.F1tenth_model.m, 1, obj.N), 1);
            lambda = sdpvar(obj.J_l.num_previous_laps, 1);
            s = sdpvar(obj.N, 1);

            % Define the constraints
            constraints = [x{1} == x0, lambda >= 0, sum(lambda) == 1];
            
            for k = 1:obj.N
                % System dynamics
                constraints = [constraints, x{k+1} == obj.F1tenth_model.f(x{k}, u{k})];
                
                % Track constraints
                constraints = [constraints, obj.track_constraints(x{k}) <= obj.b];
                
                % State and input constraints
                constraints = [constraints, obj.x_min <= x{k} <= obj.x_max, obj.u_min <= u{k} <= obj.u_max];
                
                % Slack variables
                constraints = [constraints, s{k} >= 0];
            end

            % Define the cost function
            cost = 0;
            for k = 1:obj.N
                cost = cost + u{k}' * obj.R * u{k} + s{k}' * obj.q_s * s{k};
            end
            cost = cost + s{t}' * obj.q_s * s{t} + obj.J_l.get_cost_to_go(x{obj.N+1}) * lambda;

            % Set up and solve the optimization problem
            options = sdpsettings('verbose', 0, 'solver', 'quadprog');
            problem = optimize(constraints, cost, options);

            % Extract the optimal control input and lambda
            u = value(u{1});
            lambda = value(lambda);
        end
    end
end

