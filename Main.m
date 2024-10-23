%if the variable called 'ev3Brick' does not exist, then connect to the brick. Otherwise, continue running
if ~exist('ev3Brick', 'var')
    ev3Brick = ConnectBrick('BRCK1'); %This function only needs to be run once each time the brick is powered on
end
disp('EV3 Brick found');


%------------------------------------  Parameters  --------------------------------------
left_motor_port = 'D'; %port that the left motor is connected to

right_motor_port = 'C'; %port that the right motor is connected to

ultrasonic_sensor_port = 3; %port that the touch sensor is connected to

color_sensor_port = 1; %port that the color sensor is connected to

color_sensor_port_2 = 4; %port for the second color sensor

turning_degrees = 395; %the angle in degrees to turn the left motor to make the car turn at a right angle

motor_speed = 50; %speed to run the motors during the program
%----------------------------------------------------------------------------------------


%ev3Brick.MoveMotor(left_motor_port, 0);
%ev3Brick.MoveMotor(right_motor_port, 0);


% if ~exist('calibrator', 'var')
%     calibrator = Calibrator(ev3Brick, left_motor_port, right_motor_port);
% end

% calibrator.rotateLeft(395, 50);
% calibrator.rotateRight(390, 50);


car = Robot(ev3Brick, left_motor_port, right_motor_port, ultrasonic_sensor_port, color_sensor_port, color_sensor_port_2, motor_speed, turning_degrees);
%car.run();

car.run_blue_path();
%car.run_green_path();