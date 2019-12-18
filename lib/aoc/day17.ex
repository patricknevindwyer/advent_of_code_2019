defmodule Aoc.Day17 do
    @moduledoc """
    Advent of Code 2019. Day 17. Problem 01/02.
    
    https://adventofcode.com/2019/day/15
    
    """ 
    
    alias Aoc.Intcode
    alias Chunky.Grid
    
    def problem02 do
        
        ascii_state = create_ascii_state(
            %{
                main: "A,A,B,C,C,A,C,B,C,B",
                a: "L,4,L,4,L,6,R,10,L,6",
                b: "L,12,L,6,R,10,L,6",
                c: "R,8,R,10,L,6"
            },
            camera_width: 46,
            camera_height: 35,
            continuous: false    
        )
        |> run_droid()
        
        IO.puts("Dust: #{ascii_state.dust}")
        ascii_state
    end
    
    def problem01 do
        
        ascii_state = create_ascii_state() |> run_droid()
        
        grid = camera_to_grid(ascii_state.camera)
        |> draw()
        
        inters = grid
        |> find_intersections()
        
        aps = inters
        |> Enum.map(fn {x, y, _v} -> x * y end)
        |> Enum.sum()
        
        IO.puts("found #{length(inters)} intersections")
        IO.puts("alignment parameter sum: #{aps}")


    end
    
    
    def run_droid(ascii_state) do
        
        # IO.ANSI.clear() |> IO.write()
        

        # load our program and run it
        program = "data/day17/ascii.ic"
        |> Intcode.program_from_file()
            
        # are we rewriting part of our program?
        program = if length(ascii_state.program) > 0 do
            Intcode.memory_write(program, 0, 2)
        else 
            program
        end
        
        program
        # run the program
        |> Intcode.run(
            [
                memory_size: 6000,
                input_function: Intcode.send_for_input(self()),
                await_with: 
                    fn -> 
                        Intcode.await_io(ascii_state, output_function: &handle_ascii_output/2, output_count: 1, input_function: &handle_ascii_input/1)
                    end
            ]
        )
    end
    
    @doc """
    Create an empty ASCII state computer with no input programs
    """
    def create_ascii_state() do
        %{
            camera: [],
            program: [],
            dust: 0
        }
    end
    
    @doc """
    Create a ASCII state computer with input programs.
    
    """
    def create_ascii_state(%{}=program_data, opts \\ []) do
        
        # queue up the program data
        program = [:main, :a, :b, :c]
        |> Enum.map(
            fn prog_key -> 
                
                # reformat the program data from simple strings into something more sensible.
                reprog = program_data 
                |> Map.get(prog_key, "")
                |> String.to_charlist()
                
                reprog ++ String.to_charlist("\n")
            end
        )
        |> List.flatten()
        
        # are we running in streaming video mode?
        program = if Keyword.get(opts, :continuous, false) do
            program ++ String.to_charlist("y\n")
        else 
            program ++ String.to_charlist("n\n")
        end
        
        # check for a known width/height of our camera data
        camera_width = opts |> Keyword.get(:camera_width, 0)
        camera_height = opts |> Keyword.get(:camera_height, 0)
        
       %{
           camera: [],
           program: program,
           dust: 0,
           camera_width: camera_width,
           camera_height: camera_height
       } 
    end
    
    @doc """
    convert camera data into grid data.
    """
    def camera_to_grid(camera) do
        
        # convert camera to string
        lines = camera |> to_string() |> String.split("\n") |> Enum.reject(fn line -> line |> String.trim() == "" end)
        
        # determine our grid size and initialize the grid
        height = length(lines)
        width = lines |> List.first() |> String.length()
        
        # IO.puts("camera(#{width}, #{height})")
        # IO.inspect(lines)
        
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
        grid |> put_all(grid_points)
        
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
    
    @doc """
    Find any loops/intersections in the generated map. From visual inspection, there are
    no loops at the edge of the map (there would be no way to tell where the loop point was),
    so we look for every grid point that has a corridor, and check it's cardinal neighbors. If
    all four neighbors are also corridors, we're at a loop point.
    
    Return a list of all such points.
    """
    def find_intersections(%Grid{}=grid) do
        
        # walk through our grid, checking every grid point
        grid
        |> filter(
            fn {x, y, value} -> 
                
                cond do
                    
                    # not part of the line
                    value != "#" -> false
                    
                    # edges don't have loops
                    at_edge?(grid, x, y) -> false
                    
                    # we're on the line, not on an edge
                    true -> 
                        
                        # check our neighbors, if all four are #, we're in a loop
                        grid
                        |> cardinal_neighbors(x, y)
                        |> Enum.filter(
                            fn {card_x, card_y} -> 
                                grid |> Grid.get_at(card_x, card_y) == "#"
                            end
                        )
                        |> length() == 4
                end
            end
        )
        
    end
    
    @doc """
    Enum.filter/2 for working with a Grid.
    """
    def filter(%Grid{}=grid, func) when is_function(func, 1) do
        
        0..grid.height - 1
        |> Enum.map(
            fn y -> 
                0..grid.width - 1
                |> Enum.map(
                    fn x -> 
                        {x, y, grid |> Grid.get_at(x, y)}
                    end
                )
            end
        )
        |> List.flatten()
        |> Enum.filter(fn coord_with_value -> func.(coord_with_value) end)
        
    end
    
    @doc """
    Find valid cardinal neighbor points for a location in the grid.
    """
    def cardinal_neighbors(%Grid{}=grid, x, y) do
       [ {x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}] 
       |> Enum.filter(fn coord -> grid |> Grid.valid_coordinate?(coord) end)
    end
    
    def at_edge?(%Grid{}=grid, x, y) do
       cond do
          x == 0 -> true
          y == 0 -> true
          x == (grid.width - 1) -> true
          y == (grid.height - 1) -> true
          true -> false
       end 
    end
    
    @doc """
    Add a list of point data to a grid. Points can be specified as `{x, y, value}` tuples
    or as maps of `%{x: x, y: y, value: value}`.
    
    ## Example
    
        iex> Grid.new(10, 10) |> put_all([ {1, 1, "#"}, {3, 2, "."}, ...])
    """
    def put_all(%Grid{}=grid, [datum]) do
        case datum do
           {x, y, val} -> grid |> Grid.put_at(x, y, val)
           %{x: x, y: y, value: val} ->  grid |> Grid.put_at(x, y, val)
        end
     end
     
    def put_all(%Grid{}=grid, [datum | data]) do
        case datum do
           {x, y, val} -> grid |> Grid.put_at(x, y, val) |> put_all(data)
           %{x: x, y: y, value: val} ->  grid |> Grid.put_at(x, y, val) |> put_all(data)
        end            
    end
    
    
    @doc """
    await_io handlers
    """
    def handle_ascii_input(ascii_state) do

        # grab a value from our queue
        {iv, program_queue} = ascii_state.program |> List.pop_at(0)
        
        # print and clear any output state (like message prompts)
        # IO.puts(ascii_state.camera)
        
        
        # send a value from our program
        {
            iv,
            %{ascii_state | program: program_queue, camera: []}
        }
                
    end
    
    @doc """
    """
    def handle_ascii_output(ascii_state, [camera_output]) do
        
        # if our camera state is large enough, we need to print out the
        # camera, and dump, in order to support continuous map mode.
        
        # if the value is large than 128, that's our final output
        ascii_state_next = if camera_output > 128 do
            Map.put(ascii_state, :dust, camera_output)
        else
            n_state = %{ascii_state | camera: ascii_state.camera ++ [camera_output]}
            
            # if there is no camera width defined, we're in problem one
            if Map.has_key?(ascii_state, :camera_width) do
                if (camera_output == 10) && (length(n_state.camera) >= (ascii_state.camera_width * ascii_state.camera_height)) do
                    # camera is full
                    n_state.camera
                    |> camera_to_grid()
                    |> draw()
                    # IO.puts("did camera draw")
                    %{n_state | camera: []}
                else
                    n_state
                end
            else
               n_state 
            end
            
        end
        {:continue, ascii_state_next}

    end
    
    @doc """
    Draw the grid.
    """
    def draw(%Grid{}=grid) do
        IO.ANSI.home() |> IO.write()
        
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
end