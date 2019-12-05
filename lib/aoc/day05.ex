defmodule Aoc.Day05 do
    @moduledoc """
    Advent of Code 2019. Day 05. Problem 01/02.
    
    https://adventofcode.com/2019/day/5
    """
    
    @program01 [
        3,225,1,225,6,6,1100,1,238,225,104,0,
        2,136,183,224,101,-5304,224,224,4,224,
        1002,223,8,223,1001,224,6,224,1,224,223,
        223,1101,72,47,225,1101,59,55,225,1101,
        46,75,225,1101,49,15,224,101,-64,224,224,
        4,224,1002,223,8,223,1001,224,5,224,1,224,
        223,223,102,9,210,224,1001,224,-270,224,4,
        224,1002,223,8,223,1001,224,2,224,1,223,
        224,223,101,14,35,224,101,-86,224,224,4,
        224,1002,223,8,223,101,4,224,224,1,224,
        223,223,1102,40,74,224,1001,224,-2960,224,
        4,224,1002,223,8,223,101,5,224,224,1,
        224,223,223,1101,10,78,225,1001,39,90,224,
        1001,224,-149,224,4,224,102,8,223,223,1001,
        224,4,224,1,223,224,223,1002,217,50,224,
        1001,224,-1650,224,4,224,1002,223,8,223,
        1001,224,7,224,1,224,223,223,1102,68,
        8,225,1,43,214,224,1001,224,-126,224,4,
        224,102,8,223,223,101,3,224,224,1,224,
        223,223,1102,88,30,225,1102,18,80,225,1102,
        33,28,225,4,223,99,0,0,0,677,0,0,0,0,
        0,0,0,0,0,0,0,1105,0,99999,1105,227,247,
        1105,1,99999,1005,227,99999,1005,0,256,1105,
        1,99999,1106,227,99999,1106,0,265,1105,1,
        99999,1006,0,99999,1006,227,274,1105,1,99999,
        1105,1,280,1105,1,99999,1,225,225,225,1101,
        294,0,0,105,1,0,1105,1,99999,1106,0,300,
        1105,1,99999,1,225,225,225,1101,314,0,0,
        106,0,0,1105,1,99999,108,677,677,224,102,
        2,223,223,1005,224,329,1001,223,1,223,1107,
        677,226,224,102,2,223,223,1006,224,344,1001,
        223,1,223,108,226,226,224,102,2,223,223,1005,
        224,359,1001,223,1,223,1108,677,226,224,102,
        2,223,223,1006,224,374,101,1,223,223,108,677,
        226,224,102,2,223,223,1006,224,389,1001,223,1,
        223,107,226,226,224,102,2,223,223,1005,224,
        404,1001,223,1,223,8,226,226,224,102,2,223,
        223,1006,224,419,101,1,223,223,1107,677,677,
        224,102,2,223,223,1006,224,434,1001,223,1,223,
        1107,226,677,224,1002,223,2,223,1006,224,449,
        101,1,223,223,7,677,677,224,1002,223,2,223,
        1006,224,464,1001,223,1,223,1108,226,677,224,
        1002,223,2,223,1005,224,479,1001,223,1,223,8,
        677,226,224,1002,223,2,223,1005,224,494,101,1,
        223,223,7,226,677,224,102,2,223,223,1005,224,
        509,101,1,223,223,1008,677,226,224,102,2,223,
        223,1006,224,524,101,1,223,223,8,226,677,224,
        1002,223,2,223,1006,224,539,1001,223,1,223,1007,
        677,677,224,102,2,223,223,1005,224,554,101,1,
        223,223,107,226,677,224,1002,223,2,223,1005,
        224,569,1001,223,1,223,1108,677,677,224,1002,
        223,2,223,1006,224,584,1001,223,1,223,1008,
        226,226,224,1002,223,2,223,1005,224,599,101,
        1,223,223,1008,677,677,224,102,2,223,223,
        1005,224,614,101,1,223,223,7,677,226,224,
        1002,223,2,223,1005,224,629,1001,223,1,223,
        107,677,677,224,1002,223,2,223,1006,224,644,
        101,1,223,223,1007,226,677,224,1002,223,2,
        223,1005,224,659,1001,223,1,223,1007,226,226,
        224,102,2,223,223,1005,224,674,101,1,223,
        223,4,223,99,226
    ]
    
    def problem01() do
       eval_program(@program01) 
    end
    
    def problem02() do
       eval_program(@program01, 0, [input_function: fn -> 5 end]) 
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
    def eval_program(program, at \\ 0, opts \\ []) do
        
        # make sure we have an input routine
        input_func = opts |> Keyword.get(:input_function, &default_input/0)
        
        case eval_at(program, at, [input_function: input_func]) do
           {:halt, u_program} -> u_program
           {:continue, inst_inc, u_program} -> eval_program(u_program, at + inst_inc, [input_function: input_func]) 
           {:jump, pointer, u_program} -> eval_program(u_program, pointer, [input_function: input_func]) 
        end
        
    end
    
    def default_input() do
        {v, _} = IO.gets("input: ") |> Integer.parse()
        v
    end
    
    @doc """
    Eval the program instruction at the given offset, returning the updated program
    with:
        
     - :halt and program contents
     - :continue, instruction pointer increment, and program contets
    
    ## Example
    
        iex> eval_at(program, 0)
        {:continue, 2, [...]}
        
        iex> eval_at(program, 0)
        {:continue, 4, [...]}
    
        iex> eval_at(program, 12)
        {:halt, [...]}
    """
    def eval_at(program, offset, opts) do
       
       case decode_instruction(Enum.at(program, offset)) do
          
          {:halt} -> 
              {:halt, program}
          
          {:add, l_addr_mode, r_addr_mode, :position} -> 
              
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
              
              # gather our values
              l_val = case l_addr_mode do
                 :position -> Enum.at(program, l_addr)
                 :immediate -> l_addr
              end
              
              r_val = case r_addr_mode do
                 :position -> Enum.at(program, r_addr)
                 :immediate -> r_addr
              end
              
              {:continue, 4, List.update_at(program, store_addr, fn _ -> r_val + l_val end)}
              
          {:multiply, l_addr_mode, r_addr_mode, :position} ->
              
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
              
              # gather our values
              l_val = case l_addr_mode do
                 :position -> Enum.at(program, l_addr)
                 :immediate -> l_addr
              end
              
              r_val = case r_addr_mode do
                 :position -> Enum.at(program, r_addr)
                 :immediate -> r_addr
              end
              
              {:continue, 4, List.update_at(program, store_addr, fn _ -> r_val * l_val end)}
              
          {:input, :position} ->
              
              input_func = opts |> Keyword.get(:input_function)
              
              int_in = input_func.()
              store_addr = Enum.at(program, offset + 1)
              
              {:continue, 2, List.update_at(program, store_addr, fn _ -> int_in end)}
              
          {:output, o_addr_mode} ->
              
              o_addr = Enum.at(program, offset + 1)
              
              o_val = case o_addr_mode do
                  :position -> Enum.at(program, o_addr)
                  :immediate -> o_addr                  
              end
              
              IO.puts("#{o_val}")
              {:continue, 2, program}
              
          {:jump_if_true, l_addr_mode, j_addr_mode} ->

              [l_addr, j_addr] = Enum.slice(program, offset + 1, 2)
              
              l_val = case l_addr_mode do
                 :position -> Enum.at(program, l_addr)
                 :immediate -> l_addr
              end
              
              j_val = case j_addr_mode do
                 :position -> Enum.at(program, j_addr)
                 :immediate -> j_addr
              end
              
              if l_val > 0 do
                  {:jump, j_val, program}
              else
                  {:continue, 3, program}
              end
              
          {:jump_if_false, l_addr_mode, j_addr_mode} ->

              [l_addr, j_addr] = Enum.slice(program, offset + 1, 2)
              
              l_val = case l_addr_mode do
                 :position -> Enum.at(program, l_addr)
                 :immediate -> l_addr
              end
              
              j_val = case j_addr_mode do
                 :position -> Enum.at(program, j_addr)
                 :immediate -> j_addr
              end
              
              if l_val == 0 do
                  {:jump, j_val, program}
              else
                  {:continue, 3, program}
              end
              
          {:less_than, l_addr_mode, r_addr_mode, :position} ->
              
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
          
              # gather our values
              l_val = case l_addr_mode do
                 :position -> Enum.at(program, l_addr)
                 :immediate -> l_addr
              end
          
              r_val = case r_addr_mode do
                 :position -> Enum.at(program, r_addr)
                 :immediate -> r_addr
              end
              
              # what are we storing
              store_val = if l_val < r_val do
                  1
              else
                  0
              end
              
              {:continue, 4, List.update_at(program, store_addr, fn _ -> store_val end)}
              
          {:equals, l_addr_mode, r_addr_mode, :position} ->
          
              [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
          
              # gather our values
              l_val = case l_addr_mode do
                 :position -> Enum.at(program, l_addr)
                 :immediate -> l_addr
              end
          
              r_val = case r_addr_mode do
                 :position -> Enum.at(program, r_addr)
                 :immediate -> r_addr
              end
              
              # what are we storing
              store_val = if l_val == r_val do
                  1
              else
                  0
              end
              
              {:continue, 4, List.update_at(program, store_addr, fn _ -> store_val end)}              
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
                   :position
               } 
               
           2 ->
               {
                   :multiply,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode(),
                   :position
               }
               
           3 ->
               {
                   :input,
                   :position
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
                   :position
               }
               
           8 ->
               {
                   :equals,
                   digits |> Enum.at(2, 0) |> memory_mode(),
                   digits |> Enum.at(3, 0) |> memory_mode(),
                   :position
               }
               
           99 ->
               {
                   :halt
               }
                   
        end
        
        
    end
    
    defp memory_mode(0), do: :position
    defp memory_mode(1), do: :immediate
end