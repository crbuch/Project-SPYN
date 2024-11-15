classdef Joystick
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
            obj.fig = uifigure('Name', 'Robot Controls', 'Position', [0 0 500 320]);
            obj.htmlContent = uihtml(obj.fig, 'Position', [0 0 500 320]);
            obj.htmlContent.HTMLSource = './Joystick.html';
            obj.htmlContent.HTMLEventReceivedFcn = @obj.eventRecieved;
            obj.is_enabled = true;
            obj.navigator = navigator;
        end

        function changeMotorStates(obj, lr, ud, lift)
            
        end

        function eventRecieved(obj, ~, event)
            name = event.HTMLEventName;
            if strcmp(name,'DataChange')
                if obj.is_enabled
                    eventData = event.HTMLEventData;
                    obj.changeMotorStates(eventData(1), eventData(2), eventData(3));
                end
            elseif strcmp(name, 'ControlStateChange')
                eventData = event.HTMLEventData;
                if ~eventData
                    obj.changeMotorStates(0, 0, 0)
                    obj.navigator.run();
                end
            end
        end

    end

end

