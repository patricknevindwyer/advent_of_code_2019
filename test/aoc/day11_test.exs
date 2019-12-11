defmodule AocTest.Day11 do
    use ExUnit.Case
    
    import Aoc.Day11
    
    describe "hull_bot" do
       
       test "simulated movement" do
           assert init_hull_bot(5, 5, 3, 3)
           |> sim_instructions([1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0])
           |> painted_panel_count() == 6
       end 
       
       test "init_hull_bot/4" do
           assert init_hull_bot(100, 100, 50, 50)
           |> painted_panel_count() == 0
       end
    end
    
    describe "utilities" do

        test "first_pixel/1" do
           assert first_pixel([0, 1, 1, 0]) == 0
           assert first_pixel([-1, -1 ,1, 1, 1]) == 2
        end
        
        test "last_pixel/1" do
           assert last_pixel([0, 0, 0, 0])  == 3
           assert last_pixel([0, 0, -1, -1]) == 1
        end
    end

end