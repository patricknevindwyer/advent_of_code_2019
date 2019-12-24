defmodule Aoc.Day24 do
    @moduledoc """
    Advent of Code 2019. Day 24. Problem 01/02.
    
    https://adventofcode.com/2019/day/24
    
    """ 
    
    alias Chunky.Grid
    
    def problem01 do
       "data/day24/problem_01.cells"
       |> find_repeating_automata()
       |> biodiversity_rating() 
    end
    
    def problem02 do
       "data/day24/problem_01.cells"
       |> recursive_grid_from_file()
       |> step_recursive_automata(200)
       |> count_bugs() 
    end
    
    def biodiversity_rating(%Grid{}=grid) do
        pows = [
            1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 
            2048, 4096, 8192, 16384, 32768, 65536, 131072, 
            262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216
        ]
        
        cells = grid.data |> List.flatten()
        
        Enum.zip(pows, cells)
        |> Enum.map(
            fn {p, c} -> 
                if c == "#" do
                    p
                else
                    0
                end
            end
        )
        |> Enum.sum()
    end
    
    def step_automata(grid) do
       stepped_points = grid
       |> map(
           fn g, x, y -> 
               
               # what is our state
               me = g |> Grid.get_at(x, y)
               
               # how many neighbors do we have?
               living_neighbors = g
               |> neighbors({x, y})
               |> Enum.filter(fn {_x, _y, v} -> v == "#" end)
               |> length()
               
               new_v = case {me, living_neighbors} do
                   {"#", 1} -> "#"
                   {"#", _} -> "."
                   {".", 2} -> "#"
                   {".", 1} -> "#"
                   {".", _} -> "."
               end
               
               {x, y, new_v}
           end
       ) 
       |> List.flatten()
       
       Grid.new(grid.width, grid.height, " ")
       |> Grid.put_all(stepped_points)
    end
    
    def recursive_grid_from_file(filename) do
       1..3
       |> Enum.map(
           fn idx -> 
               if idx == 2 do
                   file_to_grid(filename) 
                   |> Grid.put_at(2, 2, "?")
               else
                   Grid.new(5, 5, ".")
                   |> Grid.put_at(2, 2, "?")
               end
           end
       ) 
    end
    
    def count_bugs(grids) when is_list(grids) do
        
        grids
        |> Enum.map(fn grid -> grid.data |> List.flatten() end)
        |> List.flatten()
        |> Enum.filter(fn v -> v == "#" end)
        |> length()
    end
    
    def step_recursive_automata(grids, 0), do: grids
    def step_recursive_automata(grids, count) do
        grids |> step_recursive_automata() |> step_recursive_automata(count - 1)
    end
    
    def step_recursive_automata(grids) do
        
        # setup our null grids
        blank_grid = Grid.new(5, 5, ".")
        
        # bound the grids we want to step through
        bounded_grids = [blank_grid] ++ grids ++ [blank_grid]
        
        # now map all of our grids
        updated_grids = 1..length(grids)
        |> Enum.map(
            fn grid_idx -> 
                up_grid = bounded_grids |> Enum.at(grid_idx - 1)
                grid = bounded_grids |> Enum.at(grid_idx)
                down_grid = bounded_grids |> Enum.at(grid_idx + 1)
                
                step_automata(up_grid, grid, down_grid)
            end
        )
        
        # if our outer grids have any bugs, we need to add blanks to the top and bottom
        if count_bugs([Enum.at(updated_grids, 0)]) > 0 or count_bugs([Enum.at(updated_grids, length(updated_grids) - 1)]) > 0 do
            [Grid.new(5, 5, ".") |> Grid.put_at(2, 2, "?")] ++ updated_grids ++ [Grid.new(5, 5, ".") |> Grid.put_at(2, 2, "?")]
        else
            updated_grids
        end
    end
    
    @doc """
    Step a grid recursively - in the plutonian settlement recursive
    setup, each grid has a surrounding grid and a surrounded grid, the
    UP and DOWN respectively. These up and down grids provide neighbors
    to our current grid
    """
    def step_automata(up_grid, grid, down_grid) do
        stepped_points = grid
        |> map(
            fn g, x, y -> 
               
                # what is our state
                me = g |> Grid.get_at(x, y)
               
                # how many neighbors do we have?
                living_neighbors = neighbors(up_grid, grid, down_grid, {x, y})
                |> Enum.filter(fn {_x, _y, v} -> v == "#" end)
                |> length()
               
                new_v = case {me, living_neighbors} do
                    {"?", _} -> "?"
                    {"#", 1} -> "#"
                    {"#", _} -> "."
                    {".", 2} -> "#"
                    {".", 1} -> "#"
                    {".", _} -> "."
                end
               
                {x, y, new_v}
            end
        ) 
        |> List.flatten()
       
        Grid.new(grid.width, grid.height, " ")
        |> Grid.put_all(stepped_points)
    end
    
    def find_repeating_automata(filename) do
       
        file_to_grid(filename)
        |> step_until_repeat(MapSet.new())
        
    end
    
    def step_until_repeat(%Grid{}=grid, history) do
        h = hash(grid)
        
        if MapSet.member?(history, h) do
            grid
        else
            step_until_repeat(
                step_automata(grid),
                MapSet.put(history, h)
            )
        end
    end
    
    def hash(%Grid{}=g) do
       
       g.data
       |> List.flatten()
       |> Enum.join("")
        
    end
    
    def eq?(%Grid{}=grid_a, %Grid{}=grid_b) do
        grid_a.data == grid_b.data
    end
    
    def file_to_grid(filename) do
       filename
       |> File.read!()
       |> string_to_grid() 
    end
    
    def string_to_grid(grid_string) do
        
        # convert camera to string
        lines = grid_string |> String.split("\n") |> Enum.reject(fn line -> line |> String.trim() == "" end)
        
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

    def draw_grid(grid) do
        # IO.ANSI.home() |> IO.write()
        
        0..grid.height - 1
        |> Enum.each(
            fn y -> 
                0..grid.width - 1
                |> Enum.each(
                    fn x -> 
                        grid 
                        |> Grid.get_at(x, y)
                        |> IO.write()
                    end
                )
                IO.write("\n")
            end
        )
        grid
    end
    
    def map(%Grid{}=grid, map_func) when is_function(map_func) do
        
        0..grid.height - 1
        |> Enum.map(
            fn y -> 
                0..grid.width - 1
                |> Enum.map(
                    fn x -> 
                        map_func.(grid, x, y)
                    end
                )
            end
        )
    end
    
    def neighbors(%Grid{}=grid, {x, y}) do 
        [
            {x, y - 1}, 
            {x - 1, y},                 {x + 1, y},
            {x, y + 1}
        ]
        |> Enum.filter(fn coord -> Grid.valid_coordinate?(grid, coord) end)
        |> Enum.map(
            fn {x, y} -> 
                v = grid |> Grid.get_at(x, y)
                {x, y, v}
            end
        )
        
    end
    
    def neighbors(%Grid{}=up_grid, %Grid{}=grid, %Grid{}=down_grid, {x, y}) do
       
        # some tracking points for calcs later
        center = %{x: 2, y: 2}
        
        # get in grid neighbors
        in_neighbors = neighbors(grid, {x, y})
       
        # check up grid (at the edge)
        up_neighbors = cond do
            
            at_nw?(grid, {x, y}) -> 
                [
                    {center.x, center.y - 1},
                    {center.x - 1, center.y}
                ]
                
            at_ne?(grid, {x, y}) -> 
                [
                    {center.x, center.y - 1},
                    {center.x + 1, center.y}
                ]
                
            at_se?(grid, {x, y}) ->
                [
                    {center.x, center.y + 1},
                    {center.x + 1, center.y}
                ]
                
            at_sw?(grid, {x, y}) ->
                [
                    {center.x, center.y + 1},
                    {center.x - 1, center.y}
                ]
                
            at_n?(grid, {x, y}) ->
                [
                    {center.x, center.y - 1}
                ]
                
            at_s?(grid, {x, y}) ->
                [
                    {center.x, center.y + 1}
                ]
                
            at_w?(grid, {x, y}) ->
                [
                    {center.x - 1, center.y}
                ]
                
            at_e?(grid, {x, y}) ->
                [
                    {center.x + 1, center.y}
                ]
                
            true -> []
        end 
        |> Enum.map(
            fn {up_x, up_y} -> 
                up_v = up_grid |> Grid.get_at(up_x, up_y) 
                {up_x, up_y, up_v}
            end
        )
       
       # check down grid (? is neighbor)
       down_neighbors = cond do
           
           # down grid on our right
           Grid.valid_coordinate(grid, x + 1, y) && Grid.get_at(grid, x + 1, y) == "?" -> 
               [
                   {0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}
               ]
               
           # down grid on our left
           Grid.valid_coordinate(grid, x - 1, y) && Grid.get_at(grid, x - 1, y) == "?" -> 
               [
                   {4, 0}, {4, 1}, {4, 2}, {4, 3}, {4, 4}
               ]

           # down grid is above us
           Grid.valid_coordinate(grid, x, y - 1) && Grid.get_at(grid, x, y - 1) == "?" -> 
               [
                   {0, 4}, {1, 4}, {2, 4}, {3, 4}, {4, 4}
               ]

           # down grid is below us
           Grid.valid_coordinate(grid, x, y + 1) && Grid.get_at(grid, x, y + 1) == "?" -> 
               [
                   {0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}
               ]
               
           true -> []
           
       end
       |> Enum.map(
           fn {down_x, down_y} -> 
               down_v = down_grid |> Grid.get_at(down_x, down_y)
               {down_x, down_y, down_v}
           end
       )
       
       in_neighbors ++ up_neighbors ++ down_neighbors
    end
    
    def at_nw?(%Grid{}=_grid, {x, y}) do
        x == 0 and y == 0
    end
    
    def at_ne?(%Grid{}=grid, {x, y}) do
        y == 0 && x == grid.width - 1
    end
    
    def at_sw?(%Grid{}=grid, {x, y}) do
        x == 0 && y == grid.height - 1
    end
    
    def at_se?(%Grid{}=grid, {x, y}) do
        x == grid.width - 1 && y == grid.height - 1
    end
    
    def at_n?(%Grid{}=grid, {x, y}) do
        y == 0 && !at_nw?(grid, {x, y}) && !at_ne?(grid, {x, y})
    end
        
    def at_s?(%Grid{}=grid, {x, y}) do
        y == grid.height - 1 && !at_sw?(grid, {x, y}) && !at_se?(grid, {x, y})
    end
    
    def at_w?(%Grid{}=grid, {x, y}) do
        x == 0 && !at_nw?(grid, {x, y}) && !at_sw?(grid, {x, y})
    end
    
    def at_e?(%Grid{}=grid, {x, y}) do
        x == grid.width - 1 && !at_ne?(grid, {x, y}) && !at_se?(grid, {x, y})        
    end

end