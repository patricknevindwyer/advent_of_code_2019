defmodule AocTest.Day05 do
    use ExUnit.Case
    
    import Aoc.Day05
    import ExUnit.CaptureIO

    describe "test programs" do
    
        test "example 01" do
           assert eval_program([1002,4,3,4,33]) == [1002,4,3,4,99]
        end
        
        test "example 02" do
           assert eval_program([1101,100,-1,4,0]) == [1101, 100, -1, 4, 99] 
        end
        
        test "equal - true" do
           assert capture_io(
               fn ->
                   eval_program(
                       [3,9,8,9,10,9,4,9,99,-1,8],
                       0,
                       [input_function: fn -> 8 end]
                   )
               end
           ) == "1\n"
        end
        
        test "equal - false" do
            assert capture_io(
                fn ->
                    eval_program(
                        [3,9,8,9,10,9,4,9,99,-1,8],
                        0,
                        [input_function: fn -> 7 end]
                    )
                end
            ) == "0\n"            
        end
        
        test "less than - true" do
            assert capture_io(
                fn ->
                    eval_program(
                        [3,9,7,9,10,9,4,9,99,-1,8],
                        0,
                        [input_function: fn -> 7 end]
                    )
                end
            ) == "1\n"                        
        end
        
        test "less than - false (equal)" do
            assert capture_io(
                fn ->
                    eval_program(
                        [3,9,7,9,10,9,4,9,99,-1,8],
                        0,
                        [input_function: fn -> 8 end]
                    )
                end
            ) == "0\n"                                    
        end
        
        test "less than - false (greater)" do
            assert capture_io(
                fn ->
                    eval_program(
                        [3,9,7,9,10,9,4,9,99,-1,8],
                        0,
                        [input_function: fn -> 77 end]
                    )
                end
            ) == "0\n"
            
        end
        
        test "equal - immediate mode - false" do
            assert capture_io(
                fn ->
                    eval_program(
                        [3,3,1108,-1,8,3,4,3,99],
                        0,
                        [input_function: fn -> 77 end]
                    )
                end
            ) == "0\n"            
        end
        
        test "equal - immediate mode - true" do
            assert capture_io(
                fn ->
                    eval_program(
                        [3,3,1108,-1,8,3,4,3,99],
                        0,
                        [input_function: fn -> 8 end]
                    )
                end
            ) == "1\n"
            
        end
        
        test "cmp - less" do
            assert capture_io(
                fn ->
                    eval_program(
                        [
                            3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
                            1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
                            999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
                        ],
                        0,
                        [input_function: fn -> 3 end]
                    )
                end
            ) == "999\n"
        end
        
        test "cmp - equal" do
            assert capture_io(
                fn ->
                    eval_program(
                        [
                            3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
                            1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
                            999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
                        ],
                        0,
                        [input_function: fn -> 8 end]
                    )
                end
            ) == "1000\n"
        end
        
        test "cmp - greater" do
            assert capture_io(
                fn ->
                    eval_program(
                        [
                            3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
                            1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
                            999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
                        ],
                        0,
                        [input_function: fn -> 29 end]
                    )
                end
            ) == "1001\n"
            
        end
    end
    
    describe "decode_instruction/1" do
       
       test "1002" do
           assert decode_instruction(1002) == {:multiply, :position, :immediate, :position}
       end
       
       test "1" do
           assert decode_instruction(1) == {:add, :position, :position, :position}           
       end
       
       test "11103" do
           assert decode_instruction(11103) == {:input, :position}
       end
       
       test "104" do
           assert decode_instruction(104) == {:output, :immediate}
       end
       
       test "3" do
           assert decode_instruction(11103) == {:input, :position}           
       end
       
       test "4" do
           assert decode_instruction(4) == {:output, :position}           
       end
       
       test "1104" do
           assert decode_instruction(1104) == {:output, :immediate}
       end
       
       test "11101" do
           assert decode_instruction(11101) == {:add, :immediate, :immediate, :position}
       end
       
       test "99" do
           assert decode_instruction(99) == {:halt}
       end
        
    end

end