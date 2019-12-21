defmodule AocTest.Day21 do
    use ExUnit.Case
    
    import Aoc.Day21
    
    describe "problems" do
       test "problem 01" do
          assert problem01().damage == 19357544
       end
    end

end