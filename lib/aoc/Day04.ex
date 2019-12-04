defmodule Aoc.Day04 do
    @moduledoc """
     Advent of Code 2019. Day 04. Problem 01/02.
    
     https://adventofcode.com/2019/day/4
    """
    
    def problem01() do
        
        candidate_passwords(124075, 580769, [&adjacent_digits?/1, &always_increasing?/1])
        |> length()
        
    end
    
    def problem02() do

        candidate_passwords(124075, 580769, [&adjacent_digits?/1, &always_increasing?/1, &exactly_two_adjacent_digits?/1])
        |> length()
        
    end
    
    @doc """
    Given a lower and higher bounds, and an optional list of conditions to be met, generate the list
    of possible candidate passwords.
    
    ## Example
    
        iex> candidate_passwords(111111, 222222, [&adjacent_digits?/1])
        [111111, 111112, ...]
    """
    def candidate_passwords(lower, higher), do: candidate_passwords(lower, higher, [])
    
    def candidate_passwords(lower, higher, predicates) when is_integer(lower) and is_integer(higher) and is_list(predicates) do
        
        lower..higher
        
        # apply all our predicates and filter out any that don't match
        |> Enum.filter(fn candidate -> fullfils_predicates?(candidate, predicates) end)
        
    end
    
    @doc """
    Does a given number meet every condition in the list of predicates?
    
    ## Example
    
        iex> fullfils_predicates?(123456, [&adjacent_digits?/1])
        false
    """
    def fullfils_predicates?(value, predicates) do
        predicates
        |> Enum.map(fn p -> p.(value) end)
        |> Enum.all?(fn r -> r end)
    end
    
    @doc """
    Password predicate: do the digits in the number contain at least one set of
    adjacent equal values? 1123456 does, 123456 does not.
    """
    def adjacent_digits?(candidate) do
       
       c_str = "#{candidate}"
       0..String.length(c_str) - 1
       |> Enum.map(
           fn idx -> 
               String.at(c_str, idx) == String.at(c_str, idx + 1)
           end
       )
       |> Enum.any?()
       
    end
    
    @doc """
    Password predicate: are the digits in the number always the same or increasing, and
    never decreasing?
    """
    def always_increasing?(candidate) do
       
       digits = Integer.digits(candidate)
       
       0..length(digits) - 1
       |> Enum.map(
           fn idx -> 
               Enum.at(digits, idx) <= Enum.at(digits, idx + 1)
           end
       )
       |> Enum.all?(fn r -> r end)
        
    end
    
    @doc """
    Password predicate: does the number contain a set of repeating digits _that only repeats once_? 
    
    Good: 111122 (22 meets predicate)
    Good: 123345 (33 meets predicate)
    Bad:  123334 (333 is tripled, not doubled)
    """
    def exactly_two_adjacent_digits?(candidate) do
        
        candidate
        |> take_sequences()
        |> Enum.any?(fn seq -> length(seq) == 2 end)
        
    end
    
    @doc """
    Given a number, break it into sub sequences of repeating digits.
    
    ## Example
    
        iex> 123345666 |> take_sequences()
        [ [1], [2], [3, 3], [4], [5], [6, 6, 6]]
    """
    def take_sequences(num) when is_integer(num) do
       take_sequences(Integer.digits(num)) 
    end
    
    def take_sequences([]), do: []
    def take_sequences([h]) do
        [[h]]
    end
    def take_sequences([h | seq]) do
        
        if h == hd(seq) do
           [[h] ++ Enum.take_while(seq, fn v -> v == h end)] ++ take_sequences(Enum.drop_while(seq, fn v -> v == h end ))
        else
           [[h]] ++ take_sequences(seq) 
        end
    end
    
end