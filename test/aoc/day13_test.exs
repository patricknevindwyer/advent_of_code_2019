defmodule AocTest.Day13 do
    use ExUnit.Case
    
    import Aoc.Day13
    
    describe "game instructions" do
        
        test "two instructions" do
            
            # setup game state
            game = create_game_state(20, 20)
            
            # run some instructions
            {:continue, game} = handle_game_instruction(game, [1, 2, 3])
            assert game |> pixel_at(1, 2) == 3
            
            {:continue, game} = handle_game_instruction(game, [6, 5, 4])
            assert game |> pixel_at(6, 5) == 4
            
        end
        
        test "screen count" do

            # setup game state
            game = create_game_state(20, 20)
            
            # run some instructions
            {:continue, game} = handle_game_instruction(game, [1, 2, 3])
            {:continue, game} = handle_game_instruction(game, [6, 5, 4])
            
            assert game |> pixel_count() == 2
        end
        
        test "find_coord_of/2" do
           
           {:continue, game} = create_game_state(40, 40) |> handle_game_instruction([10, 17, 4])
           
           assert game |> find_coord_of(4) == {10, 17}
            
        end
    end

end
