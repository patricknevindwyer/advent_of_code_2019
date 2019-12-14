defmodule AocTest.Day14 do
    use ExUnit.Case
    
    import Aoc.Day14
    
    describe "utilities" do
       
       test "parse_reaction/1 - example 1" do
           assert parse_reaction("10 ORE => 10 A") == %{ chemical: {"A", 10}, reagents: [ {"ORE", 10} ]}
       end 

       test "parse_reaction/1 - example 2" do
           assert parse_reaction("2 AB, 3 BC, 4 CA => 1 FUEL") == %{ chemical: {"FUEL", 1}, reagents: [ {"AB", 2}, {"BC", 3}, {"CA", 4} ]}
       end 

       test "parse_reaction/1 - example 3" do
           assert parse_reaction("3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT") == %{ chemical: {"KHKGT", 8}, reagents: [ {"DCFZ", 3}, {"NZVS", 7}, {"HKGWZ", 5}, {"PSHF", 10} ]}
       end 
       
       test "reactions_from_file/1" do           
           assert reactions_from_file("data/day14/example_01.chems") == [
               %{ chemical: {"A", 10}, reagents: [ {"ORE", 10} ] },
               %{ chemical: {"B", 1},  reagents: [ {"ORE", 1} ] },
               %{ chemical: {"C", 1},  reagents: [ {"A", 7}, {"B", 1} ] },
               %{ chemical: {"D", 1},  reagents: [ {"A", 7}, {"C", 1} ] },
               %{ chemical: {"E", 1},  reagents: [ {"A", 7}, {"D", 1} ] },
               %{ chemical: {"FUEL", 1}, reagents: [ {"A", 7}, {"E", 1} ] }
           ]
       end
       
       test "reagents_for/2 - exact" do
           reactions = reactions_from_file("data/day14/example_01.chems")
           
           # get our formula
           formula = reactions |> List.first()
           
           assert reagents_for(formula, 10) == {[{"ORE", 10}], 0}
       end
       
       test "reagents_for/2 - under" do
           formula = parse_reaction("2 AB, 3 BC, 4 CA => 3 FUEL")
           
           assert reagents_for(formula, 2) == {[ {"AB", 2}, {"BC", 3}, {"CA", 4} ], 1}
       end
       
       test "reagents_for/2 - over" do
           formula = parse_reaction("2 AB, 3 BC, 4 CA => 3 FUEL")
           
           assert reagents_for(formula, 5) == {[ {"AB", 4}, {"BC", 6}, {"CA", 8} ], 1}
       end
       
       test "reagents_for/2 - multiples" do
           formula = parse_reaction("2 AB, 3 BC, 4 CA => 3 FUEL")
           
           assert reagents_for(formula, 11) == {[ {"AB", 8}, {"BC", 12}, {"CA", 16} ], 1}
       end
       
       test "reagents_for/2 - lot's left over" do
           formula = parse_reaction("2 AB, 3 BC, 4 CA => 10 FUEL")
           
           assert reagents_for(formula, 2) == {[ {"AB", 2}, {"BC", 3}, {"CA", 4} ], 8}
           
       end
       
       
    end
    
    describe "problem 01" do
       
       test "example 01" do
           reactions = reactions_from_file("data/day14/example_01.chems")
           assert ore_requirements(reactions, %{"FUEL" => 1}) == 31
       end 

       test "example 02" do
           reactions = reactions_from_file("data/day14/example_02.chems")
           assert ore_requirements(reactions, %{"FUEL" => 1}) == 165
       end        
       
       test "example 03" do
           reactions = reactions_from_file("data/day14/example_03.chems")
           assert ore_requirements(reactions, %{"FUEL" => 1}) == 13312
       end 
       
       test "example 04" do
           reactions = reactions_from_file("data/day14/example_04.chems")
           assert ore_requirements(reactions, %{"FUEL" => 1}) == 180697
       end 
       
       test "example 05" do
           reactions = reactions_from_file("data/day14/example_05.chems")
           assert ore_requirements(reactions, %{"FUEL" => 1}) == 2210736
       end 
       
       
    end

    describe "problem 02" do
        
        test "example 03" do
            reactions = reactions_from_file("data/day14/example_03.chems")
            assert maximize_fuel(reactions, 1000000000000) == 82892753
        end             

        test "example 04" do
            reactions = reactions_from_file("data/day14/example_04.chems")
            assert maximize_fuel(reactions, 1000000000000) == 5586022
        end             

        test "example 05" do
            reactions = reactions_from_file("data/day14/example_05.chems")
            assert maximize_fuel(reactions, 1000000000000) == 460664
        end             
        
    end
end