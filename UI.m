fig = uifigure('Name', 'Robot Controls', 'Position', [0 0 600 350]);

htmlContent = uihtml(fig, 'Position', [0 0 600 350]);

htmlContent.HTMLSource = './Joystick.html';

htmlContent.HTMLEventReceivedFcn = @eventRecieved;

function eventRecieved(~, event)
    name = event.HTMLEventName;
    if strcmp(name,'DataChange')
        eventData = event.HTMLEventData;
        lr = eventData(1);
        ud = eventData(2);
        lift = eventData(3);

        disp(lr);
        disp(ud);
        disp(lift);
    end
end