if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1');
end
disp('EV3 Brick found');


%straight: 0deg, right: 90deg or -270, left: -90deg, or 270deg, backwards: -180


%ev3Brick.StopAllMotors('Brake');


car = Navigator(ev3Brick);
car.run();