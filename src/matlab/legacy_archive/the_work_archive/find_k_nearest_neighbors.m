function nearest_neighbors = find_k_nearest_neighbors(point, all_laps, K, l)
    distances = [];
    candidates = [];

    % Iterate through the specified laps (from the current lap to l laps ago)
    for j = length(all_laps):-1:max(1, length(all_laps) - l)
        lap_points = all_laps{j};

        % Iterate through the points in the lap
        for i = 1:length(lap_points)
            p = lap_points(i);

            % Calculate the Euclidean distance between the given point and the current point in the lap
            distance = norm([p.x - point(1), p.y - point(2)]);

            % Store the distance and the corresponding point in the candidates list
            distances = [distances; distance];
            candidates = [candidates; p];
        end
    end

    % Sort the candidates by their distances to the given point
    [sorted_distances, sorted_indices] = sort(distances);

    % Select the K-nearest neighbors
    nearest_neighbors = candidates(sorted_indices(1:K));
end
