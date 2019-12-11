defmodule Aoc.Day11 do
    @moduledoc """
    Advent of Code 2019. Day 09. Problem 01/02.
    
    https://adventofcode.com/2019/day/9
    """ 
    
    def problem02 do
        # load the boost program and run it
        program = "data/day11/problem_01.ic"
        |> program_from_file()
        
        # hull bot
        hull_bot = init_hull_bot(250, 250, 125, 125, "U", 1)
        
        run_hull_bot(program, hull_bot)
        |> display_hull()
    end
    
    def problem01 do
        
        # load the boost program and run it
        program = "data/day11/problem_01.ic"
        |> program_from_file()
        
        # hull bot
        hull_bot = init_hull_bot(250, 250)
        
        run_hull_bot(program, hull_bot)
        |> painted_panel_count()
        
    end
    
    def run_hull_bot(program, hull_bot) do
        run_intcode(
            program, 
            [
                input_function: send_for_input(self()),
                await_with: fn -> await_paint(hull_bot) end
            ]
        )
    end
    
    # run hull bot
    def sim_instructions(hull_bot, []), do: hull_bot
    def sim_instructions(hull_bot, [p, m | inst]) do
        
        hull_bot
        |> hull_bot_paint(p)
        |> hull_bot_rotate_and_move(rot_by(m))
        |> sim_instructions(inst)
        
    end
    
    defp rot_by(1), do: "R"
    defp rot_by(0), do: "L"
    
    # await_paint output
    # listen for input request
    def await_paint(hull_bot) do
    
        receive do
           :halt -> hull_bot
           
           {:input, dest} -> 
               send_hull_bot_sensor_input(hull_bot, dest) 
               await_paint(hull_bot)
               
           v ->
               
               hull_bot
               |> hull_bot_paint(v)
               |> await_move()
        end
    end
    
    # await_move output
    # listen for input request
    def await_move(hull_bot) do
        
        receive do
            :halt -> hull_bot
        
            {:input, dest} -> 
                send_hull_bot_sensor_input(hull_bot, dest) 
                await_move(hull_bot)
            
            v ->
                hull_bot
                |> hull_bot_rotate_and_move(rot_by(v))
                |> await_paint()
        end        
    end
    
    defp send_hull_bot_sensor_input(hull_bot, dest_pid) do
        # if the panel color is explicity white, return white, otherwise black
        panel_color = if hull_bot.grid |> Enum.at(hull_bot.bot.y) |> Enum.at(hull_bot.bot.x) == 1 do
            1
        else
            0
        end
        send(dest_pid, {:input, panel_color})
    end
    
    @doc """
    Initialize a hull bot state. This state tracks where the bot is, as well
    as the grid state on which it is drawing. If an initial X and Y coordinate
    and heading are supplied, the bot will be positioned as such. Otherwise the
    bot will be centered in the grid.
    
    ## Example
    
        iex> init_hull_bot(5, 5, 3, 3, "U")
        %{
            grid: [ [-1, -1, ...], [], [], [], []],
            bot: %{
                heading: "U",
                x: 3,
                y: 3
            }
        }
    """
    def init_hull_bot(grid_width, grid_height, bot_x \\ nil, bot_y \\ nil, bot_heading \\ "U", start_color \\ -1) do
        
        # build out the grid data
        grid = 1..grid_height
        |> Enum.map(
            fn _y ->
                1..grid_width
                |> Enum.map(
                    fn _x ->
                        -1
                    end
                )
            end
        )
        
        # determine our x and y
        bot_x = if bot_x == nil do
            Kernel.trunc(grid_width / 2)
        else
            bot_x
        end
        
        bot_y = if bot_y == nil do
            Kernel.trunc(grid_height / 2)
        else
            bot_y
        end
        
        %{
            grid: grid,
            bot: %{
                heading: bot_heading,
                x: bot_x,
                y: bot_y
            }
        }
        |> hull_bot_paint(start_color)
    end
    
    def painted_panel_count(hull_bot) do
    
        hull_bot.grid
        |> List.flatten()
        |> Enum.filter(fn p -> p >= 0 end)
        |> length()
    end
    
    def display_hull(hull_bot) do
        hull_bot
        |> clip_hull_image()
        |> Enum.each(
            fn row -> 
                row
                |> Enum.each(
                    fn pixel ->
                        if pixel == 1 do
                            IO.write("▊")
                        else
                            IO.write(" ")
                        end
                    end
                )
                IO.write("\n")
            end
        )
    end
    
    @doc """
    Trim down the hull image to only those areas that have been painted.
    
    Returns the hull grid, minus the hull bot
    """
    def clip_hull_image(hull_bot) do
        
        vert_clipped = hull_bot.grid
        
        # clip the top of the image
        |> Enum.drop_while(
            fn row -> 
                row |> Enum.all?(fn p -> p == -1 end)
            end
        )
        
        # clip the bottom of the image
        |> Enum.reverse()
        |> Enum.drop_while(
            fn row -> 
                row |> Enum.all?(fn p -> p == -1 end)
            end
        )
        |> Enum.reverse()
        
        # determine the min pixel index that's set on the left
        left_clip = vert_clipped
        |> Enum.map(&first_pixel/1)
        |> Enum.min()
        
        # find the right most pixel in our clipped
        right_clip = vert_clipped
        |> Enum.map(&last_pixel/1)
        |> Enum.max()
        
        # now clip on the right and left
        vert_clipped
        |> Enum.map(
            fn row ->
                # clip row
                row |> Enum.slice(left_clip, right_clip - left_clip)
            end
        )

    end
    
    # what is the index of the first pixel with a set value (a value 0 or greater)
    def first_pixel(row) do
        row |> Enum.find_index(fn p -> p >= 0 end)
    end
    
    def last_pixel(row) do
        (length(row) - 1) - (row |> Enum.reverse() |> first_pixel())
    end
    
    @doc """
    Paint the hull under the bot a specific color, returning the modified hull bot state 
    """
    def hull_bot_paint(hull_bot, color) do
        %{
            grid: hull_bot.grid |> update_in([Access.at(hull_bot.bot.y), Access.at(hull_bot.bot.x)], fn _p -> color end),
            bot: hull_bot.bot
        }
    end
    
    @doc """
    Rotate and move the hull bot Left or Right (Counter-clockwise or Clockwise).
    
    ## Example
    
        iex> hull_bot_rotate_and_move(%{}, "L")
        %{}
    """
    def hull_bot_rotate_and_move(hull_bot, rot) do
       n_heading = case rot do
          "L" -> 
              case hull_bot.bot.heading do
                 "U" -> "L"
                 "L" -> "D"
                 "D" -> "R"
                 "R" -> "U" 
              end
              
          "R" -> 
              case hull_bot.bot.heading do
                 "U" -> "R"
                 "R" -> "D"
                 "D" -> "L"
                 "L" -> "U" 
              end
       end 
       
       {x, y} = case n_heading do
          "U" ->
              {hull_bot.bot.x, hull_bot.bot.y - 1} 
          "L" ->
              {hull_bot.bot.x - 1, hull_bot.bot.y}
          "D" ->
              {hull_bot.bot.x, hull_bot.bot.y + 1}
          "R" ->
              {hull_bot.bot.x + 1, hull_bot.bot.y}
       end
       
       %{
           grid: hull_bot.grid,
           bot: %{
               heading: n_heading,
               x: x,
               y: y
           }
       }
    end
    
    @doc """
    Load an Intcode program from a file. The program should be integers separated
    by commas, all on one line.
    """
    def program_from_file(filename) do
        
        filename
        |> File.read!()
        |> String.trim()
        |> String.split(",")
        |> Enum.map(
            fn s -> 
                {i, _} = Integer.parse(s)
                i
            end
        )
    end
    
    @doc """
    Run an Intcode program, and get a collection of output values.
    
    ## Example
    
        iex> run_intcode([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99])
        [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    """
    def run_intcode(program, opts \\ []) do
        
        # use our options to build our IO functions
        input_func = opts |> Keyword.get(:input_function, &default_input/0)
        await_func = opts |> Keyword.get(:await_with, &await_and_collect/0)
        
        # initialize
        %{program: initialized_program, state: state} = initialize(program)
        
        # we're going to receive a halt instruction and output instructions
        spawn_program(
            initialized_program,
            state,
            [
                output_function: send_output(self()), 
                halt_function: send_halt(self()),
                input_function: input_func
            ]
        )
        
        await_func.()
        
    end
    
    @doc """
    Keep track of the current output of the last amplifier, and return
    it after we halt
    """
    def await_result(last_result) do
       receive do
           :halt -> last_result
           v -> await_result(v) 
       end
    end
   
    @doc """
    Keep track of the current output of the last amplifier, and forward
    it on to a list of other amplifiers. When we get a halt message,
    we can return our value
    """
    def await_and_forward(last_result, forwards) when is_list(forwards) do
       
        receive do
            :halt -> last_result
            v ->
                forwards |> Enum.each(fn pid -> send(pid, v) end)
                await_and_forward(v, forwards)
        end
    end
    
    @doc """
    Gather and collect all outputs from a program, returning the list
    of result data when the program halts.
    
    
    """
    def await_and_collect(collection \\ []) do
        receive do
            :halt -> collection
            v -> await_and_collect(collection ++ [v]) 
        end
        
    end
    
    def spawn_program(program, state, opts) do
        spawn(fn -> eval_program(program, state, 0, opts) end)
    end
    
    @doc """
    Given an Intcode program, initialize the program data and the state
    tracker. This involves a few steps:
    
     - padding out the program data to a specific size
     - initializing the state tracking registers
    
    """
    def initialize(program, opts \\ []) do
    
        # what program size are we using for padding?
        program_size = opts |> Keyword.get(:program_size, 2000)
        
        # calculate the padding
        padding = case max(program_size - Enum.count(program), 0) do
            0 -> []
            v -> 1..v |> Enum.map(fn _ -> 0 end)
        end
        
        # program and state
        %{
            program: program ++ padding,
            state: %{
                relative_base: 0
            }
        }
        
    end
    
    @doc """
    Run an Intcode program, and return the program when complete. Optionally provide a
    starting address and program options.
   
    ## Options
       
     - :input_function - the function to use when requesting user input, defaults to parsing an integer from `stdin`
   
   
    ## Example
   
        iex> eval_program([1, ...])
        [12, 0, ...]
   
    When passing program options, the starting address needs to be explicitly provided:
   
        iex> eval_program([1, ...], 0, [input_function: fn -> ... end])
        [22, 0, ...]
       
    """
    def eval_program(program, state, at \\ 0, opts \\ []) when is_map(state) do
              
        # make sure we have an input routine
        input_func = opts |> Keyword.get(:input_function, &default_input/0)
        output_func = opts |> Keyword.get(:output_function, &default_output/1)
        halt_func = opts |> Keyword.get(:halt_function, &default_halt/0)
       
        prog_opts = [input_function: input_func, output_function: output_func, halt_function: halt_func]
       
        case eval_at(program, state, at, prog_opts) do
           {:halt, u_program, _state} -> 
              
               # determine what to do when we halt
               halt_func.()
              
               # return the program
               u_program
           {:continue, inst_inc, u_program, state} -> eval_program(u_program, state, at + inst_inc, prog_opts) 
           {:jump, pointer, u_program, state} -> eval_program(u_program, state, pointer, prog_opts) 
        end
       
    end
   
    @doc """
    By default when we halt, we just null route the message
    """
    def default_halt() do
        :ok
    end
   
    @doc """
    Send the halt notification to a specific PID
    """
    def send_halt(pid) do
       fn ->
           send(pid, :halt) 
       end 
    end
   
    @doc """
    Retrieve input from STDIN
    """
    def default_input() do
        {v, _} = IO.gets("input: ") |> Integer.parse()
        v
    end
    
    @doc """
    Request input from another PID
    """
    def send_for_input(source_pid) do
        fn ->
            send(source_pid, {:input, self()})
            receive do
                {:input, v} -> v
            end
        end
    end
   
    @doc """
    Retrieve input from our PID mailbox
    """
    def receive_input() do
       receive do
          v -> v 
       end 
    end
   
    @doc """
    Push output to STDOUT
    """
    def default_output(v) do
        IO.puts("#{v}")
    end
   
    @doc """
    Generate a function that will send output to another PID
    """
    def send_output(dest_pid) do
       fn v ->
          send(dest_pid, v)
       end 
    end
   
    @doc """
    Generate a function that will send outputs to multiple PIDs
    """
    def send_multiple_outputs(dest_pids) when is_list(dest_pids) do
        fn v ->
           dest_pids
           |> Enum.each(fn pid -> send(pid, v) end) 
        end
    end
   
    @doc """
    Eval the program instruction at the given offset, returning the updated program
    with:
       
     - :halt and program contents
     - :jump makes a pointer jump
     - :continue, instruction pointer increment, and program contets
   
    ## Example
   
        iex> eval_at(program, 0)
        {:continue, 2, [...]}
       
        iex> eval_at(program, 0)
        {:continue, 4, [...]}
   
        iex> eval_at(program, 12)
        {:halt, [...]}
    """
    def eval_at(program, state, offset, opts) do
      
       case decode_instruction(Enum.at(program, offset)) do
         
          {:halt} -> 
             
              {:halt, program, state}
         
          {:add, l_addr_mode, r_addr_mode, store_addr_mode} -> 
             
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
             
              # gather our values
              l_val = decode_parameter(program, state, l_addr, l_addr_mode)
              r_val = decode_parameter(program, state, r_addr, r_addr_mode)

              store_addr = case store_addr_mode do
                  :position -> store_addr
                  :relative -> state.relative_base + store_addr
              end
             
              {:continue, 4, List.update_at(program, store_addr, fn _ -> r_val + l_val end), state}
             
          {:multiply, l_addr_mode, r_addr_mode, store_addr_mode} ->
             
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
             
              # gather our values
              l_val = decode_parameter(program, state, l_addr, l_addr_mode)
              r_val = decode_parameter(program, state, r_addr, r_addr_mode)
              
              store_addr = case store_addr_mode do
                  :position -> store_addr
                  :relative -> state.relative_base + store_addr
              end
             
              {:continue, 4, List.update_at(program, store_addr, fn _ -> r_val * l_val end), state}
             
          {:input, store_addr_mode} ->
             
              input_func = opts |> Keyword.get(:input_function)
             
              int_in = input_func.()
              
              store_addr = case store_addr_mode do
                  :position -> Enum.at(program, offset + 1)
                  :relative -> state.relative_base + Enum.at(program, offset + 1)
              end
             
              {:continue, 2, List.update_at(program, store_addr, fn _ -> int_in end), state}
             
          {:output, o_addr_mode} ->
             
              output_func = opts |> Keyword.get(:output_function)
             
              o_addr = Enum.at(program, offset + 1)              
              o_val = decode_parameter(program, state, o_addr, o_addr_mode)
             
              output_func.(o_val)

              {:continue, 2, program, state}
             
          {:jump_if_true, l_addr_mode, j_addr_mode} ->

              [l_addr, j_addr] = Enum.slice(program, offset + 1, 2)
              
              # get our compare and jump address values
              l_val = decode_parameter(program, state, l_addr, l_addr_mode)
              j_val = decode_parameter(program, state, j_addr, j_addr_mode)
             
              if l_val > 0 do
                  {:jump, j_val, program, state}
              else
                  {:continue, 3, program, state}
              end
             
          {:jump_if_false, l_addr_mode, j_addr_mode} ->

              [l_addr, j_addr] = Enum.slice(program, offset + 1, 2)

              # get our compare and jump address values
              l_val = decode_parameter(program, state, l_addr, l_addr_mode)
              j_val = decode_parameter(program, state, j_addr, j_addr_mode)
             
              if l_val == 0 do
                  {:jump, j_val, program, state}
              else
                  {:continue, 3, program, state}
              end
             
          {:less_than, l_addr_mode, r_addr_mode, store_addr_mode} ->
             
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)

              # gather our values
              l_val = decode_parameter(program, state, l_addr, l_addr_mode)
              r_val = decode_parameter(program, state, r_addr, r_addr_mode)

              store_addr = case store_addr_mode do
                  :position -> store_addr
                  :relative -> state.relative_base + store_addr
              end
             
              # what are we storing
              store_val = if l_val < r_val do
                  1
              else
                  0
              end
             
              {:continue, 4, List.update_at(program, store_addr, fn _ -> store_val end), state}
             
          {:equals, l_addr_mode, r_addr_mode, store_addr_mode} ->
         
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)

              # gather our values
              l_val = decode_parameter(program, state, l_addr, l_addr_mode)
              r_val = decode_parameter(program, state, r_addr, r_addr_mode)

              store_addr = case store_addr_mode do
                  :position -> store_addr
                  :relative -> state.relative_base + store_addr
              end
                      
              # what are we storing
              store_val = if l_val == r_val do
                  1
              else
                  0
              end
             
              {:continue, 4, List.update_at(program, store_addr, fn _ -> store_val end), state}
              
          {:relative_base_add, rba_addr_mode} ->
              
              # get our immediate value parameter
              rba_addr = Enum.at(program, offset + 1)
              rba_val = decode_parameter(program, state, rba_addr, rba_addr_mode)
              
              # rebuild state and continue
              {:continue, 2, program, %{state | relative_base: state.relative_base + rba_val}}
       end
    end
   
    def decode_parameter(program, state, addr, mode) do
    
        case mode do
            :position -> Enum.at(program, addr)
            :immediate -> addr
            :relative -> Enum.at(program, state.relative_base + addr)
        end
        
    end
    
    @doc """
    Decode the given instruction, according to:
   
        ABCDE
         1002

        DE - two-digit opcode,      02 == opcode 2
         C - mode of 1st parameter,  0 == position mode
         B - mode of 2nd parameter,  1 == immediate mode
         A - mode of 3rd parameter,  0 == position mode, omitted due to being a leading zero
    
        Modes
         0 - position mode
         1 - immediate mode
         2 - relative mode
    """
    def decode_instruction(inst) do
        digits = Integer.digits(inst) |> Enum.reverse()
       
        # op code
        op = digits |> Enum.slice(0, 2) |> Enum.reverse() |> Integer.undigits()
       
        case op do
           1 -> 
               {
                   :add,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode(),
                   digits |> Enum.at(4, 0) |> memory_mode()
               } 
              
           2 ->
               {
                   :multiply,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode(),
                   digits |> Enum.at(4, 0) |> memory_mode()
               }
              
           3 ->
               {
                   :input,
                   digits |> Enum.at(2, 0) |> memory_mode()
               }
              
           4 ->
               {
                   :output,
                   digits |> Enum.at(2, 0) |> memory_mode()
               }
              
           5 ->
               {
                   :jump_if_true,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode()                   
               }
              
           6 ->
               {
                   :jump_if_false,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode()                   
               }
              
           7 ->
               {
                   :less_than,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode(),
                   digits |> Enum.at(4, 0) |> memory_mode()
               }
              
           8 ->
               {
                   :equals,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode(),
                   digits |> Enum.at(4, 0) |> memory_mode()
               }
               
           9 ->
               {
                   :relative_base_add,
                   digits |> Enum.at(2, 0) |> memory_mode()
               }
              
           99 ->
               {
                   :halt
               }
                  
        end
       
       
    end
   
    defp memory_mode(0), do: :position
    defp memory_mode(1), do: :immediate  
    defp memory_mode(2), do: :relative  
    
end