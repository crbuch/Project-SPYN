%This file helps find the degrees and speed needed to turn the robot 90 degrees as precise as possible
classdef Calibrator
    properties (Access=private)
        ev3Brick
        leftMotorPort
        rightMotorPort
    end
    methods
        function obj = Calibrator(ev3Brick, leftMotorPort, rightMotorPort)
            obj.ev3Brick = ev3Brick;
            obj.leftMotorPort = leftMotorPort;
            obj.rightMotorPort = rightMotorPort;
        end

        function rotateRight(degrees, speed)
            obj.ev3Brick.MoveMotorAngleRel(obj.leftMotorPort, speed, degrees, 'Brake');
            obj.ev3Brick.WaitForMotor(obj.leftMotorPort);
        end

        function rotateLeft(degrees, speed)
            obj.ev3Brick.MoveMotorAngleRel(obj.rightMotorPort, speed, degrees, 'Brake');
            obj.ev3Brick.WaitForMotor(obj.rightMotorPort);
        end
    end

end