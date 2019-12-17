defmodule Aoc.Day16 do
    @moduledoc """
    Advent of Code 2019. Day 16. Problem 01/02.
    
    https://adventofcode.com/2019/day/16
    
    """ 
    
    def problem02 do
        "data/day16/problem01.data"
        |> File.read!()
        |> String.trim()
        |> decode_signal()
        |> Enum.take(8)
    end
    
    def problem01 do
       "data/day16/problem01.data" 
       |> File.read!()
       |> String.trim()
       |> fft(100)
       |> Enum.take(8)
    end
    
    @doc """
    Decode a long signal, and find the value at a specific message offset
    when 100 rounds of our "fft" are complete.
    """
    def decode_signal(signal) when is_binary(signal) do
       
        # take the first seven digits to be our eventual offset
        {message_offset, _} = signal |> String.slice(0..6) |> Integer.parse()
        
        # duplicate the message 10,000 times
        signal = signal |> String.duplicate(10_000)
        
        # now slice off everything up to our message offset
        signal = signal |> String.slice(message_offset, String.length(signal))
        
        # run the fft with our subset pattern
        part_two_fft(signal, 100)
        
        # get the message at offset
        |> Enum.take(8)
        
    end
    
    @doc """
    Run an "fft" with a String, Integer, or List of Integers as
    the input. Optional values for the number of times to repeat
    the input pattern, and the sequencing for the "fft" pattern
    can be provided.
    
    The final result will be a list of integers.
    
    ## Example
    
        iex> fft("123456789")
        [4,8,2,2,6,1,5,8]
    """
    def fft(num, repeat \\ 1, pattern \\ [0, 1, 0, -1])
    
    def fft(num, repeat, pattern) when is_binary(num) do
    
        num
        |> String.split("")
        |> Enum.slice(1..String.length(num))
        |> Enum.map(
            fn s_digit -> 
                {v, _} = Integer.parse(s_digit)
                v
            end
        )
        |> run_fft(repeat, pattern)
    end
    
    def fft(num, repeat, pattern) when is_integer(num) do
        run_fft(Integer.digits(num), repeat, pattern)
    end
    
    def fft(num, repeat, pattern) when is_list(num) do
        run_fft(num, repeat, pattern)
    end
    
    @doc """
    The "fft" for problem two doesn't need to be as complex (and
    _can't_ be as complex) as the fft for problem one. For problem
    two we exploit three things:
    
     0. The "message offset" in our signal is more than halfway through the signal
     1. The beginning of the phase pattern is a lot of zeroes - up to the "message offset"
     2. The phase pattern that applies to everything after the message offset is `1`
    
    Given these three factors, we can bypass the complexity of the problem one
    "fft" entirely - all we need to calculate is a recurring sum of values.
    """
    def part_two_fft(num, repeat) when is_binary(num) do
        num
        |> String.split("")
        |> Enum.slice(1..String.length(num))
        |> Enum.map(
            fn s_digit -> 
                {v, _} = Integer.parse(s_digit)
                v
            end
        )
        |> part_two_fft(repeat)
        
    end
    
    def part_two_fft(num, 0), do: num
    def part_two_fft(num, repeat) do
        result = num 
        |> tail_sum()
        |> Enum.map(fn v -> 
            v |> Integer.digits() |> List.last() |> abs()
        end)
        part_two_fft(result, repeat - 1)
    end
    
    @doc """
    Run an "fft" against a number sequence for the specified number of
    iterations.
    
    """
    def run_fft(num, 0, _pattern) when is_list(num), do: num
    def run_fft(num, repeat, pattern) when is_list(num) do
        
        result = num
        |> Enum.with_index()
        |> Enum.map(
            fn {_digit, index} -> 
                # zip our digits and phase indexed FFT together
                num
                |> Enum.with_index()
                |> Enum.reduce(
                    0,
                    fn {a_d, a_idx}, acc -> 
                        acc + (a_d * fft_pattern_digit_at(pattern, a_idx, index: index))
                    end
                )                
                |> Integer.digits()
                |> List.last()
                |> abs()
            end
        )
        
        run_fft(result, repeat - 1, pattern)
        
    end
    
    @doc """
    Run a "tail sum" against a list of integers. In a tail sum, for each
    position in a list of integers, we sum all integers after that position
    when creating a new list. So a list that starts out as `[1, 2, 3, 4]`
    becomes `[10, 9, 7, 4]`, with each value in the new list being the sum
    of itself, and all following values from the previous list.
    """
    def tail_sum([v]), do: [v]
    def tail_sum([head | tail]) do
        rest = tail_sum(tail)
        [head + List.first(rest)] ++ rest
    end
    
    @doc """
    Calculate the fft phase sequence digit for a specific offset in a list, given
    the current phase sequence. This is a constant memory space way of working with
    even long phase sequences, without having to repeatedly build large lists. As
    this is in an inner loop of the FFT, it effectively turns an `O(N)` operation
    into `O(1)` within the loop.
    """
    def fft_pattern_digit_at(pattern, digit, opts \\ []) do
        phase_index = opts |> Keyword.get(:index, 0)
        
        # the cycle size is how big each repetition of our pattern is (1, 0, -1 vs 1, 1, 0, 0, -1, -1)
        cycle_size = length(pattern) * (phase_index + 1)
        
        if digit < (cycle_size - 1) do
            # in the first cycle. we need trim a digit to figure out where we
            # are, as our first cycle series drops a digit
            if digit < (phase_index + 1) do
                
                if digit < phase_index do
                    pattern |> Enum.at(0)
                else
                    pattern |> Enum.at(1)
                end
            else 
                digit = digit - phase_index
                p_offset = div(digit, (phase_index + 1))
                pattern |> Enum.at(p_offset + 1)
            end
            
        else
            # in a later cycle
            
            # this is which value in the specific cycle we're using, offset for the first cycle being wonky
            digit = max(0, digit - (cycle_size - 1))
            inter_cycle_offset = rem(digit, cycle_size)
        
            # now we figure out which digit that is
            p_offset = div(inter_cycle_offset, phase_index + 1)
        
            # IO.puts("digit(#{digit}) phase(#{phase_index}) cycle size(#{cycle_size}) inter cycle(#{inter_cycle_offset}) digit_offset(#{p_offset})")
            pattern |> Enum.at(p_offset)
        end
        
    end
    
    @doc """
    Build the fft phase pattern out to the proper length for an given index
    in a list. This involves changing the quantity of repeated digits in the
    base pattern, and repeating the pattern a sufficient number of times to
    match the required length for the signal.
    
    This function is unused in the final solutions to problems one and two.
    """
    def fft_pattern(pattern, opts \\ []) when is_list(pattern) do

        phase_index = opts |> Keyword.get(:index, 0)
        phase_length = opts |> Keyword.get(:length, 10)

        # use our base pattern
        pattern
        |> Enum.map(fn digit -> repeat_digit(digit, phase_index + 1) end)
        |> List.flatten()
        |> extend_pattern(phase_length + 2)
        |> Enum.drop(1)
        |> Enum.take(phase_length)

    end

    @doc """
    Repeat a digit the specified number of times.

    This function is unused in the final solutions to problems one and two.
    
    ## Example
    
        iex> repeat_digit(3, 5)
        [3, 3, 3, 3, 3]
    """
    def repeat_digit(_d, 0), do: []
    def repeat_digit(d, t) do
        repeat_digit(d, t - 1) ++ [d]
    end
    
    @doc """
    Extend a list with copies of itself until it is _at least_ a certain
    length.
    
    This function is unused in the final solutions to problems one and two.
    
    """
    def extend_pattern(p, len) when is_list(p) and length(p) >= len, do: p
    def extend_pattern(p, len) when is_list(p) do
       p ++ extend_pattern(p, len - length(p))
    end

end