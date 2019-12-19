defmodule AocTest.Day18 do
    use ExUnit.Case
    
    import Aoc.Day18
    
    describe "utilities" do
       test "create_maze/1 - example 01" do
           maze = "data/day18/example_01.map"
           |> File.read!()
           |> create_maze()
           
           assert maze.found_letters == []
           assert maze.steps == []
           assert maze.location == {5, 1}
           assert length(maze.letters) == 2
           assert maze.maze.width == 9
           assert maze.maze.height == 3
       end 
       
       test "create_maze/1 - example 04" do
           maze = "data/day18/example_04.map"
           |> File.read!()
           |> create_maze()
           
           assert maze.found_letters == []
           assert maze.steps == []
           assert maze.location == {8, 4}
           assert length(maze.letters) == 16
           assert maze.maze.width == 17
           assert maze.maze.height == 9
       end 
       
    end
    
    describe "problem 01" do
       test "example 01" do
          maze = "data/day18/example_01.map"
          |> File.read!()
          |> create_maze()
          |> solve_keys()
          
          assert length(maze.steps) == 8
       end 
       
       test "example 02" do
          maze = "data/day18/example_02.map"
          |> File.read!()
          |> create_maze()
          |> solve_keys()
          
          assert length(maze.steps) == 86 
       end

       test "example 03" do
          maze = "data/day18/example_03.map"
          |> File.read!()
          |> create_maze()
          |> solve_keys()
          
          assert length(maze.steps) == 132
       end
       
       # test "example 04" do
       #    maze = "data/day18/example_04.map"
       #    |> File.read!()
       #    |> create_maze()
       #    |> solve_keys()
       #
       #    assert length(maze.steps) == 136
       # end
       
       test "example 05" do
          maze = "data/day18/example_05.map"
          |> File.read!()
          |> create_maze()
          |> solve_keys()
          
          assert length(maze.steps) == 81
       end
       
       
    end
end