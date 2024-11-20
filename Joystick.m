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
        function self = Joystick(navigator)
            self.is_enabled = true;
            self.navigator = navigator;
            self.fig = uifigure('Name', 'Robot Controls', 'Position', [0 0 500 320]);
            self.htmlContent = uihtml(self.fig, 'Position', [0 0 500 320]);
            self.htmlContent.HTMLSource = './UI/Joystick.html';
            self.htmlContent.HTMLEventReceivedFcn = @self.eventRecieved;
        end


        function changeMotorStates(self, lr, ud, lift)
            left_power = max(30 * lr+30, 0)*ud;
            right_power = max(-30 * lr+30, 0)*ud;
            magnitude = sqrt(left_power*left_power + right_power*right_power);
            magnitude_lr_ud = sqrt(lr*lr+ud*ud);
            left_unit = left_power/magnitude;
            right_unit = right_power/magnitude;

            self.navigator.ev3Brick.MoveMotor(self.navigator.config.Motor_Ports.Left, left_unit*30*magnitude_lr_ud);
            self.navigator.ev3Brick.MoveMotor(self.navigator.config.Motor_Ports.Right, right_unit*30*magnitude_lr_ud);
            angle = -1;
            if lift > 0
                angle = 1;
            end
            self.navigator.rotate_motor(self.navigator.config.Motor_Ports.Lift, abs(lift*5), angle*360);
        end

        function eventRecieved(self, ~, event)
            name = event.HTMLEventName;
            if strcmp(name,'DataChange')
                if self.is_enabled
                    eventData = event.HTMLEventData;
                    self.changeMotorStates(eventData(1), eventData(2), eventData(3));    
                end
            elseif strcmp(name, 'ControlStateChange')
                self.is_enabled = event.HTMLEventData;
                if ~self.is_enabled 
                    self.changeMotorStates(0, 0, 0);    
                end
            end
        end
    end
end