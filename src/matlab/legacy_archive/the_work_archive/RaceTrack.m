classdef RaceTrack
    properties
        centerline
        left_boundary
        right_boundary
        centerline_directions
        centerline_normal_directions
    end
    
    methods
        function obj = RaceTrack(centerline, left_boundary, right_boundary, ...
                                 centerline_directions, centerline_normal_directions)
            obj.centerline = centerline;
            obj.left_boundary = left_boundary;
            obj.right_boundary = right_boundary;
            obj.centerline_directions = centerline_directions;
            obj.centerline_normal_directions = centerline_normal_directions;
        end
        
        function [s, n] = xy_to_sn(obj, x, y)
            xy = [x, y];
            num_segments = size(obj.centerline, 1) - 1;
            closest_segment_index = 1;
            min_distance = Inf;
            total_length = 0;
            length_to_closest_segment = 0;
        
            for i = 1:num_segments
                current_segment = [obj.centerline(i, :); obj.centerline(i + 1, :)];
                [projection, distance] = obj.project_point_to_line_segment(xy, current_segment);
                total_length = total_length + norm(current_segment(2, :) - current_segment(1, :));
        
                if distance < min_distance
                    closest_segment_index = i;
                    min_distance = distance;
                    length_to_closest_segment = total_length - norm(current_segment(2, :) - current_segment(1, :)) ...
                                                 + norm(projection - current_segment(1, :));
                end
            end
        
            s = length_to_closest_segment / total_length;
            n_vector = xy - projection;
            n = sign(dot(n_vector, obj.centerline_normal_directions(closest_segment_index, :))) * norm(n_vector);
        end

        function [projection, distance] = project_point_to_line_segment(obj, point, line_segment)
            v = line_segment(2, :) - line_segment(1, :);
            w = point - line_segment(1, :);

            c1 = dot(w, v);
            if c1 <= 0
                projection = line_segment(1, :);
                distance = norm(point - projection);
                return;
            end

            c2 = dot(v, v);
            if c2 <= c1
                projection = line_segment(2, :);
                distance = norm(point - projection);
                return;
            end

            b = c1 / c2;
            projection = line_segment(1, :) + b * v;
            distance = norm(point - projection);
        end
    end
end
