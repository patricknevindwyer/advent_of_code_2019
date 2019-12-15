defmodule Aoc.Day15 do
    @moduledoc """
    Advent of Code 2019. Day 15. Problem 01/02.
    
    https://adventofcode.com/2019/day/15
    
    """ 
    
    alias Aoc.Intcode
    alias Chunky.Grid
    
    def problem02 do
        
        # run the droid to find our map
        %{maze: maze} = maze_state = run_droid()
        
        # mark the oxygen sensor with oxygen
        [{oxy_x, oxy_y}] = find_index(maze, "S")
        start_grid = maze |> Grid.put_at(oxy_x, oxy_y, "O")
        
        # count steps to flood fill the rest of the map with oxygen
        steps = oxygen_flood(%{maze_state | maze: start_grid})
        
        IO.puts("Took #{steps} seconds to flood oxygen")
        
    end
    
    def problem01 do
    
        # run our droid until we're fairly certain we have a full map of the maze
        route = run_droid()
        |> depth_search()
        
        IO.puts("Min route length: #{length(route)}")
    end
    
    def find_index(grid, val) do
        0..grid.height - 1
        |> Enum.map(
            fn y -> 
                0..grid.width - 1
                |> Enum.map(
                    fn x -> 
                        {grid |> Grid.get_at(x, y) == val, x, y}
                    end
                )
            end
        )
        |> List.flatten()
        |> Enum.filter(fn {has, _, _} -> has end)
        |> Enum.map(fn {_, x, y} -> {x, y} end)
    end
    
    @doc """
    Flood oxygen through the maze until all available spaces are full. Return
    the number of steps that were required.
    """
    def oxygen_flood(maze_state, steps \\ 0) do
       
        draw_screen(maze_state)
        
       # find all locations that have oxygen
       has_oxygen = maze_state.maze |> find_index("O") 
       
       # map all of those locations to their neighbors that _don't_ have oxygen and aren't walls
       get_oxy_this_turn = has_oxygen
       
       # find locations without oxygen
       |> Enum.map(
           fn {oxy_x, oxy_y} -> 
               neighbors_without_oxygen(maze_state.maze, oxy_x, oxy_y)
           end
       )
       
       # flatten and deduplicate
       |> List.flatten()
       |> dedupe_all_points()
       
       # update all the points in the grid that get oxygen this turn
       new_maze = maze_state.maze |> put_all(get_oxy_this_turn, "O")
       
       # is our maze full?
       if count_grid(new_maze, ".") == 0 do
           steps + 1
       else
           oxygen_flood(%{maze_state | maze: new_maze}, steps + 1)
       end
    end
    
    def count_grid(grid, val) do
    
        grid.data
        |> List.flatten()
        |> Enum.filter(fn p -> p == val end)
        |> length()
    end
    
    def put_all(grid, [], _value), do: grid
    def put_all(grid, [{x, y} | points], value) do
        grid |> Grid.put_at(x, y, value) |> put_all(points, value)
    end
    
    def dedupe_all_points(point_list) do
       
       # turn the locations into a mapset
       point_list |> MapSet.new() |> MapSet.to_list() 
    end
    
    def neighbors_without_oxygen(maze, x, y) do
       [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}] 
       
       # find valid neighbors
       |> Enum.filter(
           fn {neighbor_x, neighbor_y} -> 
               maze |> Grid.valid_coordinate?(neighbor_x, neighbor_y)
           end
       )
       
       # check if they have oxygen or not
       |> Enum.filter(
           fn {neighbor_x, neighbor_y} -> 
               maze |> Grid.get_at(neighbor_x, neighbor_y) == "."
           end
       )
    end
        
    def depth_search(maze_state) do
    
        IO.puts("running depth search")
        
       # pick the starting point (always in %{x, y})
       root = maze_state.start
       
       # send to depth search
       {:found, [_start| route]} = depth_search(maze_state.maze, [], root)
       
       # filter results to only those returning "found" values 
       |> List.flatten()
       |> Enum.filter(fn {res, _route} -> res == :found end)
       |> Enum.min_by(fn {_res, route} -> length(route) end)
       
       route
    end
    
    def depth_search(maze, steps, step_to) do
       
       # is our step to a loop?
       cond do
           Enum.member?(steps, step_to) -> {:loop, steps ++ [step_to]}
           search_peek(maze, step_to) == "S" -> {:found, steps ++ [step_to]}
           true ->
               
               # walk the directions, and see what they return
               possible_moves = [:north, :south, :east, :west]
               |> Enum.filter(
                   fn heading -> 
                       search_peek(maze, step_to, heading) != "#"
                   end
               )
               
               if length(possible_moves) == 0 do
                   {:dead_end, steps ++ [step_to]}
               else
                   possible_moves
                   |> Enum.map(
                       fn heading -> 
                           depth_search(maze, steps ++ [step_to], search_step(maze, step_to, heading))
                       end
                   )
               end
               
       end
 
    end
    
    def search_peek(maze, location) do
        maze |> Grid.get_at(location.x, location.y)
    end
    
    def search_peek(maze, location, direction) do
       case direction do
          :north -> maze |> Grid.get_at(location.x, location.y - 1)
          :south -> maze |> Grid.get_at(location.x, location.y + 1)
          :west -> maze |> Grid.get_at(location.x - 1, location.y)
          :east -> maze |> Grid.get_at(location.x + 1, location.y)
       end 
    end
    
    def search_step(_maze, location, direction) do
        case direction do
           :north -> %{x: location.x, y: location.y - 1}
           :south -> %{x: location.x, y: location.y + 1}
           :west -> %{x: location.x - 1, y: location.y}
           :east -> %{x: location.x + 1, y: location.y}
        end         
    end
    
    def run_droid() do
        
        IO.ANSI.clear() |> IO.write()
        
        maze_state = create_maze_state(60, 50, run_for: 2600)
        
        # load our program and run it
        "data/day15/droid.ic"
        |> Intcode.program_from_file()
        
        # run the program
        |> Intcode.run(
            [
                memory_size: 8000,
                input_function: Intcode.send_for_input(self()),
                await_with: 
                    fn -> 
                        Intcode.await_io(maze_state, output_function: &handle_droid_output/2, output_count: 1, input_function: &handle_droid_input/1)
                    end
            ]
        )
        |> draw_screen()
    end
    
    def draw_screen(maze_state) do
        IO.ANSI.home() |> IO.write()
        
        0..maze_state.maze.height - 1
        |> Enum.each(
            fn y -> 
                0..maze_state.maze.width - 1
                |> Enum.each(
                    fn x -> 
                        cond do
                            droid_at?(maze_state.droid, x, y) -> "D"
                            start_at?(maze_state, x, y) -> "@"
                            true -> maze_state.maze |> Grid.get_at(x, y)
                        end
                        |> IO.write()
                    end
                )
                IO.write("\n")
            end
        )
        IO.puts("Cycles: #{maze_state.cycles}")
        maze_state
    end
    
    def droid_at?(droid, x, y) do
        (droid.x == x) and (droid.y == y)
    end
    
    def start_at?(maze, x, y) do
        (maze.start.x == x) && (maze.start.y == y)
    end
    
    @doc """
    Send an instruction to move in our current heading
    """
    def handle_droid_input(maze_state) do
        
        case maze_state.droid.heading do
            :north -> 1
            :south -> 2
            :east -> 4
            :west -> 3
        end
        
    end
    
    @doc """
    The droid is sending us data in response to moving. Let's figure out what's going
    on. The possible sensor outputs are:
    
        0: The repair droid hit a wall. Its position has not changed.
        1: The repair droid has moved one step in the requested direction.
        2: The repair droid has moved one step in the requested direction; its new position is the location of the oxygen system.
    
    
    """
    def handle_droid_output(maze_state, [sensor_output]) do
        
        draw_screen(maze_state)
        
       # first we update the maze data
       {task, state} = case sensor_output do
          0 ->
              # hit a wall
              {tx, ty} = move_target(maze_state)
              updated_maze = %{
                  maze: Grid.put_at(maze_state.maze, tx, ty, "#"),
                  start: maze_state.start,
                  droid: maze_state.droid,
                  cycles: maze_state.cycles + 1,
                  max_cycles: maze_state.max_cycles
              }
              
              # droid didn't move, we hit a wall. Mark the place we tried to move as a wall,
              # and determine where to turn. We bias to turn right, unless that's already a wall
              # and the area to our left is empty/unknown. 
              
              # if the tile to the right is empty, turn there. if left is empty, turn there, other
              # wise turn right
              right_tile = peek(updated_maze, :right)
              left_tile = peek(updated_maze, :left)
              new_heading = cond do
                  right_tile == " " -> turn_right(updated_maze.droid)
                  left_tile == " " -> turn_left(updated_maze.droid)
                  right_tile == "#" -> turn_left(updated_maze.droid)
                  true -> turn_left(updated_maze.droid)
              end
                            
              # droid didn't move. Mark the place we tried to move as a wall, and turn right 
              {
                  :continue,
                  %{ updated_maze | droid: Map.put(updated_maze.droid, :heading, new_heading)}
              }

          1 -> 
              # droid moved. Mark the place we moved as a path, update our location. Peek around, if the
              # tile to our right isn't a wall, follow it
              {tx, ty} = move_target(maze_state)
              updated_maze = %{
                  maze: Grid.put_at(maze_state.maze, tx, ty, "."),
                  start: maze_state.start,
                  droid: maze_state.droid |> Map.merge(%{x: tx, y: ty}),
                  cycles: maze_state.cycles + 1,
                  max_cycles: maze_state.max_cycles
              }
              
              right_tile = peek(updated_maze, :right)
              new_heading = if right_tile == "#" do
                  updated_maze.droid.heading
              else
                  turn_right(updated_maze.droid)
              end
              
              {
                  :continue,
                  %{updated_maze | droid: Map.put(updated_maze.droid, :heading, new_heading)}
              }

          2 ->
              # droid moved. Mark the place we moved as the end/oxygen sensor, update our location 
              {tx, ty} = move_target(maze_state)
              {
                  :continue,
                  %{
                      maze: Grid.put_at(maze_state.maze, tx, ty, "S"),
                      start: maze_state.start,
                      droid: maze_state.droid |> Map.merge(%{x: tx, y: ty}),
                      cycles: maze_state.cycles + 1,
                      max_cycles: maze_state.max_cycles
                  }
              }
       end 
       
       # do we need to stop? have we hit max cycles?
       if state.cycles >= state.max_cycles do
           {:halt, state}
       else
           {task, state}
       end
    end
    
    def peek(maze, direction) do
       look_heading = case direction do
           :left -> turn_left(maze.droid)
           :right -> turn_right(maze.droid)
       end
       
       {tx, ty} = move_target(maze, look_heading)
       maze.maze |> Grid.get_at(tx, ty)
    end
    
    def move_target(maze_state, heading) do
        x = maze_state.droid.x
        y = maze_state.droid.y
        
        case heading do
           :north -> {x, y - 1}
           :east -> {x + 1, y}
           :south -> {x, y + 1}
           :west -> {x - 1, y} 
        end
        
    end
    
    @doc """
    Given the state of the maze, to what location are we trying to move?
    """
    def move_target(maze_state) do
        move_target(maze_state, maze_state.droid.heading)        
    end
    
    @doc """
    Return the heading for turning the droid to the right
    """
    def turn_right(droid) do
       case droid.heading do
           :north -> :east
           :east -> :south
           :south -> :west
           :west -> :north
       end 
    end
    
    @doc """
    Return the heading for turning the droid to the left
    """
    def turn_left(droid) do
        case droid.heading do
            :north -> :west
            :east -> :north
            :south -> :east
            :west -> :south
        end         
    end
        
    @doc """
    our maze state will track what the repair droid has discovered so far, as
    mapped locations. We'll leverage the grid system from Chunky to track the
    data.
    
    As part of the game state, we have a known position and heading for the
    droid, as a tuple of {x, y, H} where H is one of `:north, :south, :east, :west`.
    
    """
    def create_maze_state(width, height, opts \\ []) do
        sx = Kernel.trunc(width / 2)
        sy = Kernel.trunc(height / 2)
        
        max_cycles = opts |> Keyword.get(:run_for, 2000)
        
       %{
           maze: Grid.new(width, height, " "),
           start: %{x: sx, y: sy},
           droid: %{x: sx, y: sy, heading: :north},
           cycles: 0,
           max_cycles: max_cycles
       } 
    end
    
end