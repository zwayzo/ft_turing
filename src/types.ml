type direction =
  | LEFT
  | RIGHT

type transition = {
  read     : char; (* caractère lu sous la tête *)
  write    : char; (* caractère à écrire *)
  to_state : string; (* nouvel état après la transition *)
  action   : direction; (* direction de déplacement *)
}

type machine = {
  name        : string;
  alphabet    : char list;
  blank       : char;
  states      : string list;
  initial     : string;
  finals      : string list;
  transitions : (string * char, transition) Hashtbl.t;
  transitions_order : (string * char) list;  (* ordre original du JSON *)
}