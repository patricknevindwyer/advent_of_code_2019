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
        IO.puts("save message offset")
        
        # duplicate the message 10,000 times
        signal = signal |> String.duplicate(10_000)
        IO.puts("build extended message")
        
        # now slice off everything up to our message offset
        signal = signal |> String.slice(message_offset, String.length(signal))
        IO.puts("trimmed extended message")
        
        # run the fft with our subset pattern
        fft(signal, 100, [1, 0, -1])
        
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
        # IO.puts("Running fft on series(#{length(num)})")
        
        # build our FFT # patterns, which is pre-computed for every offset
#         patterns = 0..length(num)
#         |> Enum.map(
#             fn phase ->
#                 fft_pattern(pattern, index: phase, length: length(num))
#             end
#         )
#         IO.puts("built pre-patterns")
        # now pass things on to the FFT itself
        alt_run_fft(num, repeat, pattern)
    end
    
    def run_fft(num, 0, _pattern) when is_list(num), do: num
    def run_fft(num, repeat, pattern) when is_list(num) do
        IO.puts("cycle: #{repeat}")
        # break apart our digits
        # fft_size = length(num)
        
        result = num
        |> Enum.with_index()
        |> Enum.map(
            fn {_digit, index} -> 
                
                # get our fft pattern
                p = fft_pattern(pattern, index: index, length: length(num)) #patterns |> Enum.at(index)
                
                # zip our digits and phase indexed FFT together
                Enum.zip(num, p)
                |> Enum.map(fn {a_d, a_p} -> a_d * a_p end)
                |> Enum.sum()
                |> Integer.digits()
                |> List.last()
                |> abs()
            end
        )
        
        run_fft(result, repeat - 1, pattern)
        
    end
    
    def alt_run_fft(num, 0, _pattern) when is_list(num), do: num
    def alt_run_fft(num, repeat, pattern) when is_list(num) do
        IO.puts("alt cycle: #{repeat}")
        result = num
        |> Enum.with_index()
        |> Enum.map(
            fn {_digit, index} -> 
                # zip our digits and phase indexed FFT together
                num
                |> Enum.with_index()
                |> Enum.map(
                    fn {a_d, a_idx} -> 
                        a_d * fft_pattern_digit_at(pattern, a_idx, index: index)
                    end
                )                
                |> Enum.sum()
                |> Integer.digits()
                |> List.last()
                |> abs()
            end
        )
        
        alt_run_fft(result, repeat - 1, pattern)
        
    end
    
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
        repeat_digit(d, t - 1) ++ [d]
    end
    
    def extend_pattern(p, len) when is_list(p) and length(p) >= len, do: p
    def extend_pattern(p, len) when is_list(p) do
       p ++ extend_pattern(p, len - length(p)) 
    end

end