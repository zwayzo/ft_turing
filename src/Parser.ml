open Yojson.Basic.Util

type direction =
  | LEFT
  | RIGHT

type transition = {
  read : char;
  write : char;
  to_state : string;
  action : direction;
}

type machine = {
  name : string;
  alphabet : char list;
  blank : char;
  states : string list;
  initial : string;
  finals : string list;
  transitions : (string * char, transition) Hashtbl.t;
}

let () =
  let json =
    try
      Yojson.Basic.from_file Sys.argv.(1)
    with
    | Sys_error msg ->
        prerr_endline ("Error reading file: " ^ msg);
        exit 1
    | Yojson.Json_error msg ->
        prerr_endline ("Error parsing JSON: " ^ msg);
        exit 1
  in

  (* transitions *)
  let table = Hashtbl.create 100 in

  let trans_json = json |> member "transitions" in
  let assoc = to_assoc trans_json in

  List.iter (fun (state_name, rules_json) ->
    let rules = to_list rules_json in

    List.iter (fun rule ->
      let read =
        rule |> member "read" |> to_string |> fun s -> s.[0]
      in

      let write =
        rule |> member "write" |> to_string |> fun s -> s.[0]
      in

      let to_state =
        rule |> member "to_state" |> to_string
      in

      let action_str =
        rule |> member "action" |> to_string
      in

      let action =
        match action_str with
        | "LEFT" -> LEFT
        | "RIGHT" -> RIGHT
        | _ -> failwith "Invalid action"
      in

      let t = {
        read;
        write;
        to_state;
        action;
      } in

      Hashtbl.add table (state_name, read) t
    ) rules
  ) assoc;

  (* 🔥 parsing normal *)
  let name = json |> member "name" |> to_string in

  let alphabet =
    json |> member "alphabet" |> to_list
    |> List.map to_string
    |> List.map (fun s -> s.[0])
  in

  let blank =
    json |> member "blank" |> to_string |> fun s -> s.[0]
  in

  let states =
    json |> member "states" |> to_list
    |> List.map to_string
  in

  let initial = json |> member "initial" |> to_string in

  let finals =
    json |> member "finals" |> to_list
    |> List.map to_string
  in

  let machine = {
    name;
    alphabet;
    blank;
    states;
    initial;
    finals;
    transitions = table;
  } in

  print_endline machine.name;
  List.iter (fun c -> print_char c; print_char ' ') machine.alphabet;
  print_newline ();
  print_char machine.blank;
  print_newline ();
  List.iter (fun s -> print_string s; print_char ' ') machine.states;
  print_newline ();


  Hashtbl.iter (fun (state, read) t ->
  let action_str =
    match t.action with
    | LEFT -> "LEFT"
    | RIGHT -> "RIGHT"
  in

  print_string "(";
  print_string state;
  print_string ", ";
  print_char read;
  print_string ") -> (";
  print_string t.to_state;
  print_string ", ";
  print_char t.write;
  print_string ", ";
  print_string action_str;
  print_endline ")"
) machine.transitions;
  (* List.iter(fun s -> print_string s; print_char ' ') alphabet; *)
  print_newline ();