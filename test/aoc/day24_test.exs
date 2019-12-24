defmodule AocTest.Day24 do
    use ExUnit.Case
    
    import Aoc.Day24
    
    describe "automata stepping" do
       test "example 01" do
          g = "data/day24/example_01.cells"
          |> file_to_grid() 
          
          h = "data/day24/example_02.cells"
          |> file_to_grid()
          
          assert step_automata(g) |> eq?(h)
       end 
       
       test "example 02" do
           g = "data/day24/example_02.cells"
           |> file_to_grid() 
          
           h = "data/day24/example_03.cells"
           |> file_to_grid()
          
           assert step_automata(g) |> eq?(h)
       end
       
       test "example 03" do
           g = "data/day24/example_03.cells"
           |> file_to_grid() 
          
           h = "data/day24/example_04.cells"
           |> file_to_grid()
          
           assert step_automata(g) |> eq?(h)
       end

       test "example 04" do
           g = "data/day24/example_04.cells"
           |> file_to_grid() 
          
           h = "data/day24/example_05.cells"
           |> file_to_grid()
          
           assert step_automata(g) |> eq?(h)
       end
       
    end

    describe "utilities" do
        test "biodiversity_rating/1" do
            assert "data/day24/example_06.cells"
            |> file_to_grid()
            |> biodiversity_rating() == 2129920
        end
    end
    
    describe "recursive grids" do
        test "example 01 - bug count" do
            assert recursive_grid_from_file("data/day24/example_01.cells")
            |> step_recursive_automata(10)
            |> count_bugs() == 99
        end
        
    end
end