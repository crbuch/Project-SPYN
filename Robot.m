classdef Robot
    properties (Access = protected)
        ev3Brick
        left_motor_port
        right_motor_port
        ultrasonic_sensor_port
        ultrasonic_pan_motor_port
        gyro_sensor_port
        color_sensor_port
        motor_speed
        turning_degrees
        wheel_diameter
        wall_distance_margin_straight
        wall_distance_margin_right
        wall_distance_margin_left
    end

    methods
        function obj = Robot(ev3Brick)
            obj.ev3Brick = ev3Brick;
            obj.left_motor_port = 'D';
            obj.right_motor_port = 'C';
            obj.ultrasonic_sensor_port = 4;
            obj.gyro_sensor_port = 1;
            obj.ultrasonic_pan_motor_port = 'B';
            obj.color_sensor_port = 3;
            obj.motor_speed = 35;
            obj.turning_degrees = 395;
            obj.wheel_diameter = 5.6;
            obj.wall_distance_margin_straight = 21 + 4;
            obj.wall_distance_margin_right = 5 + 4;
            obj.wall_distance_margin_left = 16 + 4;

            obj.ev3Brick.SetColorMode(obj.color_sensor_port, 2);
            obj.ev3Brick.GyroCalibrate(1);
        end
    end

    methods(Access = protected)
        function rotate_motor(obj, port, speed, angle)
            %rotates a motor with smaller ramp up and ramp down values
            if(angle<0)
                speed = -1*speed;
            end
            angle = abs(angle);
            %args are nos, speed, ramp_up, constant, ramp_down, braketype
            obj.ev3Brick.motorStepSpeed(port, speed,  0, angle, 0, 1);
        end


        function angle = get_rotation(obj)
            angle = obj.ev3Brick.GyroAngle(obj.gyro_sensor_port);
            angle = mod(angle, 360);
            if angle < 0
                angle = angle + 360;
            end
        end

        function snap_robot_to_angle(obj)
            obj.brake();
            disp('Snapping robot to angle\n');
            currentAngle = obj.get_rotation();
            targets = [0, 90, 180, 270, 360];
            [~, idx] = min(abs(targets - currentAngle));
            targetAngle = targets(idx);
            clockwiseDiff = mod(targetAngle - currentAngle, 360);
            counterclockwiseDiff = mod(currentAngle - targetAngle, 360);
            % Determine the shortest direction
            if clockwiseDiff <= counterclockwiseDiff
                obj.rotate_motor(obj.left_motor_port, 4, 360);
                obj.rotate_motor(obj.right_motor_port, 4, -360);
                while targetAngle-obj.get_rotation() > 1 && obj.are_motors_busy()
                    %rotate right by 1 step
                    pause(0.0001);
                end
                obj.brake();
            else
                obj.rotate_motor(obj.left_motor_port, 4, -360);
                obj.rotate_motor(obj.right_motor_port, 4, 360);
                while obj.get_rotation()-targetAngle > 1 && obj.are_motors_busy()
                    %rotate left by 1 step
                    pause(0.0001);
                end
                obj.brake();
            end
            disp('Finished snapping robot to angle\n');
        end

        function lookRight(obj)
            obj.ev3Brick.MoveMotorAngleAbs(obj.ultrasonic_pan_motor_port, 50, 115 , 'Brake');
            obj.wait_for_motors();
        end

        function lookLeft(obj)
            obj.ev3Brick.MoveMotorAngleAbs(obj.ultrasonic_pan_motor_port, 50, -75 , 'Brake');
            obj.wait_for_motors();
        end

        function lookAhead(obj)
            obj.ev3Brick.MoveMotorAngleAbs(obj.ultrasonic_pan_motor_port, 50, 20 , 'Brake');
            obj.wait_for_motors();
        end


        function clear = path_to_right_is_clear(obj)
            obj.lookRight();
            clear = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) > obj.wall_distance_margin_right;
        end

        function clear = path_ahead_is_clear(obj)
            obj.lookAhead();
            clear = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) > obj.wall_distance_margin_straight;
        end

        function clear = path_to_left_is_clear(obj)
            obj.lookLeft()
            clear = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) > obj.wall_distance_margin_left;
        end


        function wait_for_motors(obj)
            obj.ev3Brick.WaitForMotor(obj.left_motor_port);
            obj.ev3Brick.WaitForMotor(obj.right_motor_port);
        end


        function result = are_motors_busy(obj)
            result = obj.ev3Brick.MotorBusy(obj.left_motor_port) == 1 || obj.ev3Brick.MotorBusy(obj.right_motor_port) == 1 ;
        end

        function move_in_cm(obj, target_distance)
            wheel_circumference = pi * obj.wheel_diameter;
            rotations_needed = target_distance / wheel_circumference;
            target_angle = rotations_needed * 360;
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed, target_angle);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed, target_angle);
        end


        function move_to_next_wall(obj)
            obj.lookAhead();
            obj.move_in_cm(obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) - obj.wall_distance_margin_straight);
        end

        function result = get_left_distance(obj)
            obj.lookLeft();
            result = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) - obj.wall_distance_margin_left;
        end

        function result = get_right_distance(obj)
            obj.lookRight();
            result = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) - obj.wall_distance_margin_right;
        end

        function wait_for_distance_reading(obj)
            obj.ev3Brick.WaitForMotor(obj.ultrasonic_pan_motor_port);
        end

        function brake(obj)
            obj.ev3Brick.StopAllMotors('Brake');
        end


        function rotate_left(obj)
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed/2, -obj.turning_degrees/2);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed/2, obj.turning_degrees/2);
            obj.wait_for_motors();
            obj.snap_robot_to_angle();
        end


        function rotate_right(obj)
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed/2, obj.turning_degrees/2);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed/2, -obj.turning_degrees/2);
            obj.wait_for_motors();
            obj.snap_robot_to_angle();
        end

        function turn_around(obj)
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed, obj.turning_degrees);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed, -obj.turning_degrees);
            obj.wait_for_motors();
            obj.snap_robot_to_angle();
        end


        function result = is_on_color(obj, color)
            ncolor = lower(strtrim(color));

            color1 = obj.ev3Brick.ColorCode(obj.color_sensor_port);

            if ncolor == "red"
                result = color1 == 5;
            elseif ncolor == "green"
                result = color1 == 3;
            elseif ncolor == "blue"
                result = color1 == 2;
            elseif ncolor == "yellow"
                result = color1;
            else
                result = false;
            end
        end
    end
end