defmodule AocTest.Day06 do
    use ExUnit.Case
    
    import Aoc.Day06
    
    describe "utilities" do
       
        @orbits [
            "COM)B",
            "B)C",
            "C)D",
            "D)E",
            "E)F",
            "B)G",
            "G)H",
            "D)I",
            "E)J",
            "J)K",
            "K)L"
        ]
        
        test "build_orbit_map/1" do
        
            assert @orbits |> Enum.slice(0, 2) |> build_orbit_map() == %{"C" => "B", "B" => "COM"}
         
        end 
        
        test "orbit_checksum/2" do
           om = @orbits |> build_orbit_map()
           
           assert orbit_checksum(om, "COM") == 0
           assert orbit_checksum(om, "D") == 3
           assert orbit_checksum(om, "L") == 7
        end
        
        test "path_to_com/2" do
           om = @orbits |> build_orbit_map()
           assert om |> path_to_com("D") == ["D", "C", "B", "COM"]
           assert om |> path_to_com("L") == ["L", "K", "J", "E", "D", "C", "B", "COM"]
           assert om |> path_to_com("COM") == ["COM"]
        end
    end
    
    describe "test cases" do

        @orbits [
            "COM)B",
            "B)C",
            "C)D",
            "D)E",
            "E)F",
            "B)G",
            "G)H",
            "D)I",
            "E)J",
            "J)K",
            "K)L"
        ]

        test "problem 01 - test case 01" do
           assert @orbits |> build_orbit_map() |> catalog_checksum() == 42 
        end
        
        test "problem 02 - test case 01" do
           om = @orbits |> build_orbit_map()
           
           assert om |> min_transfers("K", "I") == 4 
        end
    end

end