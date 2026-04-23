function [state, z, last2laps, allJ, inputHistory] = initializeRace()

    % Load global info
    global trackWidth centerline leftBoundary rightBoundary dt numSamplePoints

    % Spline interpolate track data
    t = linspace(0, 1, size(centerline, 1));
    tt = linspace(0, 1, numSamplePoints);
    centerlineInterp = interp1(t, centerline, tt, 'spline');
    leftBoundaryInterp = interp1(t, leftBoundary, tt, 'spline');
    rightBoundaryInterp = interp1(t, rightBoundary, tt, 'spline');

    % Calculate the total distance traveled along the center line and boundaries
    centerTotalDistance = sum(sqrt(sum(diff(centerlineInterp).^2, 2)));
    leftTotalDistance = sum(sqrt(sum(diff(leftBoundaryInterp).^2, 2)));
    rightTotalDistance = sum(sqrt(sum(diff(rightBoundaryInterp).^2, 2)));
    centerSpeed = centerTotalDistance / (numSamplePoints * dt);
    leftSpeed = leftTotalDistance / (numSamplePoints * dt);
    rightSpeed = rightTotalDistance / (numSamplePoints * dt);

    % Reserve space for dummy laps
    last2laps = zeros(numSamplePoints * 2, 6);
    lapSign = [-1, 1];
    speeds = {leftSpeed, rightSpeed};

    % Reserve space to calculate the remaining distance for each point in the dummy laps
    remainingDistances = zeros(numSamplePoints * 2, 1);

    % Make dummy laps with psudo-states
    for idx = 1:2
        lap_num = lapSign(idx);
        speed = speeds{idx};

        for i = 1:numSamplePoints
            % Assuming the car moves at a constant speed along the boundary and has zero lateral velocity and error angle
            vx = speed;  % Constant longitudinal velocity
            vy = 0;  % Lateral velocity
            ea = 0;  % Error angle
            
            % Yaw rate calculation
            if i < numSamplePoints
                direction_diff = centerlineInterp(i+1, :) - centerlineInterp(i, :);
                w = atan2(direction_diff(2), direction_diff(1)) / dt;
            else
                w = 0;
            end

            s = (i - 1) * dt * centerSpeed;  % Progress along the track
            ed = lap_num * trackWidth;  % Normal distance from the centerline 
            last2laps((idx - 1) * numSamplePoints + i, :) = [vx, vy, w, ea, s, ed];

            % remaining distance for each point 
            remainingDistance = centerTotalDistance - last2laps((idx - 1) * numSamplePoints + i, 5);
            remainingDistances((idx - 1) * numSamplePoints + i) = remainingDistance;
        end
    end
    last2laps=last2laps';

    % Calculate the time-to-go (J) for each dummy lap point
    allJ = remainingDistances ./ centerSpeed;
    allJ=allJ';

    % Initialize the state
    state = [0, 0, 0, 0, 0, 0]';  % [vx, vy, w, ea, s, ed]'
    
    % Initialize the candidate terminal state
    z = last2laps(:,end);

    % Dummy input history
    inputHistory = zeros(2, numSamplePoints * 2);
    xMinus=state;
    for i = 1:numSamplePoints * 2
        inputHistory(1, i) = last2laps(1, i) - xMinus(1);
        inputHistory(2, i) = (last2laps(3, i) - xMinus(3))/dt;
        xMinus = last2laps(:, i);
    end
end
