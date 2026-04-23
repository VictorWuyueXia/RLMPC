function [J, travelHistory, z] = updateLapCosts(X, J, travelHistory)
    %% Update the travelHistory, J, and z

    global dt numSamplePoints

    % Toal time used for this lap
    lapTime=dt*size(X,2);

    % The actual time stamps for each sample point
    timestamps=linspace(0, lapTime, size(X,2));

    % Interpolated time stamps for interpolated sample point
    pseudoTimestamps=linspace(0, lapTime, numSamplePoints);    

    % Interpolate to find the psudo-x
    pseudoX = interp1(timestamps, X', pseudoTimestamps, 'spline');
    pseudoX=pseudoX';
    
    % Update
    travelHistory=[travelHistory(:, numSamplePoints+1:end) pseudoX];
    J=[J(numSamplePoints+1:end) lapTime-pseudoTimestamps];
    z=travelHistory(:,end);
end