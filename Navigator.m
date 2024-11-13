classdef Navigator < Robot
    properties (Access=private)
        path_left_clear
        path_right_clear

        saw_blue
        saw_green
        saw_yellow
    end

    methods
        function obj = Navigator(ev3Brick)
            obj@Robot(ev3Brick);
            
            obj.saw_blue = false;
            obj.saw_green = false;
            obj.saw_yellow = false;
        end
    end

    methods(Access = private)
        function check_for_colors(obj)
            if obj.is_on_color("red")
                disp('Red\n')
                obj.brake();
                pause(3);
                obj.move_in_cm(20);
                obj.wait_for_motors();
            elseif ~obj.saw_blue && obj.is_on_color("blue")
                disp('Blue\n')
                obj.saw_blue = true;
                obj.brake();
                obj.ev3Brick.beep();
                pause(0.5);
                obj.ev3Brick.beep();
            elseif ~obj.saw_green && obj.is_on_color("green")
                disp('Green\n')
                obj.saw_green = true;
                obj.brake();
                obj.ev3Brick.beep();
                pause(0.5);
                obj.ev3Brick.beep();
                pause(0.5);
                obj.ev3Brick.beep();
            elseif ~obj.saw_yellow && obj.is_on_color("yellow")
                disp('Yellow\n')
                obj.saw_yellow = true;
                obj.brake();
                obj.ev3Brick.beep();
                pause(0.5);
                obj.ev3Brick.beep();
                pause(0.5);
                obj.ev3Brick.beep();
                pause(0.5);
                obj.ev3Brick.beep();
            end
        end
    end


    methods(Access = public)

        function color_test(obj)
            while true 
                pause(0.5);
                if obj.is_on_color("Red")
                    disp("Red");
                elseif obj.is_on_color("Yellow")
                    disp("Yellow")
                elseif obj.is_on_color("Green")
                    disp("Green")
                elseif obj.is_on_color("Blue")
                    disp("Blue")
                else
                    disp("No color")
                end
            end
            


        end



        function run(obj)
            step_number = 0;
            while true
                step_number = step_number + 1;

                if mod(step_number, 15) == 0
                    if obj.get_behind_distance() > 22
                        obj.move_in_cm(-20);
                    end
                end
                

                obj.path_left_clear = false;
                obj.path_right_clear = false;

                if obj.path_ahead_is_clear()
                    obj.move_to_next_wall();

                    tic;
                    while obj.are_motors_busy()

                        obj.check_for_colors();

                        %every 2 seconds, look left & right
                        if toc > 2
                            tic;
                          
                            if obj.get_left_distance() < obj.wall_distance_margin_left
                                %if the robot is too close to the left wall, turn a little right
                                obj.brake();
                                obj.rotate_motor(obj.left_motor_port, obj.motor_speed, 30);
                                obj.rotate_motor(obj.right_motor_port, obj.motor_speed, -30);
                                obj.wait_for_motors();
                            end


                            if obj.get_right_distance() < obj.wall_distance_margin_right
                                obj.brake();
                                obj.rotate_motor(obj.right_motor_port, obj.motor_speed, 45);
                                obj.rotate_motor(obj.left_motor_port, obj.motor_speed, -30);
                                obj.rotate_motor(obj.right_motor_port, obj.motor_speed, 30);
                                obj.wait_for_motors();
                            end

                        end

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