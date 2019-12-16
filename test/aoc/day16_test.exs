defmodule AocTest.Day16 do
    use ExUnit.Case
    
    import Aoc.Day16
    
    describe "utilities" do
       
       test "fft_pattern/2" do
           
           assert fft_pattern([0, 1, 0, -1], index: 0, length: 3) == [1, 0, -1]
           assert fft_pattern([0, 1, 0, -1], index: 1, length: 9) == [0, 1, 1, 0, 0, -1, -1, 0, 0]
           assert fft_pattern([0, 1, 0, -1], index: 2, length: 24) == [0, 0, 1, 1, 1, 0, 0, 0, -1, -1, -1, 0, 0, 0, 1, 1, 1, 0, 0, 0, -1, -1, -1, 0]
           
       end 
       
       test "repeat_digit/2" do
           assert repeat_digit(1, 1) == [1]
           assert repeat_digit(3, 4) == [3, 3, 3, 3]
       end
       
       test "extend_pattern/2" do
           assert extend_pattern([1, 2, 3], 3) == [1, 2, 3]
           assert extend_pattern([1, 2, 3], 4) == [1, 2, 3, 1, 2, 3]
           assert extend_pattern([1, 2, 3], 11) == [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
       end
       
    end
    
    describe "problem 01" do
        
        test "example 01" do
            
            assert fft(12345678, 1) == [4,8,2,2,6,1,5,8]
            assert fft(48226158, 1) == [3,4,0,4,0,4,3,8]
            assert fft(34040438, 1) == [0,3,4,1,5,5,1,8]
            assert fft([0,3,4,1,5,5,1,8], 1) == [0,1,0,2,9,4,9,8]
            
            assert fft("12345678", 4) == [0,1,0,2,9,4,9,8]
            
        end
        
        test "example 02" do
           assert fft("80871224585914546619083218645595", 100) |> Enum.take(8) == [2,4,1,7,6,1,7,6] 
        end
        
        test "example 03" do
           assert fft("19617804207202209144916044189917", 100) |> Enum.take(8) == [7,3,7,4,5,4,1,8] 
        end
        
        test "example 04" do
           assert fft("69317163492948606335995924319873", 100) |> Enum.take(8) == [5,2,4,3,2,1,3,3] 
        end
    end
    
    # describe "problem 02" do
    #
    #     test "example 01" do
    #         assert decode_signal("03036732577212944063491565474664") == [8,4,4,6,2,0,2,6]
    #     end
    #
    #     test "example 02" do
    #         assert decode_signal("02935109699940807407585447034323") == [7,8,7,2,5,2,7,0]
    #     end
    #
    #     test "example 03" do
    #         assert decode_signal("03081770884921959731165446850517") == [5,3,5,5,3,7,3,1]
    #     end
    # end
    
end