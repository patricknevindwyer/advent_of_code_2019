defmodule Aoc.Day19 do
    @moduledoc """
    Advent of Code 2019. Day 19. Problem 01/02.
    
    https://adventofcode.com/2019/day/19
    
    """ 
    
    alias Aoc.Intcode
    alias Chunky.Grid

    def problem_01 do
       Aoc.Day19.scan_area().outputs 
       |> Enum.sum() 
    end
    
    def problem_02 do
        {x, y} = find_first_fit(100)
        (x * 10000) + y
    end
    
    @doc """
    Find the first location (x, y top left coordinate) that will fit
    a square of the given size within the tractor beam. 
    
    What we're looking for:
    
     - row at least size wide, with left coordinate of x_a
     - where (row-size) has a right coordinate in the beam at x_a + size
    """
    def find_first_fit(size, start_hint \\ 20) do
        find_first_fit(size - 1, start_hint, start_hint + size - 1)
    end
    
    def find_first_fit(size, top_row, bottom_row) do
        
       # check the row coordinates
       {{_tl_x, _}, {tr_x, _}} = beam_at_row(top_row)
       {{bl_x, _}, {br_x, _}} = beam_at_row(bottom_row)

       IO.puts("checking row(#{bottom_row}) width(#{br_x - bl_x})")
       
       # does the bottom fit?
       if br_x - bl_x > Kernel.trunc(size * 1.3) do

           # does the top right fit?
           if tr_x >= (bl_x + size) do
               # we fit - our top left coordinate is in teh top row, athe bottom left x
               {bl_x, top_row}
           else
               IO.puts("\toverage(#{bl_x + size - tr_x})")
               
               overage = bl_x + size - tr_x
               jump_size = max(div(overage, 2), 1)
               
               # we don't fit, move ahead
               find_first_fit(size, top_row + jump_size, bottom_row + jump_size) 
           end
       else 
           # if the bottom doesn't fit, jump ahead by size
           find_first_fit(size, bottom_row, bottom_row + size)
       end
       
    end
    
    def closest_to_origin({tl_x, tl_y}, size) do
    
        # walk the points in the square, finding the closest to the origin
        tl_y..(tl_y + size - 1)
        |> Enum.map(
            fn y -> 
                tl_x..(tl_x + size - 1)
                |> Enum.map(
                    fn x -> 
                        {x, y, :math.sqrt(x * x + y * y)}
                    end
                )
            end
        )
        |> List.flatten()
        |> Enum.sort_by(fn {_, _, dist} -> dist end)
        |> Enum.min_by(fn {_, _, dist} -> dist end)
    end
    
    @doc """
    Determine the start and end coordinates for the beam at a specific
    row in space, for row numbers > 20
    
        iex> beam_at_row(8)
        { {7, 8}, {8, 8} }
    """
    def beam_at_row(row_idx) do
            
        # find an anchor point in the row, where we _know_ we'll find the beam
        anchor = find_any_beam_at_row(row_idx)
        
        # find the edge coordinates at a specific row, using a binary search
        # from some point to the anchor
        left = find_beam_edge(row_idx, 0, anchor)
        right = find_beam_edge(row_idx, anchor, anchor * 10)
        { {left, row_idx}, {right, row_idx} }
    end
    
    def find_beam_edge(row_idx, left, right) when is_integer(left) and is_integer(right) do
        # what are the beam values?
        left_value = tractor_beam_test_at(left, row_idx)
        right_value = tractor_beam_test_at(right, row_idx)
        
        # binary search it
        if left == (right - 1) do
           # we're at an edge, which point is a 1?
           if left_value == 1 do
               left
           else
               right
           end 
        else
            
            # find a mid point
            mid = Kernel.trunc(div(right - left, 2) + left)
            mid_value = tractor_beam_test_at(mid, row_idx)
            
            case {left_value, mid_value, right_value} do
               {0, 0, 1} -> find_beam_edge(row_idx, mid, right)
               {0, 1, 1} -> find_beam_edge(row_idx, left, mid)
               {1, 0, 0} -> find_beam_edge(row_idx, left, mid)
               {1, 1, 0} -> find_beam_edge(row_idx, mid, right) 
            end
        end
    end
    
    @doc """
    Find any beam coordinate in the row, so we can use it as a search anchor
    """
    def find_any_beam_at_row(row_idx, last \\ nil) do
        
        # what point are we testing?
        test_point = if last == nil do
            # no point coming in, let's use row / 2
            div(row_idx, 2)
        else
            last + 3
        end
        
        if tractor_beam_test_at(test_point, row_idx) == 1 do
            test_point
        else
            find_any_beam_at_row(row_idx, test_point)
        end
        
    end
    
    @doc """
    Wrap interactions with the drone so we can query about a specific point
    on the (unrealized) tractor beam grid space.
    
        iex> tractor_beam_test_at(3, 4)
        1
    """
    def tractor_beam_test_at(x, y) do
        
        drone = %{
            create_drone_state(1, 1) |
            inputs: [x, y]
        }
        |> run_droid()
        
        drone.outputs |> List.first()
        
    end
    
    @doc """
    Use the area scanner to look at and print out a grid area.
    """
    def inspect_area(width, height) do
        
        drone = create_drone_state(width, height)
        |> scan_area()
        
        # convert the drone data into coordinates
        coords = drone.outputs
        |> Enum.with_index()
        |> Enum.map(
            fn {output, index} -> 
                
                # convert the index to a coordinate
                y = div(index, width)
                x = rem(index, width)
                {x, y, output}
            end
        )
        
        IO.ANSI.clear() |> IO.write()
        Grid.new(width, height, 0) 
        |> Grid.put_all(coords)
        |> draw()
        
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
                        if grid |> Grid.get_at(x, y) == 1 do
                            IO.write("#")
                        else
                            IO.write(".")
                        end
                    end
                )
                IO.write("\n")
            end
        )
        grid
    end
    
    @doc """
    Scan an entire 50x50 grid space, starting from 0, 0
    """
    def scan_area() do
        drone = create_drone_state(50, 50)
        scan_area(drone)
    end
    
    @doc """
    Scan a grid area, using the provided input data, and saving
    the outputs into the drone state
    """
    def scan_area(drone_state) do
        new_drone_state = run_droid(drone_state)
        
        if length(new_drone_state.inputs) > 0 do
            scan_area(new_drone_state)
        else
            new_drone_state
        end 
    end
    
    def run_droid(drone_state) do
        
        # IO.ANSI.clear() |> IO.write()

        # load our program and run it
        program = "data/day19/drone.ic"
        |> Intcode.program_from_file()
                    
        program
        # run the program
        |> Intcode.run(
            [
                memory_size: 6000,
                input_function: Intcode.send_for_input(self()),
                await_with: 
                    fn -> 
                        Intcode.await_io(drone_state, output_function: &handle_drone_output/2, output_count: 1, input_function: &handle_drone_input/1)
                    end
            ]
        )
    end
    
    @doc """
    create the state for a drone, so we can track outputs given a specific
    set of input areas.
    """
    def create_drone_state(width, height) do
        coords = 0..height - 1
        |> Enum.map(
            fn y -> 
                0..width - 1
                |> Enum.map(fn x -> [x, y] end)
            end
        )
        |> List.flatten()
        
        %{
            width: width,
            height: height,
            outputs: [],
            inputs: coords
        }
    end
    
    @doc """
    await_io handlers
    """
    def handle_drone_output(drone_state, [drone_out]) do
       {:continue, %{drone_state | outputs: drone_state.outputs ++ [drone_out]}}
    end
    
    def handle_drone_input(drone_state) do
        # grab a value from our queue
        {iv, data_queue} = drone_state.inputs |> List.pop_at(0)
                
        # send a value from our program
        {
            iv,
            %{drone_state | inputs: data_queue}
        }
    end
end