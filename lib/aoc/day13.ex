defmodule Aoc.Day13 do
    @moduledoc """
    Advent of Code 2019. Day 13. Problem 01/02.
    
    https://adventofcode.com/2019/day/13
    
    TODO: input function to move paddle

    """ 
    
    alias Aoc.Intcode
    
    def problem01 do
        
        # load the arcade program and run it
        "data/day13/rom.ic"
        |> Intcode.program_from_file()
        |> run_arcade()
        |> draw_screen()
        |> block_count()

        
    end
    
    def problem02 do
        
        # load the arcade program and run it
        game_res = "data/day13/rom.ic"
        |> Intcode.program_from_file()
        
        # write two quarters to memory address 0 for free-play
        |> Intcode.memory_write(0, 2)
        
        # run our program
        |> run_arcade()
        
        # draw the result
        |> draw_screen()
        
        # and print the score
        IO.puts("Score: #{game_res.settings.score}")
        
    end
    
    @doc """
    Run an arcade program in self-playing mode.
    """
    def run_arcade(program) do
        
        # setup our program state, with a game screen 80 pixels wide, 40 tall
        game = create_game_state(80, 40)
        
        # run the program
        Intcode.run(
            program, 
            [
                memory_size: 8000,
                input_function: Intcode.send_for_input(self()),
                await_with: 
                    fn -> 
                        Intcode.await_io(game, output_function: &handle_game_instruction/2, output_count: 3, input_function: &handle_game_input/1)
                    end
            ]
        )
        
    end
    
    @doc """
    We want to handle the input for the game. Moving the paddle is done with a -1 (move left), 0 (stay in place),
    or 1 (move right). We want to automatically track the ball, and move so we're underneath it.
    
    """
    def handle_game_input(game_state) do
                
        {ball_x, _} = game_state |> find_coord_of(4)
        {pad_x, _} = game_state |> find_coord_of(3)
        
        cond do
           ball_x < pad_x -> -1
           pad_x < ball_x -> 1
           true -> 0 
        end
    end
    
    @doc """
    Find a specific pixel on screen, and return the {x, y} coordinate.
    """
    def find_coord_of(game_state, pixel_value) do
        
        idx = game_state.screen |> List.flatten() |> Enum.find_index(fn v -> v == pixel_value end)
        
        y = Kernel.trunc(idx / game_state.settings.screen_height)
        x = rem(idx, game_state.settings.screen_width)
        {x, y}
    end
    
    @doc """
    Handle pixel instructions for our game. The three values should be
    
     - `[-1, 0, value]` - set the game score
     - `[x, y, tile]` - set a tile value at a specific screen location
    
    As part of the instruction cycle, the game screen is printed out every 100 screen
    updates.
    """
    def handle_game_instruction(game_state, [x, y, p]) do
        
        if rem(game_state.steps, 100) == 0 do
            draw_screen(game_state)
        end
        
        if (x == -1) and (y == 0) do
                        
            # set the game score
            {
                :continue,
                %{
                    screen: game_state.screen,
                    settings: %{game_state.settings | score: p},
                    steps: game_state.steps + 1
                }
            }

        else 
            
            # set a tile 
            
            if !pixel_in_screen?(game_state, x, y) do
                IO.puts("Intcode MAME error: pixel out of bounds (#{x}, #{y})")
            end
            
            # update the screen
            {
                :continue, 
                %{
                    screen: Kernel.update_in(game_state.screen, [Access.at(y), Access.at(x)], fn _ -> p end),
                    settings: game_state.settings,
                    steps: game_state.steps + 1
                }
            }            
        end
    end
    
    @doc """
    Check that the pixel we're trying to access is within screen bounds
    """
    def pixel_in_screen?(game_state, x, y) do
        (x >= 0) && (x < game_state.settings.screen_width) && (y >= 0) && (y < game_state.settings.screen_height)
    end
    
    @doc """
    Retrieve a specific pixel value.
    """
    def pixel_at(game_state, x, y) do
       Kernel.get_in(game_state.screen, [Access.at(y), Access.at(x)]) 
    end
    
    @doc """
    Count the total number of non-blank pixels on screen.
    """
    def pixel_count(game) do
       game.screen
       |> List.flatten()
       |> Enum.filter(fn p -> p > 0 end)
       |> length() 
    end
    
    @doc """
    Count the total number of "block" tiles on screen
    """
    def block_count(game) do
        game.screen
        |> List.flatten()
        |> Enum.filter(fn p -> p == 2 end)
        |> length() 
    end
    
    @doc """
    Draw the game screen
    """
    def draw_screen(game_state) do
        tiles = %{0 => " ", 1 => "▊", 2 => "=", 3 => "-", 4 => "*"}
        
        game_state.screen
        |> Enum.each(
            fn row -> 
                row
                |> Enum.each(
                    fn pixel ->
                        tiles |> Map.get(pixel) |> IO.write()
                    end
                )
                IO.write("\n")
            end
        )
        game_state
    end

    @doc """
    Create the game state tracking structure
    """
    def create_game_state(w, h) do
       board = 1..h
       |> Enum.map(
           fn _y -> 
               1..w
               |> Enum.map(
                   fn _x -> 
                       0
                   end
               )
           end
       ) 
       
       %{
           screen: board,
           settings: %{
               screen_width: w,
               screen_height: h,
               score: 0
           },
           steps: 0
       }
    end
    
end