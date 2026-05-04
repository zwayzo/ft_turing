open Yojson.Basic.Util
open Types

let parse_machine json_file =
  (* Charge et parse le fichier JSON depuis le disque *)
  let json =
    try Yojson.Basic.from_file json_file
    with
    | Sys_error msg ->
        prerr_endline ("Error reading file: " ^ msg); exit 1
    | Yojson.Json_error msg ->
        prerr_endline ("Error parsing JSON: " ^ msg); exit 1
  in

  (* Table de hachage : (état, caractère_lu) -> transition *)
  let table = Hashtbl.create 100 in

  let trans_json = json |> member "transitions" in

  (* Garde l'ordre original des transitions tel qu'il apparait dans le JSON *)
  (* car la hashtable ne preserve pas l'ordre d'insertion *)
  let order = ref [] in

  (* Parcourt chaque état et ses règles de transition *)
  List.iter (fun (state_name, rules_json) ->

    (* Parcourt chaque règle de transition pour cet état *)
    List.iter (fun rule ->
      let read     = (rule |> member "read"     |> to_string).[0] in
      let write    = (rule |> member "write"    |> to_string).[0] in
      let to_state =  rule |> member "to_state" |> to_string in
      let action   = match rule |> member "action" |> to_string with
        | "LEFT"  -> LEFT
        | "RIGHT" -> RIGHT
        | _       -> failwith "Invalid action"
      in

      (* Insère la transition dans la hashtable avec la clé (état, char_lu) *)
      Hashtbl.add table (state_name, read) { read; write; to_state; action };

      (* Mémorise la clé dans l'ordre d'apparition pour l'affichage du header *)
      order := !order @ [(state_name, read)]

    ) (to_list rules_json)
  ) (to_assoc trans_json);

  (* Construit et retourne le record machine complet *)
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
    transitions_order = !order; (* ordre préservé pour l'affichage *)
  }