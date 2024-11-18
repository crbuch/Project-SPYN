if ~exist('ev3Brick', 'var')
  ev3Brick = ConnectBrick('BRCK1');
end
disp('EV3 Brick found');

%ev3Brick.StopAllMotors()

% %car.color_test();

%ev3Brick = MockBrick();

car = Navigator(ev3Brick);

