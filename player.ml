open Utilities
open Dcard
open Town

(* Mutable variables used for the search algorithms which back
our AI. *)
type a_i_variables = {
  mutable curpos : coordinates;
  mutable left : int;
  mutable right : int;
  mutable up : int;
  mutable down : int
}

(* Stores all specific information about a single player.
The only duplication of this data is in tiles, where the
towns are represented again to make resource distribution
easier.*)
type player = {
  roads_left : int;
  roads : (coordinates * coordinates) list;
  settlements_left : int;
  cities_left : int;
  towns : town list;
  victory_points : int;
  dcards : dcard list;
  resources : rsrc;
  exchange : rsrc;
  color : color;
  a_i : bool;
  ai_vars : a_i_variables;
  army_size : int;
  largest_army : bool;
  road_size : int;
  longest_road : bool
}

(* Automatically finds the old version of the provided player based on
color and replacees them. *)
let rec change_player_list (lst: player list) (plyr: player) : player list =
  match lst with
  | h::t -> if h.color = plyr.color then plyr::t
            else h::(change_player_list t plyr)
  | [] -> []

(* Pull a single resource out of the 5-tuple. *)
let split_resource (r:rsrc) (resource: int) : int =
  match (resource, r) with
  | 0, (x,_,_,_,_) -> x (* Brick *)
  | 1, (_,x,_,_,_) -> x (* Wool *)
  | 2, (_,_,x,_,_) -> x (* Ore *)
  | 3, (_,_,_,x,_) -> x (* Grain *)
  | 4, (_,_,_,_,x) -> x (* Lumber *)
  | _ -> failwith "Invalid resource index."

(* Get a specified resource from a player *)
let get_resource (plyr: player) (resource: int) : int =
  split_resource plyr.resources resource

(* Get a specified trade exchange rate from a player *)
let get_exchange (plyr: player) (resource: int) : int =
  split_resource plyr.exchange resource

(* Change the specified resource by amt. *)
let change_resource (plyr: player) (resource: int) (amt: int) : player =
  match (resource, plyr.resources) with
  | 0, (a,x,y,z,w) -> {plyr with resources = (a+amt,x,y,z,w)}
  | 1, (x,a,y,z,w) -> {plyr with resources = (x,a+amt,y,z,w)}
  | 2, (x,y,a,z,w) -> {plyr with resources = (x,y,a+amt,z,w)}
  | 3, (x,y,z,a,w) -> {plyr with resources = (x,y,z,a+amt,w)}
  | 4, (x,y,z,w,a) -> {plyr with resources = (x,y,z,w,a+amt)}
  | _ , _          -> failwith "Change_resource parameters not met"

(* Change multiple resources at once with a 5-tuple representing
the overall change. *)
let change_resources (plyr: player) (amt: rsrc) : player =
  let (a,b,c,d,e) = plyr.resources in
  let (d1,d2,d3,d4,d5) = amt in
  {plyr with resources=(a+d1,b+d2,c+d3,d+d4,e+d5)}

(* Update the owner of the largest army point bonus. *)
let rec update_largest_army (players: player list) (changing_player: player) =
  match players with
  | [] -> []
  | h::t -> if h.color = changing_player.color then
              changing_player::(update_largest_army t changing_player)
            else
              if h.largest_army then
                if changing_player.army_size > h.army_size then
                  let plyr = {h with victory_points = h.victory_points - 2;
                                     largest_army = false} in
                  plyr::t
                else
                  h::t
              else
                h::(update_largest_army t changing_player)

(* Initialize a human player *)
let init_non_ai_player (c:color) = {roads_left = 15; roads = [];
  settlements_left = 5; cities_left = 4; towns = []; victory_points = 0;
  dcards = []; resources = (0,0,0,0,0); exchange = (4,4,4,4,4);
  color = c; a_i = false; ai_vars = {curpos = (0,0); left = 0; right = 0; up =0;
  down = 0}; army_size = 0; largest_army = false;
  road_size = 0; longest_road = false}

(* Initialize a computer player. *)
let init_ai_player (c:color) = {roads_left =15; roads = []; settlements_left =5;
  cities_left = 4; towns = []; victory_points = 0;
  dcards = []; resources = (0,0,0,0,0); exchange = (4,4,4,4,4);
  color = c; a_i = true; ai_vars = {curpos = (0,0); left = 0; right = 0; up = 0;
  down = 0}; army_size = 0; largest_army = false;
  road_size = 0; longest_road = false}
(* Initialize all four players as humans. *)
let initialize_non_ai_players () =
  [init_non_ai_player Red; init_non_ai_player Blue;
  init_non_ai_player White; init_non_ai_player Orange]

(* Initialize 3 ai and 1 human player. *)
let initialize_single_player () =
  [init_non_ai_player Red; init_ai_player Blue;
    init_ai_player White; init_ai_player Orange]

(* Initialize 2 ai and 2 human players. *)
let initialize_2_ai_players () =
  [init_non_ai_player Red; init_non_ai_player Blue;
    init_ai_player White; init_ai_player Orange]

(* Initialize 1 ai and 3 human players. *)
let initialize_1_ai_player () =
  [init_non_ai_player Red; init_non_ai_player Blue;
    init_non_ai_player White; init_ai_player Orange]

(* Initialize all 4 players as ai. *)
let initialize_all_ai_players () =
  [init_ai_player Red; init_ai_player Blue;
    init_ai_player White; init_ai_player Orange]

(* Initialize the stated number of ai players. *)
let initialize_ai_players (num:int) =
  if num = 0 then initialize_non_ai_players ()
  else if num = 1 then initialize_1_ai_player ()
  else if num = 2 then initialize_2_ai_players ()
  else if num = 3 then initialize_single_player ()
  else initialize_all_ai_players ()

(* Checks whether a specified coordinate pair has a road on it. *)
let is_road (road: coordinates * coordinates) (plyrs:player list): bool =
  let (a,b) = road in
  let rec check_all_players (players: player list) =
  (match players with
  |h::t -> if ((List.mem road h.roads) || (List.mem (b,a) h.roads)) ||
            not(in_bounds a) || not(in_bounds b)
            then true
          else check_all_players t
  |[] -> false) in
  check_all_players plyrs

(* Check whether a given corner has an unbuilt road edge touching it. *)
let corner_can_expand (coord: coordinates) (plyrs: player list) : bool =
if (fst coord) mod 2 = 0 then
  not(is_road (coord, ((fst coord) + 1, snd coord)) plyrs) ||
  not(is_road (coord, ((fst coord) - 1, snd coord)) plyrs) ||
  not(is_road (coord, ((fst coord) + 1, (snd coord) + 1)) plyrs)
else
  not(is_road (coord, ((fst coord) + 1, snd coord)) plyrs) ||
  not(is_road (coord, ((fst coord) - 1, snd coord)) plyrs) ||
  not(is_road (coord, ((fst coord) - 1, (snd coord) - 1)) plyrs)

(* Move the search cursor for a given player's ai. *)
let rec curpos_change(roads: (coordinates * coordinates) list) (plyr: player)
  (plyrs: player list): (bool*player) =
  match roads with
  | [] -> (false, plyr)
  | h::t -> if corner_can_expand (fst h) plyrs then
              let _ = plyr.ai_vars.curpos <- fst h in
                (true, plyr)
            else
              if corner_can_expand (snd h) plyrs then
                let _ = plyr.ai_vars.curpos <- snd h in
                (true, plyr)
              else
                curpos_change t plyr plyrs
