if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1');
end
disp('EV3 Brick found');


%car.color_test();


car = Navigator(ev3Brick);
car.run();