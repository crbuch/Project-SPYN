classdef Robot < handle
    properties (Access = public)
        ev3Brick
        config
        pid_values
    end

    properties (Access= private)
        startTick
        angular_offset
    end

    methods
        function self = Robot(ev3Brick, config_file_path)
            self.ev3Brick = ev3Brick;
            self.config = jsondecode(fileread(config_file_path));

            self.ev3Brick.SetColorMode(self.config.Sensor_Ports.Color, 2);
            self.ev3Brick.GyroCalibrate(self.config.Sensor_Ports.Gyro);

            self.angular_offset = 0;
            self.startTick = tic;
            self.pid_values = struct();

            self.resetPID();
        end

        function elapsedTime = tick(self)
            elapsedTime = toc(self.startTick);
        end

        function resetPID(self)
            self.pid_values.wall_output = 0;
            self.pid_values.prev_wall_error = 0;
            self.pid_values.wall_integral = 0;
            self.pid_values.prev_angular_error = 0;
            self.pid_values.angular_integral = 0;

            self.pid_values.wall_kP=5;
            self.pid_values.wall_kI=0;
            self.pid_values.wall_kD=0;

            self.pid_values.angular_kP=1;
            self.pid_values.angular_kI=0;
            self.pid_values.angular_kD=0;
            self.pid_values.wall_previous_tick = self.tick();
            self.pid_values.angular_previous_tick = self.tick();
        end


        function rotate_motor(self, port, speed, angle)
            %rotates a motor with smaller ramp up and ramp down values
            if(angle<0)
                speed = -1*speed;
            end
            angle = abs(angle);
            %args are nos, speed, ramp_up, constant, ramp_down, braketype
            self.ev3Brick.motorStepSpeed(port, speed,  0, angle, 0, 1);
        end


        function angle = get_rotation(self)
            angle = self.ev3Brick.GyroAngle(self.config.Sensor_Ports.Gyro) - self.angular_offset;
            angle = mod(angle, 360);
            if angle < 0
                angle = angle + 360;
            end
        end


        function output = pid_control(self, desired_distance, actual_distance)
            dt = self.tick() - self.pid_values.wall_previous_tick;
            err = desired_distance - actual_distance;
            P = self.pid_values.wall_kP * err;
            self.pid_values.wall_integral = self.pid_values.wall_integral + (err * dt);
            I = self.pid_values.wall_kI * self.pid_values.wall_integral;
            derivative = (err - self.pid_values.prev_wall_error) / dt;
            D = self.pid_values.wall_kD * derivative;
            output = P + I + D;
            self.pid_values.prev_wall_error = err;
            self.pid_values.wall_previous_tick = self.tick();
        end

        function output = angular_pid_control(self, target_angle, current_angle)
            dt = self.tick() - self.pid_values.angular_previous_tick;
            err = target_angle - current_angle;
            if err > 180
                err = err - 360;
            elseif err < -180
                err = err + 360;
            end
            self.pid_values.angular_integral = self.pid_values.angular_integral + err * dt;
            derivative = (err - self.pid_values.prev_angular_error) / dt;
            output = self.pid_values.angular_kP * err + self.pid_values.angular_kI * self.pid_values.angular_integral + self.pid_values.angular_kD * derivative;
        end

        function move_forward_towards_angle(self, target_speed, target_angle)
            output = selfangular_pid_control(target_angle, self.get_rotation());
            self.ev3Brick.MoveMotor(char(self.config.Motor_Ports.Left), target_speed + output)
            self.ev3Brick.MoveMotor(char(self.config.Motor_Ports.Right), target_speed - output)
        end

        function snap_robot_to_angle(self)
            self.brake();
            currentAngle = self.get_rotation();
            targets = [0, 90, 180, 270, 360];
            [~, idx] = min(abs(targets - currentAngle));
            targetAngle = targets(idx);
            clockwiseDiff = mod(targetAngle - currentAngle, 360);
            counterclockwiseDiff = mod(currentAngle - targetAngle, 360);
            % Determine the shortest direction
            if clockwiseDiff <= counterclockwiseDiff
                self.rotate_motor(char(self.config.Motor_Ports.Left), 3, 360);
                self.rotate_motor(char(self.config.Motor_Ports.Right), 3, -360);
                while targetAngle-self.get_rotation() > 1 && self.are_motors_busy()
                    %rotate right by 1 step
                    pause(0.025);
                end
                self.brake();
            else
                self.rotate_motor(char(self.config.Motor_Ports.Left), 3, -360);
                self.rotate_motor(char(self.config.Motor_Ports.Right), 3, 360);
                while self.get_rotation()-targetAngle > 1 && self.are_motors_busy()
                    %rotate left by 1 step
                    pause(0.025);
                end
                self.brake();
            end
        end

        function wait_for_motors(self)
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Left));
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Right));
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Radar));
        end


        function result = are_motors_busy(self)
            result = self.ev3Brick.MotorBusy(char(self.config.Motor_Ports.Left)) == 1 || self.ev3Brick.MotorBusy(char(self.config.Motor_Ports.Right)) == 1 ;
        end

        function distance = get_left_distance(self, absolute)
            if absolute==true
                self.ev3Brick.MoveMotorAngleAbs(self.config.Motor_Ports.Radar, 100, -90-self.get_rotation());
            else
                self.ev3Brick.MoveMotorAngleAbs(self.config.Motor_Ports.Radar, 100, -90)
            end
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Radar));
            distance = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic);
        end

        function distance = get_ahead_distance(self, absolute)
            if absolute==true
                self.ev3Brick.MoveMotorAngleAbs(self.config.Motor_Ports.Radar, 100, 0-self.get_rotation());
            else
                self.ev3Brick.MoveMotorAngleAbs(self.config.Motor_Ports.Radar, 100, 0);
            end
            self.ev3Brick.WaitForMotor(self.config.Motor_Ports.Radar);
            distance = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic);
        end

        function brake(self)
            self.ev3Brick.StopAllMotors('Brake');
        end

        function move_in_cm(self, target_distance)
            wheel_circumference = pi * self.config.Nav_Config.Wheel_Diameter;
            rotations_needed = target_distance / wheel_circumference;
            target_angle = rotations_needed * 360;
            self.rotate_motor(char(self.config.Motor_Ports.Left), self.config.Nav_Config.Speed, target_angle);
            self.rotate_motor(char(self.config.Motor_Ports.Right), self.config.Nav_Config.Speed, target_angle);
            self.wait_for_motors();
        end


        function pivot_left_90(self)
            self.rotate_motor(self.config.Motor_Ports.Right, self.config.Nav_Config.Speed, 430);
            self.wait_for_motors();
            self.angular_offset = self.angular_offset - 90;
        end

        function pivot_right_90(self)
            self.rotate_motor(self.config.Motor_Ports.Left, self.config.Nav_Config.Speed, 430);
            self.wait_for_motors()
            self.angular_offset = self.angular_offset + 90;
        end

        function result = is_on_color(self, color)
            ncolor = lower(strtrim(color));

            color1 = self.ev3Brick.ColorCode(self.config.Sensor_Ports.Color);

            if ncolor == "red"
                result = color1 == 5;
            elseif ncolor == "green"
                result = color1 == 3;
            elseif ncolor == "blue"
                result = color1 == 2;
            elseif ncolor == "yellow"
                result = color1 == 4;
            else
                result = false;
            end
        end
    end
end