classdef Navigator < Robot
    properties (Access=private)
        path_left_clear
        path_right_clear

        saw_blue
        saw_green
        saw_yellow
    end


    methods
        function obj = Navigator(ev3Brick)
            obj@Robot(ev3Brick);
            
            obj.saw_blue = false;
            obj.saw_green = false;
            obj.saw_yellow = false;
        end
    end


    methods(Access = public)
        function run(obj)
            while true
                obj.path_left_clear = false;
                obj.path_right_clear = false;

                if obj.path_ahead_is_clear()
                    obj.move_to_next_wall();

                    iteration = 1;
                    check_every = 2; %how often (in seconds) the robot should check left & right
                    while obj.are_motors_busy()

                        if obj.is_on_color("red")
                            disp('Red\n')
                            obj.brake();
                            pause(3);
                            obj.move_in_cm(20);
                            obj.wait_for_motors();
                        elseif ~obj.saw_blue && obj.is_on_color("blue")
                            disp('Blue\n')
                            obj.saw_blue = true;
                            obj.brake();
                            obj.ev3Brick.beep();
                            pause(0.5);
                            obj.ev3Brick.beep();
                        elseif ~obj.saw_green && obj.is_on_color("green")
                            disp('Green\n')
                            obj.saw_green = true;
                            obj.brake();
                            obj.ev3Brick.beep();
                            pause(0.5);
                            obj.ev3Brick.beep();
                            pause(0.5);
                            obj.ev3Brick.beep();

                        elseif ~obj.saw_yellow && obj.is_on_color("yellow")
                            disp('Yellow\n')
                            obj.saw_yellow = true;
                            obj.brake();
                            obj.ev3Brick.beep();
                            pause(0.5);
                            obj.ev3Brick.beep();
                            pause(0.5);
                            obj.ev3Brick.beep();
                            pause(0.5);
                            obj.ev3Brick.beep();
                        end


                        %every 2 seconds, look left & right
                        if mod(iteration, check_every/0.125) == 0
                          
                            if obj.get_left_distance() < obj.wall_distance_margin_left-5
                                %if the robot is too close to the left wall, turn a little right
                                obj.brake();
                                obj.rotate_motor(obj.left_motor_port, 50, 45);
                                pause(1);
                            end

                            pause(0.5);

                            if obj.get_right_distance() < obj.wall_distance_margin_right-5
                                obj.brake();
                                obj.rotate_motor(obj.right_motor_port, 50, 45);
                                pause(1);
                            end

                        end

                        iteration = iteration + 1;
                    end

                    continue;
                end

                if obj.path_to_right_is_clear()
                    obj.path_right_clear = true;
                end

                if obj.path_to_left_is_clear()
                    obj.path_left_clear = true;
                end

                if obj.path_left_clear && obj.path_right_clear
                    %find the longer path and move there
                    left_dist = obj.get_left_distance();
                    right_dist = obj.get_right_distance();
                    if left_dist < right_dist
                        obj.rotate_right();
                    else
                        obj.rotate_left();
                    end
                    continue;
                end

                if obj.path_left_clear && ~obj.path_right_clear
                    obj.rotate_left();
                    continue;
                end

                if obj.path_right_clear && ~obj.path_left_clear
                    obj.rotate_right();
                    continue;
                end

                if ~obj.path_right_clear && ~obj.path_left_clear
                    obj.turn_around();
                end
            end
        end
    end
end