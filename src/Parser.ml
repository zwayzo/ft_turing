
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
}



let () =
    let json = Yojson.Basic.from_file Sys.argv.(1) in
    let name =
        json |> Yojson.Basic.Util.member "name" |> Yojson.Basic.Util.to_string in
    let alphabet =
        json
        |> Yojson.Basic.Util.member "alphabet"
        |> Yojson.Basic.Util.to_list
        |> List.map Yojson.Basic.Util.to_string
        |> List.map (fun s -> s.[0]) in
    
    let blank =
        json |> Yojson.Basic.Util.member "blank" |> Yojson.Basic.Util.to_string |> fun s -> s.[0] in

    let states =
        json
        |> Yojson.Basic.Util.member "states"
        |> Yojson.Basic.Util.to_list
        |> List.map Yojson.Basic.Util.to_string in
    
    let initial =
        json |> Yojson.Basic.Util.member "initial" |> Yojson.Basic.Util.to_string in

    let finals =
        json
        |> Yojson.Basic.Util.member "finals"
        |> Yojson.Basic.Util.to_list
        |> List.map Yojson.Basic.Util.to_string

  in
  print_endline name;
  List.iter (fun c -> print_char c; print_char ' ') alphabet;
  print_endline ""