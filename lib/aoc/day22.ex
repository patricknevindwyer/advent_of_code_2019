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
    
    def problem02 do
       
        "data/day22/problem_01.shuffle"
        |> File.read!()
        |> parse_shuffle()
        |> run_modulo_techs(119315717514047, 101741582076661, 2020)
       
       # 93750418158025 
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
    
    
    # https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbqs5bk/
    def run_modulo_techs(techs, deck_size, iterations, card_loc) do
       
       # reverse the calcs, and run
       {o_m, i_m} = techs
       |> Enum.reverse()
       |> run_modulo_techs_iter(deck_size, iterations, card_loc) 
       
       # run final modulo math
       # inv = lambda x: pow(x, c-2, c)
       # o *= inv(1-i); i = pow(i, n, c)
       IO.puts("pre-I: #{i_m}")
       o_m = o_m * mod_pow(1 - i_m, deck_size - 2, deck_size)
       i_m = mod_pow(i_m, iterations, deck_size) # here's our problem - erlang's :crypto.mod_pow overflows, and we get an improper result
       
       IO.puts("O: #{o_m}")
       IO.puts("I: #{i_m}")
       # return (p*i + (1-i)*o) % c
       rem(
           (
               (card_loc * i_m) + ((1 - i_m) * o_m)
           ), 
           deck_size
       )
    end
    
    def run_modulo_techs_iter([], _deck_size, _iterations, _card_loc), do: {0, 1}
    def run_modulo_techs_iter([tech|techs], deck_size, iterations, card_loc) do
        run_modulo_tech(
            tech, 
            deck_size, 
            iterations, 
            card_loc, 
            run_modulo_techs_iter(techs, deck_size, iterations, card_loc)
        )
    end
    
    def run_modulo_tech({:deal_stack}, _deck_size, _iterations, _card_loc, {o_m, i_m}) do
        # o -= i; i *= -1
        {
            o_m - i_m,
            i_m * -1
        }
    end
    
    def run_modulo_tech({:deal_increment, inc}, deck_size, _iterations, _card_loc, {o_m, i_m}) do
        # inv = lambda x: pow(x, c-2, c) 
        # i *= inv(int(s[-1]))  
        {
            o_m,
            i_m * mod_pow(inc, deck_size - 2, deck_size)
        }
    end
    
    def run_modulo_tech({:cut, break}, _deck_size, _iterations, _card_loc, {o_m, i_m}) do
        #   o += i * int(s[-1])
        {
            o_m + (i_m * break),
            i_m
        }
    end
    
    defp mod_pow(x, n, c) do
       :crypto.mod_pow(x, n, c) |> :binary.decode_unsigned()
    end
    
    @doc """
    Deal as a new card stack
    """
    def tech_new_stack(cards) do
        cards |> Enum.reverse()
    end
    
    # @doc """
    # Track a specific card location through a new stack deal.
    #
    # For a new stack, our card location will change to count backwards from
    # where it currently is in the deck.
    # """
    # def tech_s_new_stack(deck_size, card_loc) do
    #     (deck_size - 1) - card_loc
    # end
    
    @doc """
    Cut the deck of cards
    """
    def tech_cut(cards, break) do
        {a, b} = cards |> Enum.split(break)
        b ++ a
    end
    
    # @doc """
   #  Cut the deck of cards by tracking a specific card location through
   #  a stack cut
   #  """
   #  def tech_s_cut(deck_size, break, card_loc) do
   #      # convert the break to a positive number
   #      break = if break < 0 do
   #          deck_size + break
   #      else
   #          break
   #      end
   #
   #      cond do
   #          card_loc < break -> card_loc + (deck_size - break)
   #          card_loc == break -> 0
   #          card_loc > break -> card_loc - break
   #      end
   #  end
    
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