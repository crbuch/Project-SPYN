classdef Navigator < Robot

    properties (Access=private)
        path_left_clear
        path_right_clear
    end

    methods
        function obj = Navigator(ev3Brick)
            obj@Robot(ev3Brick);            
        end
    end


    methods(Access = public)
        function angle = correct_angle(obj, gyroAngle)
            angle = mod(gyroAngle, 360);
            if angle < 0
                angle = angle + 360;
            end
        end



        function run(obj)
            while true

                
                % while mod(obj.get_gyro_angle(), 90) < 2 || mod(obj.get_gyro_angle(), 90) > 2
                %     if mod(obj.get_gyro_angle(), 90) < 0
                %         obj.rotate_motor(obj.left_motor_port, obj.motor_speed, 1)
                %         obj.rotate_motor(obj.right_motor_port, obj.motor_speed, -1)
                %     elseif mod(obj.get_gyro_angle(), 90) > 0
                %         obj.rotate_motor(obj.left_motor_port, obj.motor_speed, -1)
                %         obj.rotate_motor(obj.right_motor_port, obj.motor_speed, 1)
                %     else
                %         break
                %     end
                % end


                obj.path_left_clear = false;
                obj.path_right_clear = false;

                if obj.path_ahead_is_clear()
                    obj.move_to_next_wall();
                    continue;
                end

                if obj.path_to_right_is_clear()
                    obj.path_right_clear = true;
                end

                if obj.path_to_left_is_clear()
                    obj.path_left_clear = true;
                end

                if obj.path_left_clear && obj.path_right_clear
                    %find the longer path and move there
                    left_dist = obj.get_left_distance();
                    right_dist = obj.get_right_distance();
                    if left_dist < right_dist
                        obj.rotate_right();
                    else
                        obj.rotate_left();
                    end
                    continue;
                end

                if obj.path_left_clear && ~obj.path_right_clear
                    obj.rotate_left();
                    continue;
                end

                if obj.path_right_clear && ~obj.path_left_clear
                    obj.rotate_right();
                    continue;
                end

                if ~obj.path_right_clear && ~obj.path_left_clear
                    obj.turn_around();
                end
            end
        end
    end
end