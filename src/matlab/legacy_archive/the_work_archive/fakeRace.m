function fakeX = fakeRace(lapTime, dt, centerline, totalDistance)
    %% Fake data for a car to track the centerline
    
    speed=totalDistance/lapTime;
    lapPoints=lapTime/dt;
    
    fakeX=NaN([lapPoints,6]);

    t = linspace(0, 1, size(centerline, 1));
    tt = linspace(0, 1, lapPoints);
    centerlineInterp = interp1(t, centerline, tt, 'spline');
 
    for i = 1:lapPoints
        % Assuming the car moves at a constant speed along the boundary and has zero lateral velocity and error angle
        vx = speed;  % Constant longitudinal velocity
        vy = 0;  % Lateral velocity
        ea = 0;  % Error angle
        ed = 0;  % Normal distance from the centerline 
        
        % Yaw rate calculation
        if i < lapPoints
            direction_diff = centerlineInterp(i+1, :) - centerlineInterp(i, :);
            w = atan2(direction_diff(2), direction_diff(1)) / dt;
        else
            w = 0;
        end

        s = (i - 1) * dt * speed;  % Progress along the track

        fakeX(i, :) = [vx, vy, w, ea, s, ed];
    end

    fakeX=fakeX';

end
