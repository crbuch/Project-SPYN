%if the variable called 'ev3Brick' does not exist, then connect to the brick. Otherwise, continue running
if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1'); %This function only needs to be run once each time the brick is powered on
end
disp('EV3 Brick found');


%------------------------------------  Parameters  --------------------------------------
distance_Threshold = 20; %how close the robot can be to a wall before turning

left_motor_port = 'A'; %port that the left motor is connected to

right_motor_port = 'B'; %port that the right motor is connected to

ultrasonic_sensor_port = 1; %port that the ultrasonic sensor is connected to

turning_degrees = 90; %angle in degrees to turn the left motor to make the car turn at a right angle

color_sensor_port = 2; %port that the color sensor is connected to

color_sensor_mode = 4;
%----------------------------------------------------------------------------------------


car = Vantage(ev3Brick, left_motor_port, right_motor_port, ultrasonic_sensor_port, color_sensor_port, distance_Threshold, turning_degrees, color_sensor_mode);

car.run();