defmodule Aoc.Day25 do
    @moduledoc """
    Advent of Code 2019. Day 25. Problem 01/02.
    
    https://adventofcode.com/2019/day/25
    
    """ 
    
    alias Aoc.Intcode
        
    def problem01 do
        
        create_ascii_state()
        |> run_droid()
        
    end
    
    
    def run_droid(ascii_state) do
                
        # load our program and run it
        program = "data/day25/santa.ic"
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
    def create_ascii_state() do
       %{
           input: [],
           output: []
       } 
    end    
    
    @doc """
    await_io handlers
    """
    def handle_ascii_input(ascii_state) do
        
        # if our input is empty, prompt for more
        n_ascii_state = if length(ascii_state.input) == 0 do
            IO.puts(ascii_state.output)
            new_input = IO.gets("> ") |> String.to_charlist()       
            %{ascii_state | input: new_input, output: []}
        else
            ascii_state
        end
        
        # grab a value from our queue
        {iv, input} = n_ascii_state.input |> List.pop_at(0)
                
        # send a value from our program
        {
            iv,
            %{n_ascii_state | input: input}
        }
                
    end
    
    @doc """
    """
    def handle_ascii_output(ascii_state, [droid_output]) do
        
        # if our camera state is large enough, we need to print out the
        # camera, and dump, in order to support continuous map mode.
        
        # if the value is large than 128, that's our final output
        {:continue, %{ascii_state | output: ascii_state.output ++ [droid_output]}}

    end
    
end