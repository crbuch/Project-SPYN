classdef Vantage
    properties (Access = private)
        ev3Brick
        left_motor_port %Port that the left motor is connected to
        right_motor_port %Port that the right motor is connected to
        ultrasonic_sensor_port %Port that the ultrasonic sensor is connected to
        color_sensor_port %Port that the color sensor is connected to
        distance_threshold %closest distance the car can be from a wall before turning
        turning_degrees %Amount of degrees to turn the motor to rotate the car 90 degrees
    end

    methods(Access = public) %Public methods
        function obj = Vantage(ev3Brick, left_motor_port, right_motor_port, ultrasonic_sensor_port, color_sensor_port, distance_threshold, turning_degrees, color_mode)
            ev3Brick.SetColorMode(color_sensor_port, color_mode);
            obj.ev3Brick = ev3Brick;
            obj.left_motor_port = left_motor_port;
            obj.right_motor_port = right_motor_port;
            obj.ultrasonic_sensor_port = ultrasonic_sensor_port;
            obj.color_sensor_port = color_sensor_port;
            obj.distance_threshold = distance_threshold;
            obj.turning_degrees = turning_degrees;
        end

        function run(obj)
            while true
                color_rgb = obj.ev3Brick.ColorRGB(obj.color_sensor_port);
                red = color_rgb(1);
                green = color_rgb(2);
                blue = color_rgb(3);
            end
        end
    end

    methods(Access = private) %Private methods
        function checkForWall(obj)
            currentDist = obj.ev3Brick.UltrasonicDist(obj.ultrasonic_sensor_port);
            if currentDist < obj.distance_threshold
                obj.ev3Brick.MoveMotorAngleRel(obj.right_motor_port, 50, obj.turning_degrees, 'Brake');
            end
        end
    end
end