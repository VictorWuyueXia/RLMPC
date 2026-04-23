function u = solveLMPC(x, z, travelHistory, allJ, discreteCarModel)
    % Input arguments
    % x: current state [vx, vy, w, ea, s, ed]'
    % travelHistory: 6x400 matrix of all the states traveled in the past two laps
    % allJ: 1x400 array of the J values for each state in travelHistory

    % Load track map info
    global totalDistance progress trackWidth curvature K N numSamplePoints
    
    %linearize the model
    [A, B ,C]=linearModel(discreteCarModel)

end