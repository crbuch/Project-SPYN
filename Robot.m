classdef Robot
    properties (Access = private)
        ev3Brick
        left_motor_port
        right_motor_port
        ultrasonic_sensor_port
        color_sensor_port 
        color_sensor_port_2
        motor_speed
        turning_degrees
        wheel_diameter
    end

    methods
        function obj = Robot(ev3Brick)
            obj.ev3Brick = ev3Brick;

            obj.left_motor_port = 'D';
            obj.right_motor_port = 'C';
            obj.ultrasonic_sensor_port = 3;
            obj.color_sensor_port = 1;
            obj.color_sensor_port_2 = 4;
            obj.motor_speed = 50;
            obj.turning_degrees = 395;
            obj.wheel_diameter = 5.6;

            obj.ev3Brick.SetColorMode(obj.color_sensor_port, 2);
            obj.ev3Brick.SetColorMode(obj.color_sensor_port_2, 2);
        end
    end

    methods(Access = protected)

        function stop_at_red_light(obj)
            obj.brake();
            pause(5);
            yield_fn = obj.go_forward_in_cm(12);
            yield_fn();
        end

        function result = go_forward_in_cm(obj, target_distance)
            wheel_circumference = pi * obj.wheel_diameter;
            
            rotations_needed = target_distance / wheel_circumference;
            target_angle = rotations_needed * 360;
        
            obj.ev3Brick.MoveMotorAngleRel(obj.left_motor_port, obj.motor_speed, target_angle, 'Brake');
            obj.ev3Brick.MoveMotorAngleRel(obj.right_motor_port, obj.motor_speed, target_angle, 'Brake');


            function yield_until_complete()
                obj.ev3Brick.WaitForMotor(obj.left_motor_port);
                obj.ev3Brick.WaitForMotor(obj.right_motor_port);
            end
            result = yield_until_complete;
        end
       
        function move_to_next_wall(obj)
            obj.go_forward_in_cm(obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port)-10);
        end

        function brake(obj)
            obj.ev3Brick.StopAllMotors('Brake');
        end

        function rotate_left(obj)
            obj.ev3Brick.MoveMotorAngleRel(obj.left_motor_port, obj.motor_speed/2, -obj.turning_degrees/2, 'Brake');
            obj.ev3Brick.MoveMotorAngleRel(obj.right_motor_port, obj.motor_speed/2, obj.turning_degrees/2, 'Brake');
            obj.ev3Brick.WaitForMotor(obj.left_motor_port);
            obj.ev3Brick.WaitForMotor(obj.right_motor_port);
        end

        function rotate_right(obj)
            obj.ev3Brick.MoveMotorAngleRel(obj.left_motor_port, obj.motor_speed/2, obj.turning_degrees/2, 'Brake');
            obj.ev3Brick.MoveMotorAngleRel(obj.right_motor_port, obj.motor_speed/2, -obj.turning_degrees/2, 'Brake');
            obj.ev3Brick.WaitForMotor(obj.left_motor_port);
            obj.ev3Brick.WaitForMotor(obj.right_motor_port);
        end

        function result = is_on_color(obj, color)
            ncolor = lower(strtrim(color));

            color1 = obj.ev3Brick.ColorCode(obj.color_sensor_port);
            color2 = obj.ev3Brick.ColorCode(obj.color_sensor_port_2);

            if ncolor == "red"
                result = (color1 == 5 || color2 == 5);
            elseif ncolor == "green"
                result = (color1 == 3 || color2 == 3);
            elseif ncolor == "blue"
                result = (color1 == 2 || color2 == 2);
            elseif ncolor == "yellow"
                result = (color1 == 4 || color2 == 4);
            else
                result = false;
            end
        end

    end
end