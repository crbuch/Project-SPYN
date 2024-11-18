classdef Navigator < handle & Robot
    properties (Access=private)
        path_left_clear
        path_right_clear

        saw_blue
        saw_green
        saw_yellow

        joystick_controller
    end

    methods
        function obj = Navigator(ev3Brick)
            obj@Robot(ev3Brick);
            
            %you must pass self (navigator instance) into the joystick
            %controller
            obj.joystick_controller = Joystick(obj);
            
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
            tic;
            while ~obj.joystick_controller.is_enabled
                disp(obj.joystick_controller.is_enabled)
                if obj.joystick_controller.is_enabled
                    disp("Breaking");
                    break;
                end
                %every 15 seconds, reverse 20 cm in case robot is stuck in wall
                if toc > 15
                    tic;
                    if obj.get_behind_distance() > 22
                        obj.move_in_cm(-20);
                        obj.snap_robot_to_angle();
                    end
                end
                

                obj.path_left_clear = false;
                obj.path_right_clear = false;

                if obj.path_ahead_is_clear()
                    obj.move_to_next_wall();

                    while obj.are_motors_busy()
                        obj.check_for_colors();
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