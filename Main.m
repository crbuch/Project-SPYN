if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1');
end
disp('EV3 Brick found');

%{
Ideas:
make the robot follow the left or right wall:
* first the robot looks forward, and it will travel that way while looking left/right and maintaining a certain
distance from the wall
%}

%ev3Brick = MockBrick();


car = Navigator(ev3Brick, "./Config.json");
car.run();