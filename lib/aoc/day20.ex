defmodule Aoc.Day20 do
    @moduledoc """
    Advent of Code 2019. Day 20. Problem 01/02.
    
    https://adventofcode.com/2019/day/20
    
    """ 
    
    alias Chunky.Grid
    import Astar
    
    def problem01 do
        "data/day20/problem_01.map"
        |> astar_search()
        |> length()
    end
    
    def problem02 do
        "data/day20/problem_01.map"
        |> astar_search_recursive_map()
        |> length()        
    end
    
    def create_maze(maze_string, recursive \\ false) do
        
        # parse maze strings
        maze = maze_to_grid(maze_string)
        
        # get the start and warps
        %{start: start, finish: finish, warps: warps} = find_warps(maze)
        
        %{
            maze: maze,
            location: start,
            finish: finish,
            start: start,
            steps: [],
            warps: warps,
            recursive: recursive
       } 
    end
    
    @doc """
    Find all of the warp points in the map, returning a dictionary of point
    maps and a starting point and end point.
    
    ## Example
    
        iex> find_warps(grid)
        %{warps: %{ {3, 3} => {7, 11}, {7, 11} => {3, 3], ...}, start: {9, 1}, finish: {20, 3} }
    """
    def find_warps(maze_grid) do
        
        # scan for points on the grid, and then look for adjacent letters
        warp_points = 0..maze_grid.height - 1
        |> Enum.map(
            fn y -> 
                0..maze_grid.width - 1
                |> Enum.map(
                    fn x -> 

                        # we're walking every X,Y point on the map
                        if maze_grid |> Grid.get_at(x, y) == "." do
                            # now check around us for a letter
                            [:north, :south, :east, :west]
                            |> Enum.map(
                                fn heading -> 
                                    
                                    if search_peek(maze_grid, %{x: x, y: y}, heading) |> is_letter?() do
                                        
                                        # we have a warp point! what's our other letter?
                                        let_a = search_peek(maze_grid, %{x: x, y: y}, heading)
                                        let_b = search_peek(maze_grid, search_step(maze_grid, %{x: x, y: y}, heading), heading)
                                        
                                        # the name of this warp point depends on heading
                                        warp_name = case heading do
                                            :north -> "#{let_b}#{let_a}"
                                            :south -> "#{let_a}#{let_b}"
                                            :east -> "#{let_a}#{let_b}"
                                            :west -> "#{let_b}#{let_a}"
                                        end
                                        
                                        {:warp, %{x: x, y: y}, warp_name}
                                    else
                                        :no_warp 
                                    end
                                end
                            )
                            
                        else
                            [:no_warp]
                        end
                    end
                )
            end 
        )
        
        # we have a list of [:no_warp, {:warp, {x, y}, name}, ....] so flatten and filter it
        |> List.flatten()
        |> Enum.filter(
            fn warps -> 
                case warps do
                    
                    :no_warp -> false
                    _ -> true
                end
            end
        )
        
        # now with a list of warps, we want to extract the starting point
        start_index = warp_points |> Enum.find_index(fn {:warp, _point, name} -> name == "AA" end)
        {:warp, start, "AA"} = warp_points |> Enum.at(start_index)
        warp_points = warp_points |> List.delete_at(start_index)

        end_index = warp_points |> Enum.find_index(fn {:warp, _point, name} -> name == "ZZ" end)
        {:warp, end_point, "ZZ"} = warp_points |> Enum.at(end_index)
        warp_points = warp_points |> List.delete_at(end_index)
        
        # now we need to group/partition our points by name
        warps = warp_points |> Enum.group_by(fn {:warp, _point, name} -> name end)
        
        # and convert the warp point results to a bi directional map of points
        warps = warps
        |> Enum.map(
            fn {_name, [{:warp, point_a, _}, {:warp, point_b, _}]} -> 
                [
                    {point_a, point_b},
                    {point_b, point_a}
                ]
            end
        )
        |> List.flatten()
        |> Map.new()
        
        %{
            warps: warps,
            start: start |> Map.put(:level, 0),
            finish: end_point |> Map.put(:level, 0)
        }
        
    end
    
    def is_letter?(str) when is_binary(str) do
        String.contains?("ABCDEFGHIJKLMNOPQRSTUVWXYZ", str)
    end
    
    def maze_to_grid(maze_string) do
        
        # convert camera to string
        lines = maze_string |> String.split("\n") |> Enum.reject(fn line -> line |> String.trim() == "" end)
        
        # determine our grid size and initialize the grid
        height = length(lines)
        width = lines |> List.first() |> String.length()
                
        grid = Grid.new(width, height, " ")
        
        # map our camera data to grid points
        grid_points = lines
        |> Enum.with_index()
        |> Enum.map(
            fn {line, y} -> 
                
                line
                |> string_to_list()
                |> Enum.with_index()
                |> Enum.map(fn {point, x} -> {x, y, point} end)
                
            end
        ) |> List.flatten()
        
        # now add all the points to the grid
        grid |> Grid.put_all(grid_points)
        
    end

    @doc """
    Convert a string to a list of strings, one for each grapheme cluster. This is different
    from String.to_charlist/1, as this preserves multi-codepoint glyphs.
    """
    def string_to_list(s) when is_binary(s) do
        s
        |> String.split("")
        |> Enum.slice(1..String.length(s))
    end 

    def draw_maze(maze_state) do
        # IO.ANSI.home() |> IO.write()
        
        0..maze_state.maze.height - 1
        |> Enum.each(
            fn y -> 
                0..maze_state.maze.width - 1
                |> Enum.each(
                    fn x -> 
                        maze_state.maze 
                        |> Grid.get_at(x, y)
                        |> IO.write()
                    end
                )
                IO.write("\n")
            end
        )
        maze_state
    end
    
    def astar_search_recursive_map(map_filename) when is_binary(map_filename) do
        map_filename
        |> File.read!()
        |> create_maze(true)
        |> astar_search()
    end
    
    def astar_search(map_filename) when is_binary(map_filename) do
        map_filename
        |> File.read!()
        |> create_maze()
        |> astar_search()
    end
    
    def astar_search(maze_state) when is_map(maze_state) do
        
        astar(
            {
                fn vert ->
                    astar_steps(maze_state, vert)
                end,
                fn _a, _b -> 1 end,
                # fn a, b -> :math.sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)) end
                fn _a, _b -> 1 end
            },
            maze_state.start,
            maze_state.finish    
        )
    end
    
    def astar_steps(maze_state, vertex) do

        # walk the directions, and see what they return
        [:north, :south, :east, :west, :warp]
        |> Enum.filter(
            fn heading ->
                search_peek(maze_state, vertex, heading) != "#"                
            end
        )
        |> Enum.map(
            fn heading -> 
                search_step(maze_state, vertex, heading)
            end
        )
        
    end
    
    @doc """
    Look at the location in the maze grid at a particular location, either at
    a specific point, or in a direction from the current point (north, south, east,
    west, or warp)
    """
    def search_peek(maze, %{}=location) do
        maze |> Grid.get_at(location.x, location.y)
    end
    
    def search_peek(maze, {x, y}) do
        maze |> Grid.get_at(x, y)
    end

    def search_peek(%Grid{}=maze, location, direction) do
       case direction do
          :north -> maze |> Grid.get_at(location.x, location.y - 1)
          :south -> maze |> Grid.get_at(location.x, location.y + 1)
          :west -> maze |> Grid.get_at(location.x - 1, location.y)
          :east -> maze |> Grid.get_at(location.x + 1, location.y)
       end 
    end
    
    
    def search_peek(maze, location, direction) do
       val = case direction do
          :north -> maze.maze |> Grid.get_at(location.x, location.y - 1)
          :south -> maze.maze |> Grid.get_at(location.x, location.y + 1)
          :west -> maze.maze |> Grid.get_at(location.x - 1, location.y)
          :east -> maze.maze |> Grid.get_at(location.x + 1, location.y)
          :warp -> 
              
              # check the warp level - if we're at level 0, the outer warps are walls
              # this function returns open area vs wall - if this is a warp tile,
              # return a walkable area
              if maze.recursive do
                  if location.level == 0 do
                      # outer level
                      if Map.has_key?(maze.warps, %{x: location.x, y: location.y}) do
                          # are we near the edge?
                          if (location.x == 2) or (location.y == 2) or (location.x == maze.maze.width - 3) or (location.y == maze.maze.height - 3) do
                              # if the warp is ZZ, it's value
                              if Map.get(maze.warps, %{x: location.x, y: location.y}) == "ZZ" do
                                  "."
                              else
                                  "#"
                              end

                          else
                              "."
                          end
                      else
                          # no warp
                         "#" 
                      end
                  else
                      # recursive level
                      if Map.has_key?(maze.warps, %{x: location.x, y: location.y}) do
                          # if the warp is AA or ZZ it isn't valid
                          case Map.get(maze.warps, %{x: location.x, y: location.y}) do
                              "AA" -> "#"
                              "ZZ" -> "#"
                              _ -> "."
                          end
                      else
                          "#"
                      end                  
                  end
              else 
                  if Map.has_key?(maze.warps, %{x: location.x, y: location.y}) do
                      "."
                  else
                      "#"
                  end                  
              end
       end 
       
       case val do
           "#" -> "#"
           "." -> "."
           _ -> "#"
       end
    end
    
    @doc """
    Determine the coordinates of the directional step from the current location
    """
    def search_step(maze, location, direction) do

        current_level = Map.get(location, :level, 0)
        
        case direction do
            
           :north -> %{x: location.x, y: location.y - 1, level: current_level}
           :south -> %{x: location.x, y: location.y + 1, level: current_level}
           :west -> %{x: location.x - 1, y: location.y, level: current_level}
           :east -> %{x: location.x + 1, y: location.y, level: current_level}
           :warp ->

               if maze.recursive do
                   # does this walk up or down the level of recursion?
                   level_mod = if (location.x == 2) or (location.y == 2) or (location.x == maze.maze.width - 3) or (location.y == maze.maze.height - 3) do
                       -1
                   else
                       1
                   end
                   Map.get(maze.warps, %{x: location.x, y: location.y}) |> Map.put(:level, current_level + level_mod)
               else
                   # map isn't recursive
                   Map.get(maze.warps, %{x: location.x, y: location.y}) |> Map.put(:level, current_level)
               end
        end         
    end
    

end