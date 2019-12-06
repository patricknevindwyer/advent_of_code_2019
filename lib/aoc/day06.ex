defmodule Aoc.Day06 do

    @moduledoc """
    Advent of Code 2019. Day 06. Problem 01/02.
    
    https://adventofcode.com/2019/day/6
    """
   
    def problem01() do
    
        # load our orbits from a file (data/day06/orbits.txt)
        orbits = "data/day06/orbits.txt"
        |> File.read!()
        |> String.split("\n")
        
        # build our catalog and compute a checksum
        orbits
        |> build_orbit_map()
        |> catalog_checksum()
    end
    
    def problem02() do
    
        # load orbits and build a map
        # load our orbits from a file (data/day06/orbits.txt)
        orbits = "data/day06/orbits.txt"
        |> File.read!()
        |> String.split("\n")
        
        # build our catalog and compute a checksum
        catalog = orbits
        |> build_orbit_map()
        
        # find what YOU and SAN orbit
        body_a = catalog |> Map.get("YOU")
        body_b = catalog |> Map.get("SAN")
        
        # how many transfers are we doing?
        catalog |> min_transfers(body_a, body_b)
    end
    
    @doc """
    Convert a list of orbital strings into an orbit catalog.
    
    ## Example
    
        iex> ["COM)A", "A)B", "COM)C"] |> build_orbit_map()
        %{"A" => "COM", "B" => "A", "C" => "COM"}
        
    """
    def build_orbit_map(orbit_list) when is_list(orbit_list) do
       orbit_list 
       |> Map.new(&parse_orbit/1) 
    end
    
    @doc """
    Parse an orbital string to build an {satellite, body} tuple.
    
    ## Example
        
        iex> parse_orbit("B)C")
        {"C", "B"}
    """
    def parse_orbit(orbit_string) do
       [host, guest] = orbit_string |> String.split(")") 
       {guest, host}
    end
    
    @doc """
    How many direct and indirect objects is a body orbiting?
    
    ## Example
    
        iex> catalog |> orbit_checksum("B")
        1
    
        iex> catalog |> orbit_checksum("I")
        4
    """
    def orbit_checksum(catalog, body) do
       if body == "COM" do
           0
       else
           1 + orbit_checksum(catalog, Map.get(catalog, body))
       end 
    end
    
    @doc """
    Find the path between a body and COM, returning a list of orbital
    bodies.
    
    ## Example
    
        iex> %{"A" => "COM", "B" => "A"} |> path_to_com("B")
        ["B", "A", "COM"]
    
    """
    def path_to_com(catalog, body) do
    
        if body == "COM" do
            ["COM"]
        else
            [body] ++ path_to_com(catalog, Map.get(catalog, body))
        end
        
    end
    
    @doc """
    A catalog checksum is the sum total of orbit_checksums for all
    orbiting bodies in the catalog.
    
    ## Example
    
        iex> catalog |> catalog_checksum()
        42
    """
    def catalog_checksum(catalog) do
       
       catalog
       |> Map.keys()
       |> Enum.map(
           fn body ->
               orbit_checksum(catalog, body)
           end
       ) 
       |> Enum.sum()
    end
    
    @doc """
    What is the minimum number of orbital transfers to move from an
    orbit around body A to an orbit around body B? Since we know this is
    a well built directed graph, we do a dead simple intersection calculation
    instead of a spanning tree.
    
    ## Example
    
        iex> catalog |> min_transfers("K", "I")
        4
    
    """
    def min_transfers(catalog, body_a, body_b) do
        
        body_a_path = catalog |> path_to_com(body_a)
        body_b_path = catalog |> path_to_com(body_b)
        
        # now find the offset of each of the body_a_path entries in body_b,
        # and only keep ones that have an index, then finding the smallest
        # index
        intercept_idx = body_a_path
        |> Enum.map(
            fn body ->
                body_b_path |> Enum.find_index(fn v -> v == body end)
            end
        )
        |> Enum.reject(fn v -> v == nil end)
        |> Enum.min()
        
        intercept_body = Enum.at(body_b_path, intercept_idx)

        # we have an intercept body, calculate the index in each list, and add one
        # for final transfer
        a_transfers = Enum.find_index(body_a_path, fn o -> o == intercept_body end)
        b_transfers = Enum.find_index(body_b_path, fn o -> o == intercept_body end)
        
        a_transfers + b_transfers
    end
end