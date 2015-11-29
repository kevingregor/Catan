open Player
open Board
open Utilities
open Tile

(* Gamestate module. Holds information and communicates with all modules. *)

(* Stage of the game *)
type stage =
	| Start | Production | Trade | Build | End

(* State of the game *)
type gamestate = {
	playerturn : color;
	players : player list;
	game_board : board;
	game_stage : stage
}

(* Change the turn to a different player *)
val change_turn : gamestate -> gamestate

(* Change the stage of the game *)
val change_stage : gamestate -> gamestate

(* Find the tile corresponding to coordinates *)
val find_tile : gamestate -> coordinates -> tile
(* Add a town to the list of towns on a tile *)
val add_town : gamestate -> tile -> (color*int) -> gamestate
(* Move the robber among tiles *)
val move_robber : gamestate -> gamestate

(* Pick a card out of the list of cards and remove it *)
val pick_card : gamestate -> gamestate
(* Build a road, settlement, city, or dcard *)
val build : gamestate -> string -> gamestate

(* Trade among players/bank *)
val trade : gamestate -> gamestate

(* Have the AI make a move *)
val a_i_makemove : gamestate -> gamestate