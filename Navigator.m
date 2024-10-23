classdef Navigator < Robot

    methods
        function obj = Navigator(ev3Brick)
            %Calling the constructor of the parent class
            obj@Robot(ev3Brick);            
        end

        function run(obj)
            while true
                if obj.is_on_color("Blue")
                    obj.run_path_starting_at(0);
                    break;
                elseif obj.is_on_color("Green")
                    obj.run_path_starting_at(4);
                    break;
                else
                    disp('Place robot on blue or green square \n');
                end
                pause(1);
            end
        end
    end

    %Private methods
    methods(Access = private)

        function run_path_starting_at(obj, starting_step_number)
            run_main_loop = true;
            step_number = starting_step_number;
            while run_main_loop
                if obj.is_on_yellow_square()
                    obj.brake();
                    break;
                end

                switch step_number
                    case 0
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_right();
                    case 1
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_left();
                    case 2
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_right();
                    case 3
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_left();
                    case 4
                        %do the logic of running into red light here
                        %run this asynchronously
                        obj.move_to_next_wall();

                        while true
                            if obj.is_on_color("Red")
                                obj.stop_at_red_light();
                                obj.rotate_left();
                                break;
                            end
                        end
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_right();
                    case 5
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_left();
                    case 6
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        obj.rotate_left();
                    case 7
                        yield_until_complete = obj.move_to_next_wall();
                        yield_until_complete();
                        run_main_loop = false;
                        obj.ev3Brick.playThreeTones();
                    otherwise
                        obj.brake();
                        run_main_loop = false;
                        obj.ev3Brick.playThreeTones();
                end
                step_number = step_number + 1;

                fprintf('step number: %d\n', step_number);
                
            end
        end

    end


end