defmodule AocTest.Day03 do
  use ExUnit.Case

  alias Aoc.Day03

  describe "utility" do
      
      test "translate_move/1" do
          
          assert Day03.translate_move("U12") == {:up, 12}
          assert Day03.translate_move("D35") == {:down, 35}
          assert Day03.translate_move("L666") == {:left, 666}
          assert Day03.translate_move("R73") == {:right, 73}
          
      end
      
      test "moves_to_points/1 - left" do
          assert Day03.moves_to_points([Day03.translate_move("L4")]) == [{0, 1}, {-1, 1}, {-2, 1}, {-3, 1}]
      end
      
      test "moves_to_points/1 - right" do
          assert Day03.moves_to_points([Day03.translate_move("R4")]) == [{2, 1}, {3, 1}, {4, 1}, {5, 1}]
      end
      
      test "moves_to_points/1 - up" do
          assert Day03.moves_to_points([Day03.translate_move("U4")]) == [{1, 2}, {1, 3}, {1, 4}, {1, 5}] 
      end
      
      test "moves_to_points/1 - down" do
          assert Day03.moves_to_points([Day03.translate_move("D4")]) == [{1, 0}, {1, -1}, {1, -2}, {1, -3}]  
      end
      
      test "moves_to_points/1 - mixed" do
          moves = ["R1", "U1", "L1", "D1"] |> Enum.map(&Day03.translate_move/1)
          assert Day03.moves_to_points(moves) == [{2, 1}, {2, 2}, {1, 2}, {1, 1}]
      end
      
      test "moves_with_counts/1" do 
          assert Day03.moves_with_counts([{1, 1}, {1, 2}]) == [{1, 1, 1}, {1, 2, 2}]
      end
  end
  
  describe "problem 01" do
     
     test "test case 01" do
         wire_a = ["R8","U5","L5","D3"]
         wire_b = ["U7","R6","D4","L4"]
         assert Day03.shortest_distance(wire_a, wire_b) == 6
     end 
     
     test "test case 02" do
         wire_a = ["R75","D30","R83","U83","L12","D49","R71","U7","L72"]
         wire_b = ["U62","R66","U55","R34","D71","R55","D58","R83"] 
         assert Day03.shortest_distance(wire_a, wire_b) == 159
     end
     
     test "test case 03" do
         wire_a = ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"]
         wire_b = ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]
         assert Day03.shortest_distance(wire_a, wire_b) == 135
     end
  end
  
  describe "problem 02" do
     
     test "test case 01" do
         wire_a = ["R8","U5","L5","D3"]
         wire_b = ["U7","R6","D4","L4"]
         assert Day03.nearest_intersection(wire_a, wire_b) == 30
     end 
     
     test "test case 02" do
         wire_a = ["R75","D30","R83","U83","L12","D49","R71","U7","L72"]
         wire_b = ["U62","R66","U55","R34","D71","R55","D58","R83"] 
         assert Day03.nearest_intersection(wire_a, wire_b) == 610
     end
     
     test "test case 03" do
         wire_a = ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"]
         wire_b = ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]
         assert Day03.nearest_intersection(wire_a, wire_b) == 410
     end
  end
  
end
