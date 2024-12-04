classdef Robot < handle
    properties (Access = public)
        ev3Brick
        config
    end

    methods
        function self = Robot(ev3Brick, config_file_path)
            self.ev3Brick = ev3Brick;
            self.config = jsondecode(fileread(config_file_path));
            self.ev3Brick.SetColorMode(self.config.Sensor_Ports.Color, 2);
            self.ev3Brick.GyroCalibrate(self.config.Sensor_Ports.Gyro);
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
            angle = self.ev3Brick.GyroAngle(self.config.Sensor_Ports.Gyro);
            angle = mod(angle, 360);
            if angle < 0
                angle = angle + 360;
            end
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

        function lookRight(self)
            self.ev3Brick.MoveMotorAngleAbs(char(self.config.Motor_Ports.Radar), 100, 110 , 'Brake');
            self.wait_for_motors();
        end

        function lookLeft(self)
            self.ev3Brick.MoveMotorAngleAbs(char(self.config.Motor_Ports.Radar), 100, -75 , 'Brake');
            self.wait_for_motors();
        end

        function lookAhead(self)
            self.ev3Brick.MoveMotorAngleAbs(char(self.config.Motor_Ports.Radar), 100, 17 , 'Brake');
            self.wait_for_motors();
        end

        function lookBehind(self)
            self.ev3Brick.MoveMotorAngleAbs(char(self.config.Motor_Ports.Radar), 100, -165)
            self.wait_for_motors();
        end


        function clear = path_to_right_is_clear(self)
            self.lookRight();
            clear = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic) > self.config.Padding_Distance.Right;
        end

        function clear = path_ahead_is_clear(self)
            self.lookAhead();
            clear = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic) > self.config.Padding_Distance.Front;
        end

        function clear = path_to_left_is_clear(self)
            self.lookLeft()
            clear = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic) > self.config.Padding_Distance.Left;
        end


        function wait_for_motors(self)
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Left));
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Right));
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Radar));
        end


        function result = are_motors_busy(self)
            result = self.ev3Brick.MotorBusy(char(self.config.Motor_Ports.Left)) == 1 || self.ev3Brick.MotorBusy(char(self.config.Motor_Ports.Right)) == 1 ;
        end


        function move_in_cm(self, target_distance)
            wheel_circumference = pi * self.config.Nav_Config.Wheel_Diameter;
            rotations_needed = target_distance / wheel_circumference;
            target_angle = rotations_needed * 360;
            self.rotate_motor(char(self.config.Motor_Ports.Left), self.config.Nav_Config.Speed, target_angle);
            self.rotate_motor(char(self.config.Motor_Ports.Right), self.config.Nav_Config.Speed, target_angle);
        end


        function move_to_next_wall(self)
            self.lookAhead();
            self.move_in_cm(self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic) - (self.config.Padding_Distance.Front-2));
        end

        function result = get_left_distance(self)
            self.lookLeft();
            result = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic) - self.config.Padding_Distance.Left;
        end

        function result = get_right_distance(self)
            self.lookRight();
            result = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic) - self.config.Padding_Distance.Right;
        end

        function result = get_behind_distance(self)
            self.lookBehind();
            result = self.ev3Brick.UltrasonicDist(self.config.Sensor_Ports.Ultrasonic);
        end

        function wait_for_distance_reading(self)
            self.ev3Brick.WaitForMotor(char(self.config.Motor_Ports.Radar));
        end

        function brake(self)
            self.ev3Brick.StopAllMotors('Brake');
        end


        function rotate_left(self)
            self.rotate_motor(char(self.config.Motor_Ports.Left), self.config.Nav_Config.Speed/2, -self.config.Nav_Config.Steps_Per_Turn/2);
            self.rotate_motor(char(self.config.Motor_Ports.Right), self.config.Nav_Config.Speed/2, self.config.Nav_Config.Steps_Per_Turn/2);
            self.wait_for_motors();
            self.snap_robot_to_angle();
        end


        function rotate_right(self)
            self.rotate_motor(char(self.config.Motor_Ports.Left), self.config.Nav_Config.Speed/2, self.config.Nav_Config.Steps_Per_Turn/2);
            self.rotate_motor(char(self.config.Motor_Ports.Right), self.config.Nav_Config.Speed/2, -self.config.Nav_Config.Steps_Per_Turn/2);
            self.wait_for_motors();
            self.snap_robot_to_angle();
        end

        function turn_around(self)
            self.rotate_motor(char(self.config.Motor_Ports.Left), self.config.Nav_Config.Speed, self.config.Nav_Config.Steps_Per_Turn);
            self.rotate_motor(char(self.config.Motor_Ports.Right), self.config.Nav_Config.Speed, -self.config.Nav_Config.Steps_Per_Turn);
            self.wait_for_motors();
            self.snap_robot_to_angle();
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