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

            self.joystick_controller = Joystick(self);
        end
    end

    methods(Access = public)

        function actual_dist = left_Tracked_Forward_Update(self, base_speed, desired_dist, distance_cutoff_threshold) % returns the current distance
            actual_dist = self.get_left_distance(true);
            if actual_dist <= distance_cutoff_threshold
                wall_output = self.pid_control(desired_dist, actual_dist);
                self.move_forward_towards_angle(base_speed, wall_output)
            end
        end

        function find_Wall_Behind(self)
            self.rotate_motor(self.config.Motor_Ports.Left, 10, -360);
            self.rotate_motor(self.config.Motor_Ports.Right, 10, -360);
            while self.get_left_distance(false) > self.config.Nav_Config.Distance_Cutoff_Threshold && self.are_motors_busy()
                pause(1/40);
            end
            self.brake();
        end



        function run(self)
            step_number = 0;
            pause_time = self.config.Nav_Config.Pause_Time_Between_Steps;
            while true
                while ~self.joystick_controller.self_driving_enabled
                    pause(1/40);
                end

                step_number = step_number + 1;

                if mod(step_number, 6)==0
                    forward_dist = self.get_ahead_distance(true);
                    if forward_dist < self.config.Nav_Config.Distance_Cutoff_Threshold
                        self.brake()
                        pause(pause_time);
                        self.snap_robot_to_angle()
                        pause(pause_time);

                        self.move_in_cm((self.config.Nav_Config.Distance_From_Wall*2)-forward_dist);

                        pause(pause_time);
                        self.pivot_right_90()
                        pause(pause_time);
                        self.resetPID();
                    end
                end

                wall_dist = self.left_Tracked_Forward_Update(self.config.Nav_Config.Speed, self.config.Nav_Config.Distance_From_Wall, self.config.Nav_Config.Distance_Cutoff_Threshold);


                if wall_dist >= self.config.Nav_Config.Distance_Cutoff_Threshold
                    self.brake()
                    pause(pause_time);
                    self.snap_robot_to_angle()
                    pause(pause_time);
                    self.find_Wall_Behind()
                    pause(pause_time);
                    self.move_in_cm(self.config.Nav_Config.Distance_From_Wall)
                    pause(pause_time);
                    self.pivot_left_90()
                    pause(pause_time);
                    self.move_in_cm(self.config.Nav_Config.Distance_From_Wall*2)
                    pause(pause_time);
                    if self.get_left_distance(false) >= self.config.Nav_Config.Distance_Cutoff_Threshold
                        pause(pause_time);
                        self.pivot_left_90()
                        pause(pause_time);
                        self.move_in_cm(self.config.Nav_Config.Distance_From_Wall*2)
                        pause(pause_time);
                    end
                    self.resetPID();
                end

            end
        end


        function color_test(self)
            while true
                pause(pause_time);
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