classdef Robot
    properties (Access = protected)
        ev3Brick
        left_motor_port
        right_motor_port
        ultrasonic_sensor_port
        color_sensor_port
        motor_speed
        turning_degrees
        wheel_diameter
        wall_distance_margin
    end

    methods
        function obj = Robot(ev3Brick)
            obj.ev3Brick = ev3Brick;
            obj.left_motor_port = 'D';
            obj.right_motor_port = 'C';
            obj.ultrasonic_sensor_port = 4;
            obj.color_sensor_port = 1;
            obj.motor_speed = 50;
            obj.turning_degrees = 395;
            obj.wheel_diameter = 5.6;
            obj.wall_distance_margin = 10;

            obj.ev3Brick.SetColorMode(obj.color_sensor_port, 2);
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
            obj.ev3Brick.motorStepSpeed(port, speed,  angle*(1/5), angle*(3/5), angle*(1/5), 1);
        end


        function clear = path_to_right_is_clear(obj)
            obj.rotate_right();
            obj.wait_for_motors();
            clear = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) > obj.wall_distance_margin;
            obj.rotate_left();
            obj.wait_for_motors();
        end

        function clear = path_ahead_is_clear(obj)
            clear = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) > obj.wall_distance_margin;
        end

        function clear = path_to_left_is_clear(obj)
            obj.rotate_left();
            obj.wait_for_motors();
            clear = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) > obj.wall_distance_margin;
            obj.rotate_right();
            obj.wait_for_motors();
        end

        function turn_around(obj)
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed, obj.turning_degrees);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed, -obj.turning_degrees);
            obj.wait_for_motors();
        end

        function wait_for_motors(obj)
            obj.ev3Brick.WaitForMotor(obj.left_motor_port);
            obj.ev3Brick.WaitForMotor(obj.right_motor_port);
        end

        function stop_at_red_light(obj)
            obj.brake();
            pause(5);
            obj.go_forward_in_cm(34);
            obj.wait_for_motors();
        end

        function go_forward_in_cm(obj, target_distance)
            wheel_circumference = pi * obj.wheel_diameter;
            rotations_needed = target_distance / wheel_circumference;
            target_angle = rotations_needed * 360;
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed, target_angle);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed, target_angle);
        end


        function move_to_next_wall(obj)
            obj.go_forward_in_cm(obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port) - obj.wall_distance_margin);
        end


        function brake(obj)
            obj.ev3Brick.StopAllMotors('Brake');
        end


        function rotate_left(obj)
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed/2, -obj.turning_degrees/2);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed/2, obj.turning_degrees/2);
            obj.wait_for_motors();
        end


        function rotate_right(obj)
            obj.rotate_motor(obj.left_motor_port, obj.motor_speed/2, obj.turning_degrees/2);
            obj.rotate_motor(obj.right_motor_port, obj.motor_speed/2, -obj.turning_degrees/2);
            obj.wait_for_motors();
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