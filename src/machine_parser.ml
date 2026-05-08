open Yojson.Basic.Util
open Types

let parse_machine json_file =
  let json =
    try Yojson.Basic.from_file json_file
    with
    | Sys_error msg ->
        prerr_endline ("Error reading file: " ^ msg); exit 1
    | Yojson.Json_error msg ->
        prerr_endline ("Error parsing JSON: " ^ msg); exit 1
  in

  let table = Hashtbl.create 100 in

  let trans_json = json |> member "transitions" in


  let order = ref [] in

  List.iter (fun (state_name, rules_json) ->

    List.iter (fun rule ->
      let read     = (rule |> member "read"     |> to_string).[0] in
      let write    = (rule |> member "write"    |> to_string).[0] in
      let to_state =  rule |> member "to_state" |> to_string in
      let action   = match rule |> member "action" |> to_string with
        | "LEFT"  -> LEFT
        | "RIGHT" -> RIGHT
        | _       -> failwith "Invalid action"
      in

      Hashtbl.add table (state_name, read) { read; write; to_state; action };

      order := !order @ [(state_name, read)]

    ) (to_list rules_json)
  ) (to_assoc trans_json);

  {
    name              = json |> member "name"     |> to_string;
    alphabet          = json |> member "alphabet" |> to_list
                        |> List.map to_string
                        |> List.map (fun s -> s.[0]);
    blank             = (json |> member "blank"   |> to_string).[0];
    states            = json |> member "states"   |> to_list |> List.map to_string;
    initial           = json |> member "initial"  |> to_string;
    finals            = json |> member "finals"   |> to_list |> List.map to_string;
    transitions       = table;
    transitions_order = !order; 
  }