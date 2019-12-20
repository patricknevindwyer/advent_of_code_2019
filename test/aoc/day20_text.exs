defmodule AocTest.Day20 do
    use ExUnit.Case
    
    import Aoc.Day20
    
    describe "examples" do
       test "map 01" do
          assert "data/day20/example_01.map" 
          |> Aoc.Day20.astar_search() 
          |> length() == 23
       end
       
       test "map 02" do
           assert "data/day20/example_02.map" 
           |> Aoc.Day20.astar_search() 
           |> length() == 58
       end 
    end
    
end