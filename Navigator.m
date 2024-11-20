classdef Navigator < handle & Robot
    properties (Access=private)
        saw_blue
        saw_green
        saw_yellow

        joystick_controller
    end


    methods
        function self = Navigator(ev3Brick, config_file_path)
            self@Robot(ev3Brick, config_file_path);
            
            %pass self (navigator instance) into the joystick
            %controller
            self.joystick_controller = Joystick(self);
            
            self.saw_blue = false;
            self.saw_green = false;
            self.saw_yellow = false;
        end
    end

    methods(Access = public)
        function run(self)
            while true
                pause(0.025);

                while self.joystick_controller.is_enabled
                    %yield script until joystick controller is disabled
                    pause(0.025);
                end


                path_left_clear = false;
                path_right_clear = false;

                if self.path_ahead_is_clear()
                    self.move_to_next_wall();

                    while self.are_motors_busy()
                        pause(0.025);
                        self.check_for_colors();
                    end

                    continue;
                end

                if self.path_to_right_is_clear()
                    path_right_clear = true;
                end

                if self.path_to_left_is_clear()
                    path_left_clear = true;
                end

                if path_left_clear && path_right_clear
                    %find the longer path and move there
                    left_dist = self.get_left_distance();
                    right_dist = self.get_right_distance();
                    if left_dist < right_dist
                        self.rotate_right();
                    else
                        self.rotate_left();
                    end
                    continue;
                end

                if path_left_clear && ~path_right_clear
                    self.rotate_left();
                    continue;
                end

                if path_right_clear && ~path_left_clear
                    self.rotate_right();
                    continue;
                end

                if ~path_right_clear && ~path_left_clear
                    self.turn_around();
                end
            end
        end

        function check_for_colors(self)
            if self.is_on_color("red")
                disp('Red\n')
                self.brake();
                pause(3);
                self.move_in_cm(20);
                self.wait_for_motors();
            elseif ~self.saw_blue && self.is_on_color("blue")
                disp('Blue\n')
                self.saw_blue = true;
                self.brake();
                self.ev3Brick.beep();
                pause(0.5);
                self.ev3Brick.beep();
            elseif ~self.saw_green && self.is_on_color("green")
                disp('Green\n')
                self.saw_green = true;
                self.brake();
                self.ev3Brick.beep();
                pause(0.5);
                self.ev3Brick.beep();
                pause(0.5);
                self.ev3Brick.beep();
            elseif ~self.saw_yellow && self.is_on_color("yellow")
                disp('Yellow\n')
                self.saw_yellow = true;
                self.brake();
                self.ev3Brick.beep();
                pause(0.5);
                self.ev3Brick.beep();
                pause(0.5);
                self.ev3Brick.beep();
                pause(0.5);
                self.ev3Brick.beep();
            end
        end

        function color_test(self)
            while true
                pause(0.5);
                if self.is_on_color("Red")
                    disp("Red");
                elseif self.is_on_color("Yellow")
                    disp("Yellow")
                elseif self.is_on_color("Green")
                    disp("Green")
                elseif self.is_on_color("Blue")
                    disp("Blue")
                else
                    disp("No color")
                end
            end
        end
    end
end