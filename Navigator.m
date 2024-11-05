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
        function run(obj)
            while true
                obj.path_left_clear = false;
                obj.path_right_clear = false;

                if obj.path_ahead_is_clear()
                    obj.move_to_next_wall();

                    iteration = 1;
                    check_every = 1; %how often (in seconds) the robot should check left & right
                    while obj.are_motors_busy()
                        pause(0.125);
                        %every 2 seconds, look left & right
                        if mod(iteration, check_every/0.125) == 0
                            if obj.get_left_distance() < obj.wall_distance_margin_left
                                %if the robot is too close to the left wall, turn a little right
                                obj.brake();
                                obj.rotate_motor(obj.left_motor_port, obj.motor_speed, 45);
                                obj.wait_for_motors();
                                break;
                            end
        
                            if obj.get_right_distance() < obj.wall_distance_margin_right
                                obj.brake();
                                obj.rotate_motor(obj.right_motor_port, obj.motor_speed, 45);
                                obj.wait_for_motors();
                                break;
                            end
                        end

                        iteration = iteration + 1;
                    end

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