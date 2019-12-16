defmodule Aoc.Day16 do
    @moduledoc """
    Advent of Code 2019. Day 16. Problem 01/02.
    
    https://adventofcode.com/2019/day/16
    
    """ 
    
    def problem01 do
       "data/day16/problem01.data" 
       |> File.read!()
       |> String.trim()
       |> fft(100)
       |> Enum.take(8)
    end
    
    def decode_signal(signal) when is_binary(signal) do
       
        # take the first seven digits to be our eventual offset
        {message_offset, _} = signal |> String.slice(0..6) |> Integer.parse()
        
        # duplicate the message 10,000 times
        signal = signal |> String.duplicate(10_000)
        
        # run the fft
        fft(signal, 100)
        
        # get the message at offset
        |> Enum.drop(message_offset - 1)
        |> Enum.take(8)
        
    end
    
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
        |> fft(repeat, pattern)
    end
    
    def fft(num, repeat, pattern) when is_integer(num) do
        fft(Integer.digits(num), repeat, pattern)
    end
    
    def fft(num, repeat, pattern) when is_list(num) do
        
        # build our FFT patterns, which is pre-computed for every offset
        patterns = 0..length(num)
        |> Enum.map(
            fn phase -> 
                fft_pattern(pattern, index: phase, length: length(num))
            end
        )
        
        # now pass things on to the FFT itself
    end
    
    def run_fft(num, 0, _patterns) when is_list(num), do: num
    def run_fft(num, repeat, patterns) when is_list(num) do
        
        # break apart our digits
        fft_size = length(num)
        
        result = num
        |> Enum.with_index()
        |> Enum.map(
            fn {_digit, index} -> 
                
                # get our fft pattern
                p = fft_pattern(pattern, index: index, length: fft_size)
                
                # zip our digits and phase indexed FFT together
                Enum.zip(num, p)
                |> Enum.map(fn {a_d, a_p} -> a_d * a_p end)
                |> Enum.sum()
                |> Integer.digits()
                |> List.last()
                |> abs()
            end
        )
        
        fft(result, repeat - 1, pattern)
        
    end
    
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

    def repeat_digit(_d, 0), do: []    
    def repeat_digit(d, t) do
        [d] ++ repeat_digit(d, t - 1)
    end
    
    def extend_pattern(p, len) when is_list(p) and length(p) >= len, do: p
    def extend_pattern(p, len) when is_list(p) do
       p ++ extend_pattern(p, len - length(p)) 
    end

end