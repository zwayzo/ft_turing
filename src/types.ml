type direction =
  | LEFT
  | RIGHT

type transition = {
  read     : char; 
  write    : char; 
  to_state : string; 
  action   : direction; 
}

type machine = {
  name        : string;
  alphabet    : char list;
  blank       : char;
  states      : string list;
  initial     : string;
  finals      : string list;
  transitions : (string * char, transition) Hashtbl.t;
  transitions_order : (string * char) list;  
}