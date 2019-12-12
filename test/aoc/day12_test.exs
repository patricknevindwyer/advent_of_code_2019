defmodule AocTest.Day12 do
    use ExUnit.Case
    
    import Aoc.Day12
    alias Aoc.Day12.Body
    
    describe "utilities" do
        
        test "Body.create_body/3" do
            assert Body.create_body(1, 3, 7) == %Body{x: 1, y: 3, z: 7, vel_x: 0, vel_y: 0, vel_z: 0}
        end
        
        test "create_body/1" do
            assert create_body("<x=-1, y=0, z=2>") == %Body{x: -1, y: 0, z: 2, vel_x: 0, vel_y: 0, vel_z: 0}
            assert create_body("<x=2, y=-10, z=-7>") == %Body{x: 2, y: -10, z: -7, vel_x: 0, vel_y: 0, vel_z: 0}
        end
        
        test "bodies_from_file/1" do
            
            assert bodies_from_file("data/day12/example_01.bodies") == [
                %Body{x: -1, y: 0, z: 2},
                %Body{x: 2, y: -10, z: -7},
                %Body{x: 4, y: -8, z: 8},
                %Body{x: 3, y: 5, z: -1}
            ]
        end
        
        test "Body.gravitation_effect/2" do
            [body_a|_] = bodies = bodies_from_file("data/day12/example_01.bodies")
            assert Body.gravitation_effect(body_a, bodies) == %{x: 3, y: -1, z: -1}
        end
        
        test "Body.update/2" do
            [body_a|_] = bodies = bodies_from_file("data/day12/example_01.bodies")
            grav = Body.gravitation_effect(body_a, bodies)
            
            assert Body.update(body_a, grav) == %Body{x: 2, y: -1, z: 1, vel_x: 3, vel_y: -1, vel_z: -1}
        end
        
        test "step_bodies/1" do
            [a, b, c, d] = bodies_from_file("data/day12/example_01.bodies")
            |> step_bodies()
            
            # test our bodies
            assert a == %Body{x: 2, y: -1, z: 1, vel_x: 3, vel_y: -1, vel_z: -1}
            assert b == %Body{x: 3, y: -7, z: -4, vel_x: 1, vel_y: 3, vel_z: 3}
            assert c == %Body{x: 1, y: -7, z: 5, vel_x: -3, vel_y: 1, vel_z: -3}
            assert d == %Body{x: 2, y: 2, z: 0, vel_x: -1, vel_y: -3, vel_z: 1}
        end
        
        test "step_bodies/2" do
            [a, b, c, d] = bodies_from_file("data/day12/example_01.bodies")
            |> step_bodies(10)
            
            # test our bodies
            assert a == %Body{x: 2, y: 1, z: -3, vel_x: -3, vel_y: -2, vel_z: 1}
            assert b == %Body{x: 1, y: -8, z: 0, vel_x: -1, vel_y: 1, vel_z: 3}
            assert c == %Body{x: 3, y: -6, z: 1, vel_x: 3, vel_y: 2, vel_z: -3}
            assert d == %Body{x: 2, y: 0, z: 4, vel_x: 1, vel_y: -1, vel_z: -1}
            
        end
        
        test "Body.energy/1" do
            [a, b, c, d] = bodies_from_file("data/day12/example_01.bodies")
            |> step_bodies(10)
            
            assert Body.energy(a) == 36
            assert Body.energy(b) == 45
            assert Body.energy(c) == 80
            assert Body.energy(d) == 18
        end
        
        test "system_energy/1" do
            assert bodies_from_file("data/day12/example_01.bodies")
            |> step_bodies(10)            
            |> system_energy() == 179
        end
        
        test "step_until_repeat/1" do
            assert bodies_from_file("data/day12/example_01.bodies") 
            |> steps_until_repeat() == 2772            
        end
    end
    
    describe "example 02" do
        test "system_energy/1" do
            assert bodies_from_file("data/day12/example_02.bodies")
            |> step_bodies(100)            
            |> system_energy() == 1940
        end
    end
    
    describe "problem 02" do
        test "example 01 - states" do
            
           original_bodies = bodies_from_file("data/day12/example_01.bodies") 
           changed = original_bodies |> step_bodies(2772)
           assert original_bodies == changed
           
        end
        
        test "example 01 - state sets" do
            original_bodies = bodies_from_file("data/day12/example_01.bodies") 
            changed = original_bodies |> step_bodies(2772)
           
            state_set = MapSet.new() |> MapSet.put(original_bodies)
           
            assert state_set |> MapSet.member?(changed) 
        end
        
        test "example 02 - efficient sim" do
            assert bodies_from_file("data/day12/example_02.bodies")
            |> steps_until_repeat() == 4686774924
        end
    end
end