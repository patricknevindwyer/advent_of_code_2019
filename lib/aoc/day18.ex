defmodule Aoc.Day18 do
    @moduledoc """
    Advent of Code 2019. Day 18. Problem 01/02.
    
    https://adventofcode.com/2019/day/18
    
    """ 
    
    alias Chunky.Grid

    def problem01 do
        maze = solve_keys("data/day18/problem_01.map")
        
        IO.puts("Shortest path is #{length(maze.steps)}")
    end
        
    def solve_keys(map_filename) when is_binary(map_filename) do
        map_filename
        |> File.read!()
        |> create_maze()
        |> solve_keys()
    end
    
    def solve_keys(maze) do
        
        route_search(maze)
        |> List.flatten()
        |> Enum.min_by(fn solution -> length(solution.steps) end)

    end
    
    # Breadth search
    # - at given depth level - check all immediate leafs of all available current routes
    # - if any leaf is a route, return
    # - in no leaf is a route, build next layer of all available routes, repeat
    # 
    # - carry with the steps so far, and the graph alterations so far (basically rebuild at each step)
    
    @doc """
    steps list is a list of points within the maze that have been visited as
    terminal points from the starting point, along with a path length up to
    that point. So, for instance, one of the step items might be:
    
        %{path: ["a", "b"], last_location: {x, y}, total_size: 33}
    
    That item from the steps_list indicates that the given path has visited the
    `a` and `e` nodes, with the last visited location being at `{x, y}`, for a total path 
    length of 33.
    """
    def breadth_search(maze_filename) when is_binary(maze_filename) do
        maze = maze_filename
        |> File.read!()
        |> create_maze()
        
        # translate letter locations into actual letters
        letters = maze.letters
        |> Enum.map(fn loc -> maze.maze |> Grid.get_at(loc) end)
        
        %{maze | letters: letters}
        |> breadth_search()
    end
    
    def breadth_search(maze) do
            
        # find our first steps
        start_location = maze.maze |> Grid.find_index("@") |> List.first()
        maze = Map.put(maze, :cache, %{})
        breadth_search(maze, next_steps(maze, %{path: [], last_location: start_location, total_length: 0}))
    end
    
    @doc """
    Maze cache keeps a map of distances from location to location, by grid location
    """
    def build_distance_cache(maze, cache=%{}) do
       
        # what letters still exists, and where are they
        locations = maze.letters
        |> Enum.map(fn letter -> maze.maze |> Grid.find_index(letter) |> List.first() end)
        
        IO.puts("cache size pre-evict: #{map_size(cache)}")
        # remove anything from the cache that's not still in the maze
        cache = cache
        |> Enum.filter(
            fn {from, to} -> 
                case {Enum.member?(locations, from), Enum.member?(locations, to)} do
                    {true, true} -> true
                    _ -> false
                end
            end
        ) |> Map.new()

        IO.puts("cache size post-evict: #{map_size(cache)}")
       
        # for all combos still in maze, build distances
        new_locs = locations
        |> Enum.map(
            fn loc_a -> 
                
                locations
                |> Enum.map(
                    fn loc_b -> 
                        
                        cond do
                           loc_a == loc_b -> {:skip, 0}
                           cache |> Map.has_key?({loc_a, loc_b}) -> {:skip, 0}
                           true ->
                               # try an find a path
                               case depth_search(maze, loc_b, loc_a) do
                                  {:found, route} -> {:found, {loc_a, loc_b, route} }
                                  _ -> {:skip, 0}
                               end
                           
                        end
                    end
                )
            end
        )
        |> List.flatten()
        |> Enum.filter(fn {res, _size} -> res == :found end)
        |> Enum.map(fn {_res, route} -> route end)
        |> Map.new(fn {loc_a, loc_b, size} -> {{loc_a, loc_b}, size} end)
        
        Map.merge(cache, new_locs)
    end
    
    def breadth_search(maze, steps_lists) do
        
        # update the distance cache
        maze = %{maze | cache: build_distance_cache(maze, maze.cache)}
        
        # check if any of our steps lists items has visited all of the nodes
        # if so, we find all step lists that have visited enough, and we return
        # the shortest
        finishers = steps_lists
        |> Enum.filter(
            fn steps -> 
                length(steps.path) == length(maze.letters)
            end
        )
        
        if length(finishers) > 0 do
            
           # we have some winners. Sort by path, return the shortest
           finishers |> Enum.min_by(fn steps -> steps.total_length end)
           
        else
           
           # no winners, we continue the process, for each of the steps
           # in steps_list, we calculate all the next possible valid steps,
           # use those as our new steps_list, and continue
           new_steps_lists = steps_lists
           |> Enum.map(
               fn steps -> 
                   next_steps(maze, steps)
               end
           )
           |> List.flatten()
           
           IO.puts("breadth: #{length(new_steps_lists)}")
           breadth_search(maze, new_steps_lists)
        end
    end
    
    @doc """
    Given the base maze and a list of steps, build out the valid move sets,
    and return new step list objects:
        
        %{path: ["a", "e", "g"], last_location: {x, y}, total_length: 44}
    
    """
    def next_steps(maze, steps) when is_map(steps) do
    
        # build a cleaned up maze, where we need to
        #   1. let the maze.location
        #   2. remove the origin location marker
        #   3. remove the keys an doors for any steps taken so far
        clean_maze = maze |> update_maze(steps.path, steps.last_location)

        # then we need to loop through all of the still available
        # letter targets to find valid paths, which return either {:no_route, []}
        # or {:found, path}
        clean_maze.letters -- steps.path
        |> Enum.map(
            fn remaining_letter ->                 
                                
                # where is the target letter
                target = clean_maze.maze |> Grid.find_index(remaining_letter) |> List.first()
                
                if Map.has_key?(clean_maze.cache, {clean_maze.location, target}) do
                    {:found, Map.get(clean_maze.cache, {clean_maze.location, target})}
                else
                    # find a path
                    depth_search(clean_maze, target)                    
                end
                
            end
        )
        
        # filter down to only routes that have a path, and extract the route
        |> Enum.filter(fn {res, _route} -> res == :found end)
        |> Enum.map(fn {_res, route} -> route end)
        
        # now update the steps to create new ones
        |> Enum.map(
            fn route -> 
                
                # what letter is at this route target?
                last_location = route |> List.last()
                found_letter = clean_maze.maze |> Grid.get_at(last_location)
                
                %{
                    steps |
                    path: steps.path ++ [found_letter],
                    last_location: last_location,
                    total_length: steps.total_length + (length(route) - 1)
                }
                
                
            end
        )
        
    end
    
    @doc """
    Clean up the maze state for passing to a new search.
    """
    def update_maze(maze, removal_letters, search_position) do
       
        # create a list of points to update
        letter_updates = removal_letters
        |> Enum.map(
            fn lower_letter -> 
                
                # lower letter
                lower_position = case maze.maze |> Grid.find_index(lower_letter) do
                    [] -> []
                    [{ll_x, ll_y}] -> [{ll_x, ll_y, "."}]
                end
                
                # upper letter
                upper_letter = lower_letter |> String.upcase()
                upper_position = case maze.maze |> Grid.find_index(upper_letter) do
                   [] -> []
                   [{ul_x, ul_y}] -> [{ul_x, ul_y, "."}]
                end
                
                lower_position ++ upper_position
            end
        )
        |> List.flatten()
        
        # add the origin to letter updates
        {o_x, o_y} = maze.location
        
        %{
            maze |
            maze: maze.maze |> Grid.put_all(letter_updates ++ [{o_x, o_y, "."}]),
            location: search_position
        }
    end
    
    def route_search(maze) do
        
        # find locations of available keys
        letter_routes = maze.letters
        |> Enum.map(
            fn letter -> 
                depth_search(maze, letter)
            end
        )
        |> Enum.filter(fn {res, _route} -> res == :found end)
        |> Enum.map(fn {_res, route} -> route end)
        
        # heuristic - this is functionally a traveling salesman problem, we
        # can't brute force it for any decently complex map - we need to 
        # prune our search space. We'll take:
        #
        #   - all routes if there are less than 4
        #   - two shortest and one longest if there are more than 4
        letter_routes = if length(letter_routes) < 4 do
            letter_routes
        else
            sorted_routes = letter_routes 
            |> Enum.sort_by(fn r -> length(r) end)
            
            Enum.take(sorted_routes, 1) ++ [List.last(sorted_routes)]
        end
        
        # for every letter route, find all possible sub routes
        letter_routes
        |> Enum.map(
            fn route -> 
                
                # drop the first position in our route - we're already there
                route = route |> Enum.drop(1)
                
                # update our maze with
                #  - x new position for ourself
                #  - x set our old position to a dot
                #  - x remove lower case and upper case letter
                #  - x add to found_letters
                #  - x remove from letters
                #  - x add steps for route
                
                # where will we be?
                {target_x, target_y} = final_position = route |> List.last()
                
                # what letter are we removing? where?
                lower_letter = maze.maze |> Grid.get_at(final_position)
                upper_letter = lower_letter |> String.upcase()
                upper_letter_updates = case maze.maze |> Grid.find_index(upper_letter) do
                   [] -> []
                   [{ul_x, ul_y}] -> [{ul_x, ul_y, "."}]
                end
                
                # what is our current location?
                {my_x, my_y} = maze.location
                
                # what grid updates do we need?
                grid_updates = [{my_x, my_y, "."}, {target_x, target_y, "@"}] ++ upper_letter_updates
                
                updated_maze = %{
                    maze |
                    location: final_position,
                    maze: maze.maze |> Grid.put_all(grid_updates),
                    found_letters: maze.found_letters ++ [{target_x, target_y, lower_letter}],
                    letters: maze.letters |> List.delete({target_x, target_y}),
                    steps: maze.steps ++ route
                }
                
                # do we need to keep searching?
                if length(updated_maze.letters) == 0 do
                    [updated_maze]
                else
                    route_search(updated_maze)
                end
            end
        )
    end
    
    
    
    @doc """
    Search through the maze for a target location point.
    
    ## Example
    
        iex> depth_search(%{}, {5, 3})
    """
    def depth_search(maze_state, target, start_at \\ nil) do

       # pick the starting point (always in {x, y})
       root = if start_at == nil do
           maze_state.location
       else
           start_at
       end
       
       # send to depth search
       search_result = depth_search(maze_state.maze, target, [], root)
       
       # filter results to only those returning "found" values 
       |> List.flatten()
       |> Enum.filter(fn {res, _route} -> res == :found end)
       
       case search_result do
           [] -> {:no_route, []}
           routes -> 
              routes |> Enum.min_by(fn {_res, route} -> length(route) end)
              
       end
    end
    
    def depth_search(maze, target, steps, step_to) do
       
       # is our step to a loop?
       cond do
           length(steps) > 200 -> {:too_long, []}
           Enum.member?(steps, step_to) -> {:loop, steps ++ [step_to]}
           step_to == target -> {:found, steps ++ [step_to]}
           true ->
               
               # walk the directions, and see what they return
               possible_moves = [:north, :south, :east, :west]
               |> Enum.filter(
                   fn heading -> 
                       # search_peek(maze, step_to, heading) == "."
                       cond do
                          search_step(maze, step_to, heading) == target -> true
                          search_peek(maze, step_to, heading) == "." -> true
                          true -> false
                       end
                       # case search_peek(maze, step_to, heading) do
                       #    # "#" -> false
                       #    "." -> true
                       #    let -> is_lowercase?(let)
                       #    _ -> false
                       # end
                   end
               )
               
               if length(possible_moves) == 0 do
                   {:dead_end, steps ++ [step_to]}
               else
                   possible_moves
                   |> Enum.map(
                       fn heading -> 
                           depth_search(maze, target, steps ++ [step_to], search_step(maze, step_to, heading))
                       end
                   )
               end
               
       end
 
    end
    
    def search_peek(maze, {x, y}) do
        maze |> Grid.get_at(x, y)
    end
    
    def search_peek(maze, {x, y}, direction) do
       case direction do
          :north -> maze |> Grid.get_at(x, y - 1)
          :south -> maze |> Grid.get_at(x, y + 1)
          :west -> maze |> Grid.get_at(x - 1, y)
          :east -> maze |> Grid.get_at(x + 1, y)
       end 
    end
    
    def search_step(_maze, {x, y}, direction) do
        case direction do
           :north -> {x, y - 1}
           :south -> {x, y + 1}
           :west -> {x - 1, y}
           :east -> {x + 1, y}
        end         
    end
    
    def create_maze(maze_string) do
        
        # parse maze strings
        maze = maze_to_grid(maze_string)
        
        # run letter locator (lower case)
        # locate self
        # track found letters
        # tracking remaining letters
        
       %{
           maze: maze,
           location: Grid.find_index(maze, "@") |> List.first(),
           found_letters: [],
           letters: locate_letters(maze, maze_string),
           steps: []
       } 
    end
    
    @doc """
    Find all of our initial lower case letters, returning their grid points
    """
    def locate_letters(maze, maze_string) do
        
        maze_string
        |> string_to_list()
        |> Enum.reject(fn letter -> Enum.member?(["#", ".", "@", "\n"], letter) end)
        |> Enum.filter(&is_lowercase?/1)
        |> Enum.map(fn letter -> Grid.find_index(maze, letter) |> List.first() end)
        
    end
    
    defp is_lowercase?(letter) do
        letter == String.downcase(letter)
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

end