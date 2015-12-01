open Player
open Board
open Utilities
open Tile
open Dcard

(* Gamestate module. Holds information and communicates with all modules. *)

(* Stage of the game *)
type stage =
	| Start | Production | Trade | Build | End

(* State of the game *)
type gamestate = {
<<<<<<< HEAD
<<<<<<< HEAD
	playerturn : color;
	players : player list;
	game_board : board;
	game_stage : stage;
=======
=======
>>>>>>> 612645b139cab8dadcfa3221e49000752061ea36
  playerturn : color;
  players : player list;
  game_board : board;
  game_stage : stage;
<<<<<<< HEAD
>>>>>>> 612645b139cab8dadcfa3221e49000752061ea36
=======
>>>>>>> 612645b139cab8dadcfa3221e49000752061ea36
  longest_road_claimed : bool;
  largest_army_claimed : bool
}


(* Change the turn to a different player *)
val change_turn : gamestate -> gamestate

(* Change the stage of the game *)
val change_stage : gamestate -> gamestate

(* Add a town to the list of towns on a tile *)
val add_town : gamestate -> tile -> (color*int) -> gamestate
(* play a given dcard in the current gamestate*)
val play_dcard : gamestate -> dcard -> gamestate
(* Move the robber among tiles *)
val move_robber : gamestate -> gamestate

(* Pick a card out of the list of cards and remove it *)
val pick_dcard : gamestate -> gamestate
(* Build a road, settlement, city, or dcard *)
val build : gamestate -> string -> gamestate

(* Trade among players/bank *)
val trade : gamestate -> gamestate

(* Have the AI make a move *)
val a_i_makemove : gamestate -> gamestate

val change_player : gamestate -> player -> gamestate