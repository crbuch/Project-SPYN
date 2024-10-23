classdef Robot
    properties (Access = private)
        ev3Brick
        left_motor_port %Port that the left motor is connected to
        right_motor_port %Port that the right motor is connected to
        ultrasonic_sensor_port %Port that the ultrasonic sensor is connected to
        color_sensor_port %Port that the color sensor is connected to
        color_sensor_port_2 %Port that the second color sensor is connected to
        motor_speed %Speed to run the motors
        turning_degrees %Amount of degrees to turn the motor to rotate the car 90 degrees
        wall_number %current wall number
    end

    methods(Access = public) %Public methods
        function obj = Robot(ev3Brick, left_motor_port, right_motor_port, ultrasonic_sensor_port, color_sensor_port, color_sensor_port_2, motor_speed, motor_turning_degrees)
            obj.ev3Brick = ev3Brick;
            obj.ev3Brick.SetColorMode(color_sensor_port, 4);
            obj.ev3Brick.SetColorMode(color_sensor_port_2, 4);
            obj.left_motor_port = left_motor_port;
            obj.right_motor_port = right_motor_port;
            obj.ultrasonic_sensor_port = ultrasonic_sensor_port;
            obj.color_sensor_port = color_sensor_port;
            obj.motor_speed = motor_speed;
            obj.turning_degrees = motor_turning_degrees;
            obj.color_sensor_port_2 = color_sensor_port_2;
        end

        function run_green_path(obj)
            obj.run_path_starting_at(4);
        end

        function run_blue_path(obj)
            obj.run_path_starting_at(0);
        end

        function run(obj)
            while true
                if obj.is_on_blue_square()
                    obj.run_blue_path();
                    break;
                elseif obj.is_on_green_square();
                    obj.run_green_path();
                    break;
                else
                    disp('Square not found \n');
                    [r, g, b] = obj.get_RGB_Colors();
                    fprintf('color: %d, %d, %d \n', r, g, b);
                end
                pause(1);
            end
        end
    end

    methods(Access = private) %Private methods

        function run_path_starting_at(obj, starting_wall_number)
            obj.go_forward();
            run_main_loop = true;
            obj.wall_number = starting_wall_number;
            while run_main_loop
                if(obj.ev3Brick.TouchPressed(2)==1)
                    disp('Kill switch pressed\n');
                    obj.brake();
                    break;
                end

                pause(0.1);
                if obj.is_at_red_light()
                    obj.stop_at_red_light();
                    %wait 1 second for the robot to pass the red light before rotating
                    pause(0.25);
                    obj.rotate_left();
                end

                if obj.is_on_yellow_square()
                    obj.brake();
                    break;
                end

                if obj.is_touching_wall()
                    switch obj.wall_number
                        case 0
                            obj.rotate_right();
                        case 1
                            obj.rotate_left();
                        case 2
                            obj.rotate_right();
                        case 3
                            obj.rotate_left();
                        case 4
                            obj.rotate_right();
                        case 5
                            obj.rotate_left();
                        case 6
                            obj.rotate_left();
                        case 7
                            obj.brake();
                            run_main_loop = false;
                        otherwise
                            obj.brake();
                            run_main_loop = false;
                            disp('Invalid wall number. Is the robot on the right path?\n');
                    end
                    obj.wall_number = obj.wall_number + 1;
                    fprintf('wall number: %d\n', obj.wall_number);
                end
            end
        end


        function stop_at_red_light(obj)
            obj.brake();
            pause(5);
            obj.go_forward();

            while obj.is_at_red_light()
                %this loop prevents the function from exiting until the robot has move passed the "red light"
                pause(0.1);
            end
        end

        function go_forward(obj)
            disp('Moving robot forward\n');
            obj.ev3Brick.MoveMotor(obj.left_motor_port, obj.motor_speed);
            obj.ev3Brick.MoveMotor(obj.right_motor_port, obj.motor_speed);
        end

        function brake(obj)
            disp('Braking\n');
            obj.ev3Brick.MoveMotor(obj.left_motor_port, 0);
            obj.ev3Brick.MoveMotor(obj.right_motor_port, 0);
        end

        function result = is_touching_wall(obj)
            dist = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port);
            if dist < 20
                disp('Robot hit wall\n');

                result = true;
            else
                result = false;
            end
            fprintf('Distance: %d\n', dist);
        end

        function rotate_left(obj)
            disp('Rotating left\n');

            obj.brake();
            pause(0.5)
            obj.ev3Brick.MoveMotorAngleRel(obj.right_motor_port, obj.motor_speed/2, obj.turning_degrees, 'Brake');
            obj.ev3Brick.WaitForMotor(obj.right_motor_port);
            pause(0.5);
            disp('Finished rotating left\n');
            obj.go_forward();
        end

        function rotate_right(obj)
            disp('Rotating right\n');
            obj.brake();
            pause(0.5)
            obj.ev3Brick.MoveMotorAngleRel(obj.left_motor_port, obj.motor_speed/2, obj.turning_degrees, 'Brake');
            obj.ev3Brick.WaitForMotor(obj.left_motor_port);
            pause(0.5);
            disp('Finished rotating right\n');
            obj.go_forward();
        end


        function result = is_at_red_light(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r > 150 && g < 100 && b < 50
                result = true;
            else
                result = false;
            end
        end

        function result = is_on_yellow_square(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r > 150 && g > 150 && b < 50
                result = true;
            else
                result = false;
            end
        end

        function result = is_on_blue_square(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r < 50 && g < 50 && b > 150
                result = true;
            else
                result = false;
            end
        end

        function result = is_on_green_square(obj)
            [r, g, b] = obj.get_RGB_Colors();
            if r < 50 && g > 150 && b < 50
                result = true;
            else
                result = false;
            end
        end


        function [red, green, blue] = get_RGB_Colors(obj)
            color_rgb = obj.ev3Brick.ColorRGB(obj.color_sensor_port);
            color_rgb_2 = obj.ev3Brick.ColorRGB(obj.color_sensor_port_2);
            r1 = color_rgb(1);
            g1 = color_rgb(2);
            b1 = color_rgb(3);

            r2 = color_rgb_2(1);
            g2 = color_rgb_2(2);
            b2 = color_rgb_2(3);

            red = (r1+r2)/2;
            green = (g1+g2)/2;
            blue = (b1+b2)/2;

        end
    end
end