classdef Safe_points
    properties
        j
        J
        x
        y
        s
        n
    end
    
    methods
        function obj = Safe_points(j, J, x, y, track)
            obj.j = j;
            obj.J = J;
            obj.x = x;
            obj.y = y;
            [obj.s, obj.n] = track.xy_to_sn(x, y);
        end
    end
end
