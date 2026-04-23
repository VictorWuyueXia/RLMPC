function [lin_combinations] = linear_combinations(data_points)
    % Input: data_points is a 13x3 matrix where each row represents a data point (x, y, q)
    % Output: lin_combinations is a cell array where each row contains a lambda vector and the corresponding linear combination values

    % Initialize the lin_combinations cell array
    lin_combinations = {};

    % Call the recursive helper function
    lin_combinations = generate_combinations(data_points, zeros(7, 1), 1, lin_combinations);
end

