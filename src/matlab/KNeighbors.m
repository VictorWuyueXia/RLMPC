function index = KNeighbors(x, travelHistory, K, kernel)
    % Input arguments
    % x: current state [vx, vy, w, ea, s, ed]'
    % travelHistory: 6x400 matrix of all the states traveled in the past two laps

    distances=[];
    for i = 1:size(travelHistory, 2)

        % Calculate the difference between x and each state in travelHistory
        y = travelHistory(:, i) - x;
        
        distances=[distances sum(y'*kernel'*kernel*y)];
    end

    % Find the indices of the K-nearest neighbors
    [~, sortedIndices] = sort(distances);
    index = sortedIndices(1:K);
end
