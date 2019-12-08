defmodule AocTest.Day08 do
    use ExUnit.Case
    
    import Aoc.Day08
    
    describe "utilities" do
       
       test "take_chunks" do
           
           start = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
           
           assert start |> take_chunks(6, 1) == [[1, 2, 3, 4, 5, 6], [7, 8, 9, 10, 11, 12]]
           assert start |> take_chunks(2, 2) == [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]
           assert start |> take_chunks(4, 3) == [start]
       end 
       
       test "flatten/1" do
           layers = [ [0,2,2,2], [1,1,2,2], [2,2,1,2], [0,0,0,0] ]
           
           assert flatten_image(layers) == [0, 1, 1, 0]
       end
    end

end