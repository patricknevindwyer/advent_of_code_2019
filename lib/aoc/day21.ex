defmodule Aoc.Day21 do
    @moduledoc """
    Advent of Code 2019. Day 21. Problem 01/02.
    
    https://adventofcode.com/2019/day/21
    
    """ 
    
    alias Aoc.Intcode
    alias Chunky.Grid
        
    def problem01 do
        
        create_ascii_state(
            [
                "NOT C J",
                "AND D J",
                "NOT A T",
                "OR T J"
            ],
            mode: :walk
        )
        |> run_droid()
        
    end
    
    def problem02 do
        create_ascii_state(
            [
                "OR A J",
                "AND B J",   
                "AND C J",
                "NOT J J",
                "AND D J",
                "OR E T",
                "OR H T",
                "AND T J"
            ],
            mode: :run
        )
        |> run_droid()
        
    end
    
    def run_droid(ascii_state) do
                
        # load our program and run it
        program = "data/day21/springdroid.ic"
        |> Intcode.program_from_file()
                    
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
    Create a ASCII state computer with input programs.
    
    """
    def create_ascii_state(program, opts \\ []) when is_list(program) do
        
        move = case opts |> Keyword.get(:mode, :walk) do
            :walk -> "WALK"
            :run -> "RUN"
        end
        
        # update the program data to include newlines and a WALK command
        program = program ++ [move]
        |> Enum.map(
            fn asm -> 
                "#{asm}\n"
                |> String.to_charlist()
            end
        )
        |> List.flatten()
                
       %{
           program: program,
           damage: 0,
           output: []
       } 
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
            %{ascii_state | program: program_queue, output: []}
        }
                
    end
    
    @doc """
    """
    def handle_ascii_output(ascii_state, [droid_output]) do
        
        # if our camera state is large enough, we need to print out the
        # camera, and dump, in order to support continuous map mode.
        
        # if the value is large than 128, that's our final output
        ascii_state_next = if droid_output > 128 do
            Map.put(ascii_state, :damage, droid_output)
        else
            %{ascii_state | output: ascii_state.output ++ [droid_output]}            
        end
        {:continue, ascii_state_next}

    end
    
end