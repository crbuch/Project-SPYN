if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1');
end
disp('EV3 Brick found');



ev3Brick.GyroCalibrate(1);
while true
    pause(0.25);
    disp(ev3Brick.GyroAngle(1));

end




%straight: 0deg, right: 90deg or -270, left: -90deg, or 270deg, backwards: -180


%ev3Brick.StopAllMotors('Brake');


car = Navigator(ev3Brick);
car.run();
