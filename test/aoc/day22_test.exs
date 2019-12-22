defmodule AocTest.Day22 do
    use ExUnit.Case
    
    import Aoc.Day22
    
    describe "techniques" do
        @deck [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        test "deal new stack" do
            assert tech_new_stack(@deck) == [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        end
       
        test "cut - positive" do
            assert tech_cut(@deck, 3) == [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
        end
       
        test "cut - negative" do
            assert tech_cut(@deck, -4) == [6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
        end
       
        test "deal - inc 3" do
            assert tech_deal(@deck, 3) == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
        end
        
        test "factory_deck/1" do
            assert factory_deck(10) == @deck
        end
       
    end
    
    describe "single track techniques" do
        test "deal new stack" do
            assert tech_s_new_stack(10, 2) == 7
        end
        
        test "cut - positive - before" do
            assert tech_s_cut(10, 3, 1) == 8
        end
        
        test "cut - positive - after" do
            assert tech_s_cut(10, 3, 6) == 3
        end
        
        test "cut - negative - before" do
            assert tech_s_cut(10, -4, 1) == 5
        end
        
        test "cut - negative - after" do
            assert tech_s_cut(10, -4, 8) == 2
        end
    end
    
    describe "shuffles" do
        @deck [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        test "example 01" do
            assert @deck
            |> tech_deal(7)
            |> tech_new_stack()
            |> tech_new_stack() == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
        end
        
        test "example 02" do
            assert @deck
            |> tech_cut(6)
            |> tech_deal(7)
            |> tech_new_stack() == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
        end
        
        test "example 03" do
           assert @deck
           |> tech_deal(7)
           |> tech_deal(9)
           |> tech_cut(-2) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9] 
        end
        
        test "example 04" do
            assert @deck
            |> tech_new_stack()
            |> tech_cut(-2)
            |> tech_deal(7)
            |> tech_cut(8)
            |> tech_cut(-4)
            |> tech_deal(7)
            |> tech_cut(3)
            |> tech_deal(9)
            |> tech_deal(3)
            |> tech_cut(-1) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
        end
        
        test "example_04 parsing" do
            assert "data/day22/example_04.shuffle" 
            |> File.read!()
            |> parse_shuffle()
            |> run_techs(factory_deck(10)) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
            
            
        end
    end
    
end