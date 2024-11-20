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
            left_power = max(30 * lr+30, 0)*ud;
            right_power = max(-30 * lr+30, 0)*ud;
            magnitude = sqrt(left_power*left_power + right_power*right_power);
            magnitude_lr_ud = sqrt(lr*lr+ud*ud);
            left_unit = left_power/magnitude;
            right_unit = right_power/magnitude;

            obj.navigator.ev3Brick.MoveMotor(obj.navigator.left_motor_port, left_unit*30*magnitude_lr_ud);
            obj.navigator.ev3Brick.MoveMotor(obj.navigator.right_motor_port, right_unit*30*magnitude_lr_ud);
            
            angle = -1;
            if lift > 0
                angle = 1;
            end

            obj.navigator.rotate_motor(obj.navigator.wheelchair_lift_motor_port, abs(lift*5), angle*360);
        end

        function eventRecieved(obj, ~, event)
            name = event.HTMLEventName;
            if strcmp(name,'DataChange')
                if obj.is_enabled
                    eventData = event.HTMLEventData;
                    obj.changeMotorStates(eventData(1), eventData(2), eventData(3));    
                end
            elseif strcmp(name, 'ControlStateChange')
                obj.is_enabled = event.HTMLEventData;
                if ~obj.is_enabled && ~obj.navigator.is_running
                    %if joystick was disabled, re enable self driving
                    obj.navigator.ev3Brick.StopAllMotors();
                    obj.navigator.run();
                end
            end
        end
    end
end