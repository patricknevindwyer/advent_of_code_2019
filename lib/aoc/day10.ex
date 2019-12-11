defmodule Aoc.Day10 do
    @moduledoc """
     Advent of Code 2019. Day 10. Problem 01/02.
    
     https://adventofcode.com/2019/day/10
    """ 

   def problem01 do
       asteroid_map = asteroid_map_from_file("data/day10/problem_01.map")            
       highest_visibility_asteroid(asteroid_map)
   end
   
   def problem02 do

       asteroid_map = asteroid_map_from_file("data/day10/problem_01.map")            
       {laser_base, _} = highest_visibility_asteroid(asteroid_map)
       
       {bet_x, bet_y} = asteroid_map
       |> vaporization_order(laser_base)
       |> Enum.at(199)
       
       bet_x * 100 + bet_y
   end
   
   @doc """
   Calculate the vaporization order of all of the asteroids in a map, given a
   origin point. This is a circular ordering, with occlusions skipped, going
   in a continuous, looping, clockwise circle from the origin point.
   """
   def vaporization_order([], _asteroid), do: []
   def vaporization_order(asteroid_map, asteroid) do

       # remove occulusions
       unoccluded = remove_occluded(asteroid_map, asteroid)
       
       # order by angle
       ordered_asteroids = order_asteroids_by_angle(unoccluded, asteroid)
       
       # remove from original
       remaining_asteroids = remove_from(asteroid_map, ordered_asteroids ++ [asteroid])
       
       # recurse
       ordered_asteroids ++ vaporization_order(remaining_asteroids, asteroid)
       
   end
   
   def remove_from(list_a, list_b) do
       lbms = MapSet.new(list_b)
       list_a
       |> Enum.reject(fn i -> MapSet.member?(lbms, i) end)
   end
   
   @doc """
   Determine the highest visibility asteroid, and return it's position and
   the number of visible asteroids.
       
   ## Example
   
        iex> highest_visibility_asteroid([])
        {{x, y}, 14}
   """
   def highest_visibility_asteroid(asteroid_map) do
       
       # build a catalog
       catalog = asteroid_catalog_from_map(asteroid_map)
       
       # map every asteroid to highest visibility
       asteroid_map
       
       |> Enum.map(
           fn asteroid -> 
               {asteroid, visible_asteroids(asteroid_map, catalog, asteroid)}
           end
       )
       
       # find the highest visibility item
       |> Enum.max_by(fn {_asteroid, visible} -> visible end)
   end
   
   @doc """
   Sort a catalog of asteroids by the angle from the origin point. The zero angle is
   direclty up, and angle goes clockwise
   
   """
   def order_asteroids_by_angle(asteroid_map, {o_x, o_y}) do
       asteroid_map
       |> Enum.sort_by(
           fn {c_x, c_y} ->
              # this is hella weird, I know. We're modifying the orientation of the atan2 calculation
              # to match the inverted map space, with rotation. Fun times. And we bump the x coordiate
              # ever so slightly so that any atan2(0, _) calculation orders properly.
              :math.atan2((c_x - o_x + 0.001) * -1, (c_y - o_y))
           end
       )
   end
   
   @doc """
   Remove all asteroids from the map that are occluded when viewed from
   the provided asteroid.
   
   
   """
   def remove_occluded(asteroid_map, asteroid) do
       
       asteroid_catalog = asteroid_catalog_from_map(asteroid_map)
       
       asteroid_map
       |> Enum.reject(
           fn field_asteroid ->
               if field_asteroid == asteroid do
                   true
               else
                   occluded?(asteroid, field_asteroid, asteroid_catalog)
               end
           end
       )
       
   end
   
   @doc """
   Determine how many asteroids in the chart are visible from a given point.
   
   ## Example
   
       iex> visible_asteroids([], MapSet{}, {1, 1})
       3
   """
   def visible_asteroids(asteroid_map, asteroid_catalog, asteroid) do
       
       # walk all the ateroids in the map, determine if they're occluded
       asteroid_map
       |> Enum.reject(
           fn field_asteroid ->
               if field_asteroid == asteroid do
                   true
               else
                   occluded?(asteroid, field_asteroid, asteroid_catalog)
               end
           end
       )
       |> length()
   end
   
   @doc """
   Determine if the line from candidate point {c_x, c_y} to the origin
   point {o_x, o_y} is occluded by anything in the catalog. The catalog
   is a mapset of points in {x, y} form.
   """
   def occluded?({o_x, o_y}=origin, {c_x, c_y}=candidate, catalog) when is_map(catalog) do
       
       # determine the slope between the candidate and origin
       {s_x, s_y} = {o_x - c_x, o_y - c_y}
       
       # reduce slope fraction
       {r_x, r_y} = reduce_fraction({s_x, s_y})

       # generate the intersection points of whole numbered fraction steps
       # between canddiate and origin
       points_between(candidate, origin, {r_x, r_y})
       
       # check catalog for any occlusions
       |> Enum.filter(fn point -> MapSet.member?(catalog, point) end)
       
       # any occlusions?
       |> length() > 0
       
   end
   
   @doc """
   Build out the steps between the candidate and origin given the
   fractional slope. The end result is a list of points, not including
   either the candidate or origin.
   
   ## Examples
   
       iex> points_between({5, 5}, {3, 3}, {1, 1})
       [{4, 4}]
   """
   def points_between({c_x, c_y}, {o_x, o_y}, {s_x, s_y}) do
       
       {t_x, t_y} = {c_x + s_x, c_y + s_y}
       
       if {t_x, t_y} == {o_x, o_y} do
           []
       else
           [{t_x, t_y}] ++ points_between({t_x, t_y}, {o_x, o_y}, {s_x, s_y})
       end
   end
   
   def asteroid_catalog_from_map(amap) do
       MapSet.new(amap)
   end
   
   @doc """
   Load an asteroid map from file. The map format, when returned, is a list
   of tuples in {x, y} format, indicating the position of asteroids in the map
   area.
   
   Keep in mind that in asteroid map space, the origin is the TOP LEFT, like
   pixel space.
   """
   def asteroid_map_from_file(filename) do
       
       filename
       
       # load the file, breaking into lines
       |> File.read!()
       |> String.split("\n")
       
       # iterate each line with a row index (our Y value)
       |> Enum.with_index()
       |> Enum.map(
           fn {line, row_idx} ->
               
               # break the line into characters
               line
               |> String.codepoints()
               
               # iterate each character with a column index (our X value)
               |> Enum.with_index()
               |> Enum.map(
                   fn {c, col_idx} ->
                       {c, col_idx, row_idx}
                   end
               )
           end
       )
       
       # flatten our list
       |> List.flatten()
       
       # now filter out anything that isn't an asteroid
       |> Enum.reject(fn {c, _, _} -> c == "." end)
       
       # and map to just coordinates
       |> Enum.map(fn {_, x, y} -> {x, y} end)
   end
   
   @doc """
   Reduce a fraction to it's simplified form.
   
   ## Examples
   
       iex> reduce_fraction({2, 4})
       {1, 2}
   """
   def reduce_fraction({num, den}) do
      d = Integer.gcd(num, den)
      {Kernel.trunc(num / d), Kernel.trunc(den / d)} 
   end 
end