defmodule Aoc.Day22 do
    @moduledoc """
    Advent of Code 2019. Day 22. Problem 01/02.
    
    https://adventofcode.com/2019/day/22
    
    """ 
    
    def problem01 do
        
        # run our shuffle
        shuffled = "data/day22/problem_01.shuffle"
        |> File.read!()
        |> parse_shuffle()
        |> run_techs(factory_deck(10_007))
        
        # find card 2019
        shuffled |> Enum.find_index(fn v -> v == 2019 end)
    end
    
    @doc """
    Generate a factory sized deck of a specific size
    """
    def factory_deck(size) do
        0..size - 1 |> Enum.take(size)
    end
    
    @doc """
    Run a technique list against a deck of cards
    """
    def run_techs([], cards), do: cards
    def run_techs([tech | techs], cards) do        
        run_techs(techs, run_tech(tech, cards))
    end
    
    @doc """
    Run an individual card techique
    
    """
    def run_tech({:deal_stack}, cards), do: tech_new_stack(cards)
    def run_tech({:deal_increment, inc}, cards), do: tech_deal(cards, inc)
    def run_tech({:cut, c}, cards), do: tech_cut(cards, c)
    
    @doc """
    Deal as a new card stack
    """
    def tech_new_stack(cards) do
        cards |> Enum.reverse()
    end
    
    @doc """
    Cut the deck of cards
    """
    def tech_cut(cards, break) do
        {a, b} = cards |> Enum.split(break)
        b ++ a
    end
    
    @doc """
    Do an offset shuffle
    """
    def tech_deal(cards, offset) do
        
        tech_deal_iter(cards, offset, tracking_new(cards), 0)
        |> Enum.sort_by(fn {_c, idx} -> idx end)
        |> Enum.map(fn {c, _idx} -> c end)
        
    end
    
    @doc """
    Parse a shuffle from a string of techniques.
    """
    def parse_shuffle(str) do
        str
        |> String.split("\n")
        |> Enum.map(&parse_tech/1)
    end
    
    @doc """
    Parse a technique string
    """
    def parse_tech("deal with increment " <> incr) do
        {i, _} = incr |> Integer.parse()
        {:deal_increment, i} 
    end
    
    def parse_tech("deal into new stack") do
        {:deal_stack}
    end
    
    def parse_tech("cut " <> c) do
        {i, _} = c |> Integer.parse()
        {:cut, i}
    end
    
    @doc """
    Iterate through the list of cards to handle the deal shuffle. We
    build up a list of {card, index} on the fly to be sorted and mapped
    later, instead of building the full result list.
    
    The cycle is the deal size, while the tracking list is a full list
    of used indices for running the deal cycle.
    
    """
    def tech_deal_iter([], _cycle, _tracking_list, _offset), do: []
    def tech_deal_iter([card | cards], cycle, tracking_list, offset) do
        
        # find the position for our next card
        {pos, new_tracking} = tracking_next(tracking_list, offset, cycle)
        
        [{card, pos}] ++ tech_deal_iter(cards, cycle, new_tracking, pos)
    end
    
    defp tracking_new(cards) do
       0..length(cards) - 1
       |> Enum.map(fn _i -> -1 end) 
    end
    
    defp tracking_next(tracking_list, offset, cycle_size) do
        
        # handle wrapping
        offset = rem(offset, length(tracking_list)) 
        
        if Enum.at(tracking_list, offset) == -1 do
            # found our spot, update the tracking list to a _used_ marker
            {offset, List.replace_at(tracking_list, offset, 1)}
        else
            # keep going
            tracking_next(tracking_list, offset + cycle_size, cycle_size)
        end
    end
    
end