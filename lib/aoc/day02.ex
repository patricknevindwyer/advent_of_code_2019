defmodule Aoc.Day02 do
    @moduledoc """
    Advent of Code 2019. Day 02. Problem 01/02.
    
    https://adventofcode.com/2019/day/2
    """
    
    # Already fixed program for Problem 01
    @program_01 [
        1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,13,
        1,19,1,19,9,23,1,5,23,27,1,27,9,31,1,
        6,31,35,2,35,9,39,1,39,6,43,2,9,43,47,
        1,47,6,51,2,51,9,55,1,5,55,59,2,59,6,
        63,1,9,63,67,1,67,10,71,1,71,13,75,2,
        13,75,79,1,6,79,83,2,9,83,87,1,87,6,
        91,2,10,91,95,2,13,95,99,1,9,99,103,
        1,5,103,107,2,9,107,111,1,111,5,115,1,
        115,5,119,1,10,119,123,1,13,123,127,1,
        2,127,131,1,131,13,0,99,2,14,0,0
    ]
    
    @doc """
    Run Problem 01 through the Intcode computer
    
    ## Example
    
        iex> eval_prog_01()
        1111
    
    """
    def problem01(), do: eval_prog_01()
    
    def eval_prog_01() do        
        eval_program(@program_01) 
    end
    
    @doc """
    Run Problem 02 through the Intcode computer. This involves checking
    all the permutations of a set of possible programs. The return value
    is a tuple of the instructions at address 01 and 02 that fulfill the
    problem.
    
    ## Example
    
        iex> eval_prog_02()
        {20, 12}
    
    """
    def problem02(), do: eval_prog_02()
    
    def eval_prog_02() do
        
        idx = permute(99, 99)
        |> Enum.map(
            fn {l_val, r_val} ->
                @program_01
                |> List.update_at(1, fn _ -> l_val end)
                |> List.update_at(2, fn _ -> r_val end)
            end
        )
        |> Enum.map(&eval_program/1)
        |> Enum.find_index(fn x -> x == 19690720 end)
        
        permute(99, 99) |> Enum.at(idx)
    end
    
    @doc """
    Build the permutation set of all integers in the two ranges
    defined by the provided upper bounds. The permutations are returned
    as a list of tuples.
    
    ## Example
    
        iex> permute(2, 2)
        [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}]
    """
    def permute(a, b) do
       Enum.map(
           0..a, 
           fn a_v -> 
               Enum.map(
                   0..b,
                   fn b_v ->
                       {a_v, b_v}
                   end
               )
           end
       ) 
       |> List.flatten()
    end
    
    @doc """
    Run an Intcode program, and return the value at address 00 when completed.
    
    ## Example
    
        iex> eval_program([1, ...])
        320
    """
    def eval_program(program, at \\ 0) do
        
        case eval_at(program, at) do
           {:halt, u_program} -> hd(u_program)
           {:continue, u_program} -> eval_program(u_program, at + 4) 
        end
        
    end
    
    @doc """
    Eval the program instruction at the given offset, returning the updated program
    with either a :halt or :continue result.
    
    ## Example
    
        iex> eval_at(program, 0)
        {:continue, [...]}
        
        iex> eval_at(program, 12)
        {:halt, [...]}
    """
    def eval_at(program, offset) do
       
       case Enum.slice(program, offset, 4) do
           
          # halt program
          [99 | _ ] -> {:halt, program} 
          
          # add and set
          [1, l_addr, r_addr, s_addr] -> 
              l_val = Enum.at(program, l_addr)
              r_val = Enum.at(program, r_addr)
              
              {:continue, List.update_at(program, s_addr, fn _ -> l_val + r_val end)}
             
          # multiply and set
          [2, l_addr, r_addr, s_addr] ->
              
              l_val = Enum.at(program, l_addr)
              r_val = Enum.at(program, r_addr)
              
              {:continue, List.update_at(program, s_addr, fn _ -> l_val * r_val end)}
              
       end 
    end
    
end