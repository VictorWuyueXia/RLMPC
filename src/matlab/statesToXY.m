function [x, y] = statesToXY(states, centerline, centerlineNormalDirection)
    % Number of states
    numStates = size(states, 1);

    % Preallocate x and y arrays
    x = zeros(numStates, 1);
    y = zeros(numStates, 1);

    % Precalculate progress after each centerline point
    progress=[0];
    for i = 1:size(centerline,2)-1
        progress=[progress progress(end)+norm(centerline(:,i+1)-centerline(:,i))];
    end

    % Loop through each state
    for i = 1:numStates
        % Extract the s and ed values from the state
        s = states(i, 5);
        ed = states(i, 6);

        % Find the closest centerline point
        xCenter=interp1(progress, centerline(1,:), s);
        yCenter=interp1(progress, centerline(2,:), s);
        dxCenter=interp1(progress, centerlineNormalDirection(1,:), s);
        dyCenter=interp1(progress, centerlineNormalDirection(2,:), s);

        % Calculate the x and y position
        x(i) = xCenter + ed * dxCenter;
        y(i) = yCenter + ed * dyCenter;
    end
end
