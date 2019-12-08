defmodule Aoc.Day08 do
    @moduledoc """
    Advent of Code 2019. Day 08. Problem 01/02.
    
    https://adventofcode.com/2019/day/8
    """
    
    def problem01() do
       
        # load our image
        sif_image = load_image("data/day08/image01.txt") 
        
        # determine which layer has the fewest zeroes
        zero_by_layer = sif_image
        |> Enum.map(
            fn layer ->
                layer
                |> Enum.filter(fn v -> v == 0 end)
                |> length()
            end
        )
        
        fewest_zeroes = zero_by_layer |> Enum.min()
        layer_idx = zero_by_layer |> Enum.find_index(fn v -> v == fewest_zeroes end)
        
        # pull out the layer, and group values so we can count 1's and 2's
        layer = sif_image |> Enum.at(layer_idx)
        pixel_groups = layer |> Enum.group_by(fn p -> p end)
        
        length(Map.get(pixel_groups, 1)) * length(Map.get(pixel_groups, 2))
        
    end
    
    def problem02() do
    
        "data/day08/image01.txt"
        |> load_image()
        |> flatten_image()
        |> display_image()
    end
    
    @doc """
    Load a Space Image Format file, and return the decoded layer data.
    
    ## Example
    
        iex> "path/to/file.txt" |> load_image()
        [ [0, 1, 0, 1, ...], [1, 2, 0, 1, 2, ...], ...]
    """
    def load_image(filename, width \\ 25, height \\ 6) do
        
        # the raw data is a list of characters, but it has a leading and trailing part we don't want
        raw = filename
        |> File.read!()
        |> String.trim()
        
        # break apart into single characters that we can decode, removing the first and last entries
        |> String.split("")
        
        # now convert the raw data into a list of integers, trimmed to the right size
        raw
        |> Enum.slice(1..length(raw) - 2)
        |> Enum.map(
            fn str_digit ->
                {v, _} = Integer.parse(str_digit)
                v
            end
        )
        
        # and parse into layers
        |> take_chunks(width, height)
        
    end
    
    @doc """
    The layers of our image will have pixel values of 0, 1, or 2. 2 is transparent, 0 is black,
    and 1 is white. To flatten our image, we put the image layers over one another, first layer
    on top, next layer behind, etc. The computed (or flattened) value of the pixel is the first
    non-2 value in a layer for that pixel location.
    
    ## Example
    
        iex> [ [1, 0, 2, ...], ...] |> flatten_image()
        [1, 0, 1, 1, 0, 1, ...]
    """
    def flatten_image(layers) do
    
        layers
        |> Enum.zip()
        |> Enum.map(
            fn pixel_set ->
                pixel_set
                |> Tuple.to_list()
                |> Enum.drop_while(fn p -> p == 2 end)
                |> List.first()
            end
        )
    end
    
    @doc """
    An image isn't a whole lot of help if we can't see it. This will display a flattened
    SIF image via STDOUT.
    
    ## Example
    
        iex> flat_data |> display_image()
         ▊▊  ▊   ▊▊  ▊  ▊▊  ▊  ▊ 
        ▊  ▊ ▊   ▊▊  ▊ ▊  ▊ ▊  ▊ 
        ▊     ▊ ▊ ▊  ▊ ▊  ▊ ▊▊▊▊ 
        ▊      ▊  ▊  ▊ ▊▊▊▊ ▊  ▊ 
        ▊  ▊   ▊  ▊  ▊ ▊  ▊ ▊  ▊ 
         ▊▊    ▊   ▊▊  ▊  ▊ ▊  ▊ 
    """
    def display_image(layer, width \\ 25) do
       
       layer
       |> take_chunks(width, 1)
       |> Enum.each(
           fn row -> 
               row
               |> Enum.map(
                   fn pixel ->
                       if pixel == 1 do
                           IO.write("▊")
                       else
                           IO.write(" ")
                       end
                   end
               )
               IO.write("\n")
           end
       ) 
    end
    
    @doc """
    Break an enumerable into list of lists. The sub-list size is the
    width * height.
    
    ## Example
    
        iex> [1, 2, 3, 4, 5, 6, 7, 8] |> take_chunks(2, 2)
        [ [1, 2, 3, 4], [5, 6, 7, 8] ]
    """
    def take_chunks([], _w, _h), do: []
    def take_chunks(d, w, h) when is_list(d) do
       [Enum.take(d, w * h)] ++ take_chunks(Enum.drop(d, w * h), w, h)
    end

end