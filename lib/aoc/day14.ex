defmodule Aoc.Day14 do
    @moduledoc """
    Advent of Code 2019. Day 14. Problem 01/02.
    
    https://adventofcode.com/2019/day/14
    """
    
    def problem01 do
        reactions_from_file("data/day14/problem_01.chems")
        |> ore_requirements(%{"FUEL" => 1})
    end
    
    def problem02 do
        reactions_from_file("data/day14/problem_01.chems")
        |> maximize_fuel(1000000000000)
    end
    
    @doc """
    Try and maximize the fuel we can create for a target amount of ore
    """
    def maximize_fuel(reactions, ore, last_fuel \\ 1, current_fuel \\ 2) do
        
        # determine what the last and current look like for ore requirements
        curr_ore = ore_requirements(reactions, %{"FUEL" => current_fuel})
        
        if curr_ore < ore do
            # double our fuel target
            maximize_fuel(reactions, ore, current_fuel, current_fuel * 2)
        else
            
            # since we're over our fuel usage, see if last and current are within
            # one of each other
            if (current_fuel - last_fuel) == 1 do
                last_fuel
            else
                # we're over our fuel usage - pick a mid point between our current and
                # last, and check that
                mid_fuel = Kernel.trunc((current_fuel - last_fuel) / 2) + last_fuel
            
                # see where that mid point gets us
                mid_ore = ore_requirements(reactions, %{"FUEL" => mid_fuel})
                
                cond do
                   mid_ore < ore -> maximize_fuel(reactions, ore, mid_fuel, current_fuel)
                   mid_ore > ore -> maximize_fuel(reactions, ore, last_fuel, mid_fuel)
                   true -> mid_fuel
                end
            end
        end
    end
    
    @doc """
    Recursively calculate the number of required ore by walking through our list of
    chemicals, which tracks the required number of each checmical so far. In the end
    only ORE should be in the chems map, at which point we can return.
    """
    def ore_requirements(reactions, chems, extras \\ %{}) when is_list(reactions) and is_map(chems) do
        
        if Map.keys(chems) == ["ORE"] do
            # we're done, return our ORE count
            chems |> Map.get("ORE")
        else
            # pick a non-ORE chem off the list of keys, and figure out how we make it. Keep track
            # of the updated list of chemicals we need to build
            chem_name = chems |> Map.keys() |> Enum.reject(fn k -> k == "ORE" end) |> List.first()
            {chem_quant, new_chems} = chems |> Map.pop(chem_name)
            
            # find the formula for producing what we want
            formula = reactions 
            |> Enum.filter(
                fn %{chemical: {c, _}} -> 
                    c == chem_name
                end
            )
            |> List.first()
            
            # do we have any extra of the chemical we need sitting around? Not all of our reactions
            # produce exact quantities, we have stuff left over, which we need to account for
            {extras, chem_quant} = if Map.has_key?(extras, chem_name) do
                
                extra_quant = extras |> Map.get(chem_name)
                
                if extra_quant <= chem_quant do
                    # we'll need to remove the chem entirely from extras
                    {Map.delete(extras, chem_name), chem_quant - extra_quant}
                else
                    # we'll still have extra left over
                    {Map.put(extras, chem_name, extra_quant - chem_quant), 0}
                end
                
            else
                {extras, chem_quant}
            end
            
            # determine how many of each reagent we need
            {new_reagents, extra_chem} = reagents_for(formula, chem_quant)
            
            # add extra chemicals to our tracking, if they exist
            extras = if extra_chem > 0 do
                if Map.has_key?(extras, chem_name) do
                    Map.update(extras, chem_name, extra_chem, fn current_extra -> current_extra + extra_chem end)
                else
                    Map.put(extras, chem_name, extra_chem)
                end
            else
                extras
            end 
                        
            # now blend the new reagents into our existing new_chems list
            ore_requirements(
                reactions,
                Map.merge(new_chems, new_reagents |> Map.new(), fn _chem, q_a, q_b -> q_a + q_b end),
                extras
            )
        end
    end
    
    @doc """
    Given a chemical reaction and a quantity of that checmical, determine how many of each
    component reagent we need. The list returns tuples of chem name and quantity.
    """
    def reagents_for(%{chemical: {_, produced}, reagents: reagents}, quant) do
        
        # how many multiples of this chemical do we need?
        multiples = (quant / produced) |> Float.ceil() |> Kernel.trunc()
        
        # determine the reagents we need
        total_reagents = reagents |> Enum.map(fn {chem, r_quant} -> {chem, r_quant * multiples} end)
        
        # how many extra of our source chemical did we create?
        extra = (produced * multiples) - quant
        
        {total_reagents, extra}
    end
    
    @doc """
    Build a list of reactions from a file.
    """
    def reactions_from_file(filename) do
        filename
        |> File.read!()
        |> String.split("\n")
        |> Enum.map(&parse_reaction/1)
    end
    
    @doc """
    A reaction is encoded in the form:
        
        12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
    
    Which we need to translate into:
        
        %{ chemical: {"QDVJ", 9}, reagents: [ {"HKGWZ", 12}, {"GPVTF", 1}, {"PSHF", 8} ]}
    """
    def parse_reaction(str) do
        
        [agents, output] = str |> String.split("=>") |> Enum.map(&String.trim/1)
        
        %{
            chemical: output |> parse_chem_notation(),
            reagents: agents |> String.split(",") |> Enum.map(&parse_chem_notation/1)
        }
    end
    
    @doc """
    Parse a simple chemical notation of the form:
        
        8 FUEL
    
    into the tuple
    
        {"FUEL", 8}
    """
    def parse_chem_notation(str) do
        [quant, chem] = str |> String.trim() |> String.split(" ")
        {q, _} = quant |> Integer.parse()
        {chem, q}
    end
    
end
