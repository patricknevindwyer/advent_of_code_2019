defmodule AocTest.Day04 do
  use ExUnit.Case

  import Aoc.Day04

  describe "test cases - problem 01" do
      
      test "122345" do
          assert fullfils_predicates?(122345, [&adjacent_digits?/1, &always_increasing?/1])
      end
      
      test "123456" do
          assert !fullfils_predicates?(123456, [&adjacent_digits?/1, &always_increasing?/1])
      end

      test "111123" do
          assert fullfils_predicates?(111123, [&adjacent_digits?/1, &always_increasing?/1])
      end

      test "135679" do
          assert !fullfils_predicates?(135679, [&adjacent_digits?/1, &always_increasing?/1])
      end
      
      test "111111" do
          assert fullfils_predicates?(111111, [&adjacent_digits?/1, &always_increasing?/1])
      end

      test "223450" do
          assert !fullfils_predicates?(223450, [&adjacent_digits?/1, &always_increasing?/1])
      end

      test "123789" do
          assert !fullfils_predicates?(123789, [&adjacent_digits?/1, &always_increasing?/1])
      end
      
      test "124075" do
          assert !fullfils_predicates?(124075, [&adjacent_digits?/1, &always_increasing?/1])
      end
      
      test "580769" do
          assert !fullfils_predicates?(580769, [&adjacent_digits?/1, &always_increasing?/1])
      end
      
      test "911234" do
          assert !fullfils_predicates?(911234, [&adjacent_digits?/1, &always_increasing?/1])
      end
      
            
  end
  
  describe "test cases - problem 02" do
     
     test "112233" do
         assert fullfils_predicates?(112233, [&adjacent_digits?/1, &always_increasing?/1, &exactly_two_adjacent_digits?/1])
     end
     
     test "123444" do
         assert !fullfils_predicates?(123444, [&adjacent_digits?/1, &always_increasing?/1, &exactly_two_adjacent_digits?/1])
     end
      
     test "111122" do
         assert fullfils_predicates?(111122, [&adjacent_digits?/1, &always_increasing?/1, &exactly_two_adjacent_digits?/1])
     end
  end
  
end
