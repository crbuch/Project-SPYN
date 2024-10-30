classdef Navigator < Robot

    methods
        function obj = Navigator(ev3Brick)
            obj@Robot(ev3Brick);            
        end
    end

    methods(Access = public)
        function run(obj)
            while ~obj.is_on_color("Yellow")
                if obj.path_ahead_is_clear()
                    disp('Path ahead is clear\n');
                    obj.move_to_next_wall();
                elseif obj.path_to_right_is_clear()
                    disp('Path to right is clear\n');
                    obj.rotate_right();
                elseif obj.path_to_left_is_clear()
                    disp('Path to left is clear\n');
                    obj.rotate_left();
                else
                    disp('Turning around\n');
                    obj.turn_around();
                end
                pause(0.5);
            end
            obj.ev3Brick.playThreeTones();
        end
    end
end