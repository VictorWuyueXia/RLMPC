function [lin_combinations] = generate_combinations(data_points, lambda, index, lin_combinations)
    % Base case: when index is 14, calculate and store the linear combination values
    if index == 8
        lin_comb_Q = dot(lambda, data_points(:, 3));
        lin_comb_X = dot(lambda, data_points(:, 1));
        lin_comb_Y = dot(lambda, data_points(:, 2));

        lin_combinations{end + 1, 1} = lambda;
        lin_combinations{end, 2} = [lin_comb_X, lin_comb_Y, lin_comb_Q];
        return;
    end

    if index == 7
        lambda(index) = 1-sum(lambda(1:index-1));
        lin_combinations = generate_combinations(data_points, lambda, index + 1, lin_combinations);
        return;
    end

    % Recursive case: generate combinations of lambda values
    resolution=10;
    % for i = 0:round((1 - sum(lambda(1:index-1))) * resolution)
        % lambda(index) = i / resolution;
    for i = linspace(0,1-sum(lambda(1:index-1)),resolution)
        lambda(index) = i;
        lin_combinations = generate_combinations(data_points, lambda, index + 1, lin_combinations);
    end
end
