classdef Joystick < handle
    properties(Access=private)
        fig
        htmlContent
        navigator
    end

    properties(Access=public)
        is_enabled
    end

    methods
        function obj = Joystick(navigator)
            obj.is_enabled = true;
            obj.navigator = navigator;
            obj.fig = uifigure('Name', 'Robot Controls', 'Position', [0 0 500 320]);
            obj.htmlContent = uihtml(obj.fig, 'Position', [0 0 500 320]);
            obj.htmlContent.HTMLSource = './UI/Joystick.html';
            obj.htmlContent.HTMLEventReceivedFcn = @obj.eventRecieved;
        end


        function changeMotorStates(obj, lr, ud, lift)
            left_power = max(40 * lr + 40, 0)*ud;
            right_power = max(-40 * lr + 40, 0)*ud;

            lift_power = lift * 10;

            obj.navigator.ev3Brick.MoveMotor(obj.navigator.left_motor_port, left_power);
            obj.navigator.ev3Brick.MoveMotor(obj.navigator.right_motor_port, right_power);
            obj.navigator.ev3Brick.MoveMotor(obj.navigator.wheelchair_lift_motor_port, lift_power);
        end

        function eventRecieved(obj, ~, event)
            name = event.HTMLEventName;
            if strcmp(name,'DataChange')
                eventData = event.HTMLEventData;
                obj.changeMotorStates(eventData(1), eventData(2), eventData(3));

            elseif strcmp(name, 'ControlStateChange')
                obj.is_enabled = event.HTMLEventData;
                if ~obj.is_enabled
                    %if joystick was disabled, re enable self driving
                    obj.changeMotorStates(0, 0, 0)
                    obj.navigator.run()
                end
            end
        end
    end
end