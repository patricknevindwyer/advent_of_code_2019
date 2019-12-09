defmodule AocTest.Day09 do
    use ExUnit.Case
    
    import Aoc.Day09
    
    describe "problem 01" do
       
       test "example - quine" do
           program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
           assert run_intcode(program) == program
       end
       
       test "example - large number" do
           result = run_intcode([1102,34915192,34915192,7,4,7,99,0])
           
           assert length(result) == 1
           assert result |> Enum.at(0) |> Integer.digits() |> length() == 16
           
       end
       
       test "example - large params" do
           assert run_intcode([104,1125899906842624,99]) == [1125899906842624]
       end
       
    end
    
    describe "utilities" do
       
       test "program_from_file" do
          assert "data/day09/quine.ic" |> program_from_file() |> run_intcode() == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] 
       end 
    end
    
end