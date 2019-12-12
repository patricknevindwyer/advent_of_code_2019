defmodule Aoc.Day12 do
    @moduledoc """
    Advent of Code 2019. Day 12. Problem 01/02.
    
    https://adventofcode.com/2019/day/12
    """ 
    
    def problem_01 do
        bodies_from_file("data/day12/problem_01.bodies")
        |> step_bodies(1000)
        |> system_energy()
    end
    
    def problem_02 do
        bodies_from_file("data/day12/problem_01.bodies")
        |> steps_until_repeat
    end
    
    defmodule Body do
        @moduledoc """
        Handle operations with a celestial body.
        """
        defstruct [:x, :y, :z, vel_x: 0, vel_y: 0, vel_z: 0]

        @doc """
        Create a body at (X, Y, Z).
    
        ## Example
    
            iex> create_body(3, 5, 7)
            %Body{x: 3, y: 5, z: 7, vel_x: 0, vel_y: 0, vel_z: 0}
    
        """        
        def create_body(x, y, z) do
            %Body{x: x, y: y, z: z}
        end
        
        def update(%Body{x: x, y: y, z: z, vel_x: vel_x, vel_y: vel_y, vel_z: vel_z}, %{x: g_x, y: g_y, z: g_z}) do
           %Body{
               x: x + (vel_x + g_x),
               y: y + (vel_y + g_y),
               z: z + (vel_z + g_z),
               vel_x: vel_x + g_x,
               vel_y: vel_y + g_y,
               vel_z: vel_z + g_z
           } 
        end
        
        def energy(%Body{x: x, y: y, z: z, vel_x: vel_x, vel_y: vel_y, vel_z: vel_z}) do
            
            pot_e = [x, y, z] |> Enum.map(&abs/1) |> Enum.sum()
            kin_e = [vel_x, vel_y, vel_z] |> Enum.map(&abs/1) |> Enum.sum()
            
            pot_e * kin_e
        end
        
        @doc """
        Calculate the gravitational velocity effect of the list of bodies on the target
        body. The result will be a map of %{vel_x, vel_y, vel_z} values, not yet applied
        to the target body. It does not matter if the target body is in the list of bodies,
        as it will have 0 net effect on itself.
        """
        def gravitation_effect(%Body{}=body, bodies) when is_list(bodies) do
            
            [x, y, z] = bodies
            
            # determine our effect from each body
            |> Enum.map(
                fn grav_body ->
                    
                    delta_x = cond do
                       grav_body.x > body.x -> 1
                       grav_body.x < body.x -> -1
                       true -> 0 
                    end
                    
                    delta_y = cond do
                       grav_body.y > body.y -> 1
                       grav_body.y < body.y -> -1
                       true -> 0 
                    end
                    
                    delta_z = cond do
                       grav_body.z > body.z -> 1
                       grav_body.z < body.z -> -1
                       true -> 0 
                    end
                    
                    [delta_x, delta_y, delta_z]
                end
            )
            
            # now mash the coordinate spaces together
            |> Enum.zip()
            |> Enum.map(&Tuple.to_list/1)
            
            # and run our sums
            |> Enum.map(&Enum.sum/1)
            
            %{x: x, y: y, z: z}
        end
    end
    
    @doc """
    Step the sytem of bodies one step forward.
    """
    def step_bodies(bodies) do
        
        # find our gravity effects
        gravs = bodies
        |> Enum.map(
            fn body -> 
                Body.gravitation_effect(body, bodies)
            end
        )
        
        # now apply
        [bodies, gravs]
        |> Enum.zip()
        |> Enum.map(
            fn {body, grav} -> 
                Body.update(body, grav)
            end
        )
    end
    
    @doc """
    Step the system N times
    """
    def step_bodies(bodies, 0), do: bodies
    def step_bodies(bodies, steps) do
        step_bodies(bodies) |> step_bodies(steps - 1)
    end
    
    @doc """
    Step the system of bodies until the **positions and velocities** exactly
    repeat a previous state. Rather than running the entire system by brute
    force (which for most sets of bodies would take until the heat death of
    the universe), we use the fact that our three dimensions are independent
    of one another for the purposes of our calculations - we can determine
    a repeat rate for each dimension separately, and then find the least
    common multiple of the three rates. (h/t https://www.reddit.com/r/adventofcode/comments/e9jxh2/help_2019_day_12_part_2_what_am_i_not_seeing/)
    """
    def steps_until_repeat(bodies) do        
        state_map = MapSet.new() |> MapSet.put(state_vector(bodies, :x))
        x_steps = steps_until_repeat(bodies, :x, state_map, 0)
        
        state_map = MapSet.new() |> MapSet.put(state_vector(bodies, :y))
        y_steps = steps_until_repeat(bodies, :y, state_map, 0)
        
        state_map = MapSet.new() |> MapSet.put(state_vector(bodies, :z))
        z_steps = steps_until_repeat(bodies, :z, state_map, 0)
        
        lcm(x_steps, lcm(y_steps, z_steps))
    end
    
    @doc """
    Run the recursive repeat of a system until we hit a previously seen state. We track
    the system state with the `state_vector/1` value - the position and velocity of the system
    across a single spatial dimension. This state is tracked in a MapSet, and recursively updated.
    
    
    """
    def steps_until_repeat(bodies, dimension, state_map, iter) do
        new_state = step_bodies(bodies)
        if MapSet.member?(state_map, state_vector(new_state, dimension)) do
            iter + 1
        else
            steps_until_repeat(new_state, dimension, MapSet.put(state_map, state_vector(new_state, dimension)), iter + 1)
        end
    end
    
    @doc """
    Extract the state vector of a system of bodies in one of the three spatial dimensions.
    """
    def state_vector(bodies, :x) do
       bodies
       |> Enum.map(
           fn body ->
               {body.x, body.vel_x}
           end
       ) 
    end
    
    def state_vector(bodies, :y) do
        bodies
        |> Enum.map(
            fn body ->
                {body.y, body.vel_y}
            end
        )         
    end
    
    def state_vector(bodies, :z) do
        bodies
        |> Enum.map(
            fn body ->
                {body.z, body.vel_z}
            end
        )         
    end
    
    @doc """
    Parse a celestial bodies file, and create the bodies.
    """
    def bodies_from_file(filename) do
        filename
        |> File.read!()
        |> String.split("\n")
        |> Enum.map(&create_body/1)
    end
    
    @doc """
    Parse a formatted celestial body location and create our tracking
    struct.
    
    iex> create_body("<x=3, y=2, z=-10>")
    %Body{...}
    """
    def create_body(str) when is_binary(str) do
        
        [x, y, z] = str
        # remove bracketing
        |> String.replace(["<", ">"], "")
        
        # break apart to coordinates
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        
        # parse coordinates
        |> Enum.map(
            fn coord -> 
                coord
                |> String.split("=")
                |> List.last()
                |> Integer.parse()
                |> Kernel.get_in([Access.elem(0)])
            end
        )
        
        Body.create_body(x, y, z)
    end
    
    @doc """
    Find the total system energy for a system of bodies.
    """
    def system_energy(bodies) do
        bodies
        |> Enum.map(&Body.energy/1)
        |> Enum.sum()
    end
    
    @doc """
    GCD of two values.
    """
    def gcd(a,0), do: abs(a)
    def gcd(a,b), do: gcd(b, rem(a,b))
    
    @doc """
    Least Common Multiple of two values.
    """
    def lcm(a,b), do: div(abs(a*b), gcd(a,b))
end
