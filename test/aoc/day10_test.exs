defmodule AocTest.Day10 do
    use ExUnit.Case
    
    import Aoc.Day10
    
    describe "utilities" do
        
        test "reduce_fraction/1" do
            
            assert reduce_fraction({2, 4}) == {1, 2}
            assert reduce_fraction({3, 27}) == {1, 9}
            assert reduce_fraction({0, 1}) == {0, 1}
            assert reduce_fraction({1, 0}) == {1, 0}
            assert reduce_fraction({4, 0}) == {1, 0}
            assert reduce_fraction({-4, 8}) == {-1, 2}
        end
        
        test "asteroid_map_from_file/1" do
           assert asteroid_map_from_file("data/day10/example_01.map") == [{1, 0}, {4, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 3}, {3, 4}, {4, 4}] 
        end
        
        test "points_between/3" do
           
            # simple positive slope
            assert points_between({1, 1}, {7, 10}, {2, 3}) == [{3, 4}, {5, 7}]
            
            # negative slope on x
            assert points_between({10, 5}, {2, 11}, {-4, 3}) == [{6, 8}]
            
            # negative slope on y
            assert points_between({1, 10}, {5, 2}, {2, -4}) == [{3, 6}]
            
            # negative x and y
            assert points_between({10, 10}, {7, 7}, {-1, -1}) == [{9, 9}, {8, 8}]
            
            # horizontal
            assert points_between({1, 3}, {4, 3}, {1, 0}) == [{2, 3}, {3, 3}]
            
            # vertical
            assert points_between({4, 4}, {4, 1}, {0, -1}) == [{4, 3}, {4, 2}]
            
            # no steps
            assert points_between({3, 3}, {10, 10}, {7, 7}) == []
        end
        
        test "visible_asteroids/3" do
            
            # load a map
            asteroid_map = asteroid_map_from_file("data/day10/example_01.map")
            
            # build a catalog
            asteroid_catalog = asteroid_catalog_from_map(asteroid_map)
            
            # let's run some tests
            assert visible_asteroids(asteroid_map, asteroid_catalog, {1, 0}) == 7
            assert visible_asteroids(asteroid_map, asteroid_catalog, {4, 0}) == 7
            assert visible_asteroids(asteroid_map, asteroid_catalog, {0, 2}) == 6
            assert visible_asteroids(asteroid_map, asteroid_catalog, {1, 2}) == 7
            assert visible_asteroids(asteroid_map, asteroid_catalog, {2, 2}) == 7
            assert visible_asteroids(asteroid_map, asteroid_catalog, {3, 2}) == 7
            assert visible_asteroids(asteroid_map, asteroid_catalog, {4, 2}) == 5
            assert visible_asteroids(asteroid_map, asteroid_catalog, {4, 3}) == 7
            assert visible_asteroids(asteroid_map, asteroid_catalog, {3, 4}) == 8
            assert visible_asteroids(asteroid_map, asteroid_catalog, {4, 4}) == 7
            
        end
        
        test "remove_occluded/2" do
            asteroid_map = asteroid_map_from_file("data/day10/example_01.map")
            assert remove_occluded(asteroid_map, {4, 2}) == [{1, 0}, {4, 0}, {3, 2}, {4, 3}, {3, 4}]
        end
        
        test "order_asteroids_by_angle/2" do
            
            # load a map
            asteroid_map = asteroid_map_from_file("data/day10/example_06.map")
            
            # remove occlusions
            unoccluded_map = remove_occluded(asteroid_map, {8, 3})
            
            # order and test
            assert order_asteroids_by_angle(unoccluded_map, {8, 3}) |> Enum.take(9) == [{8, 1}, {9, 0}, {9, 1}, {10, 0}, {9, 2}, {11, 1}, {12, 1}, {11, 2}, {15, 1}]
        end
        
        test "vaporization_order/2 - example_06" do

            # load a map, and build the vaporization ordering
            asteroid_map = asteroid_map_from_file("data/day10/example_06.map")
            vapor_order = vaporization_order(asteroid_map, {8, 3})
            
            # do we get a full ordering
            assert length(vapor_order) == 36
            
            # is the last one correct?
            assert vapor_order |> List.last() == {14, 3}
            
        end
        
        test "vaporization_order/2 - example_05" do
            
            # load a map, and build the vaporization ordering
            asteroid_map = asteroid_map_from_file("data/day10/example_05.map")
            vapor_order = vaporization_order(asteroid_map, {11, 13})
            
            # The 1st asteroid to be vaporized is at 11,12.
            assert vapor_order |> Enum.at(0) == {11, 12}
            
            # The 2nd asteroid to be vaporized is at 12,1.
            assert vapor_order |> Enum.at(1) == {12, 1}

            # The 3rd asteroid to be vaporized is at 12,2.
            assert vapor_order |> Enum.at(2) == {12, 2}

            # The 10th asteroid to be vaporized is at 12,8.
            assert vapor_order |> Enum.at(9) == {12, 8}

            # The 20th asteroid to be vaporized is at 16,0.
            assert vapor_order |> Enum.at(19) == {16, 0}

            # The 50th asteroid to be vaporized is at 16,9.
            assert vapor_order |> Enum.at(49) == {16, 9}

            # The 100th asteroid to be vaporized is at 10,16.
            assert vapor_order |> Enum.at(99) == {10, 16}

            # The 199th asteroid to be vaporized is at 9,6.
            assert vapor_order |> Enum.at(198) == {9, 6}

            # The 200th asteroid to be vaporized is at 8,2.
            assert vapor_order |> Enum.at(199) == {8, 2}

            # The 201st asteroid to be vaporized is at 10,9.
            assert vapor_order |> Enum.at(200) == {10, 9}

            # The 299th and final asteroid to be vaporized is at 11,1.
            assert vapor_order |> Enum.at(298) == {11, 1}
            
        end
    end
    
    describe "problem 1" do
        
        test "example 01" do
            asteroid_map = asteroid_map_from_file("data/day10/example_01.map")            
            assert highest_visibility_asteroid(asteroid_map) == {{3, 4}, 8}
        end

        test "example 02" do
            asteroid_map = asteroid_map_from_file("data/day10/example_02.map")            
            assert highest_visibility_asteroid(asteroid_map) == {{5, 8}, 33}
        end

        test "example 03" do
            asteroid_map = asteroid_map_from_file("data/day10/example_03.map")            
            assert highest_visibility_asteroid(asteroid_map) == {{1, 2}, 35}
        end

        test "example 04" do
            asteroid_map = asteroid_map_from_file("data/day10/example_04.map")            
            assert highest_visibility_asteroid(asteroid_map) == {{6, 3}, 41}
        end

        test "example 05" do
            asteroid_map = asteroid_map_from_file("data/day10/example_05.map")            
            assert highest_visibility_asteroid(asteroid_map) == {{11, 13}, 210}
        end

    end

end