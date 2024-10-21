classdef Vantage
    properties (Access = private)
        ev3Brick
        left_motor_port %Port that the left motor is connected to
        right_motor_port %Port that the right motor is connected to
        touch_sensor_port %Port that the ultrasonic sensor is connected to
        color_sensor_port %Port that the color sensor is connected to
        turning_degrees %Amount of degrees to turn the motor to rotate the car 90 degrees
    end

    methods(Access = public) %Public methods
        function obj = Vantage(ev3Brick, left_motor_port, right_motor_port, touch_sensor_port, color_sensor_port, turning_degrees)
            ev3Brick.SetColorMode(color_sensor_port, 4);
            obj.ev3Brick = ev3Brick;
            obj.left_motor_port = left_motor_port;
            obj.right_motor_port = right_motor_port;
            obj.touch_sensor_port = touch_sensor_port;
            obj.color_sensor_port = color_sensor_port;
            obj.turning_degrees = turning_degrees;
        end

        function run(obj)
            if obj.is_on_blue_square()
                obj.run_blue_path();
            elseif obj.is_on_green_square();
                obj.run_green_path();
            end
        end
    end

    methods(Access = private) %Private methods
        function run_green_path(obj)
            %not yet implemented
        end

        function run_blue_path(obj)
            wall_number = 0;
            obj.startMotors();
            while true
                if obj.is_touching_wall()
                    if wall_number == 0
                        obj.rotate_right();
                        wall_number = wall_number + 1;
                    elseif wall_number == 1
                        obj.rotate_left();
                        wall_number = wall_number + 1;
                    elseif wall_number == 2
                        obj.rotate_right();
                        wall_number = wall_number + 1;
                    elseif wall_number == 3
                        obj.rotate_left();
                        wall_number = wall_number + 1;
                    elseif obj.is_at_red_light()
                        obj.stop_at_red_light();
                        %wait 1 second for the robot to pass the red light
                        pause(1);
                        obj.rotate_left();
                    elseif wall_number == 4
                        obj.rotate_right();
                        wall_number = wall_number + 1;
                    elseif wall_number == 5
                        obj.rotate_left();
                        wall_number = wall_number + 1;
                    elseif wall_number == 6
                        obj.rotate_left();
                        wall_number = wall_number + 1;
                    elseif obj.is_on_yellow_square()
                        obj.stopMotors();
                        break;
                    end
                end
            end
        end


        function stop_at_red_light(obj)
            obj.stopMotors();
            pause(5);
            obj.startMotors();
            while obj.is_at_red_light()
                %dont exit the loop until the robot has move passed the "red light"
            end
        end

        function startMotors(obj)
            obj.ev3Brick.MoveMotor(obj.left_motor_port, 50);
            obj.ev3Brick.MoveMotor(obj.right_motor_port, 50);
        end

        function stopMotors(obj)
            obj.ev3Brick.MoveMotor(obj.left_motor_port, 0);
            obj.ev3Brick.MoveMotor(obj.right_motor_port, 0);
        end

        function result = is_touching_wall(obj)
            if obj.ev3Brick.TouchPressed(obj.touch_sensor_port) == 1
                result = true;
            else
                result = false;
            end
        end

        function rotate_left(obj)
            obj.stopMotors();
            obj.ev3Brick.MoveMotorAngleRel(obj.right_motor_port, 50, obj.turning_degrees, 'Brake');
            obj.startMotors();
        end

        function rotate_right(obj)
            obj.stopMotors();
            obj.ev3Brick.MoveMotorAngleRel(obj.left_motor_port, 50, obj.turning_degrees, 'Brake');
            obj.startMotors();
        end

        function result = is_at_red_light(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r > 200 && g < 100 && b < 50
                result = true;
            else
                result = false;
            end
        end

        function result = is_on_yellow_square(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r > 200 && g > 200 && b < 50
                result = true;
            else
                result = false;
            end
        end

        function result = is_on_blue_square(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r < 50 && g < 50 && b > 200
                result = true;
            else
                result = false;
            end
        end

        function result = is_on_green_square(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r < 50 && g > 200 && b < 50
                result = true;
            else
                result = false;
            end
        end


        function [red, green, blue] = get_RGB_Colors(obj)
            color_rgb = obj.ev3Brick.ColorRGB(obj.color_sensor_port);
            red = color_rgb(1);
            green = color_rgb(2);
            blue = color_rgb(3);
        end
    end
end