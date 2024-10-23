%if the variable called 'ev3Brick' does not exist, then connect to the brick. Otherwise, continue running
if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1'); %This function only needs to be run once each time the brick is powered on
end
disp('EV3 Brick found');



calibrator = Calibrator(ev3Brick);
calibrator.rotateLeft(90, 50);
calibrator.rotateRight(90, 50);


%------------------------------------  Parameters  --------------------------------------
left_motor_port = 'A'; %port that the left motor is connected to

right_motor_port = 'B'; %port that the right motor is connected to

touch_sensor_port = 1; %port that the touch sensor is connected to

color_sensor_port = 2; %port that the color sensor is connected to

turning_degrees = 110; %the angle in degrees to turn the left motor to make the car turn at a right angle

motor_speed = 50; %speed to run the motors during the program
%----------------------------------------------------------------------------------------

%car = Vantage(ev3Brick, left_motor_port, right_motor_port, touch_sensor_port, color_sensor_port, motor_speed, turning_degrees);

%car.run();