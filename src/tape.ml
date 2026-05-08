open Types


let make_tape (input : string) : (int, char) Hashtbl.t =
  let tape = Hashtbl.create 64 in
  String.iteri (fun i c -> Hashtbl.replace tape i c) input;
  tape


let tape_read (tape : (int, char) Hashtbl.t) (pos : int) (blank : char) : char =
  match Hashtbl.find_opt tape pos with
  | Some c -> c
  | None   -> blank


let tape_write (tape : (int, char) Hashtbl.t) (pos : int) (c : char) (blank : char) : unit =
  if c = blank then Hashtbl.remove tape pos  
  else Hashtbl.replace tape pos c

let tape_snapshot (tape : (int, char) Hashtbl.t) (blank : char) : (int * char) list =
  Hashtbl.fold (fun k v acc -> if v <> blank then (k, v) :: acc else acc) tape []
  |> List.sort (fun (a, _) (b, _) -> compare a b)



let display_tape (tape : (int, char) Hashtbl.t) (head : int) (blank : char) (trans_str : string) : unit =
  let positions = Hashtbl.fold (fun k _ acc -> k :: acc) tape [] in
  let min_pos = List.fold_left min head positions in
  let max_pos = List.fold_left max head positions in
  let min_pos = min_pos - 3 in
  let max_pos = max_pos + 13 in
  print_char '[';
  for i = min_pos to max_pos do
    let c = tape_read tape i blank in
    if i = head then
      Printf.printf "\027[31m%c\027[0m" c
    else
      print_char c
  done;
  print_string "] ";
  print_endline trans_str

let print_header (machine : machine) (transitions_order : (string * char) list) : unit =
  let line = String.make 80 '*' in
  print_endline line;
  Printf.printf "*%78s*\n" "";
  let name = machine.name in
  let pad = (78 - String.length name) / 2 in
  Printf.printf "*%s%s%s*\n"
    (String.make pad ' ') name
    (String.make (78 - pad - String.length name) ' ');
  Printf.printf "*%78s*\n" "";
  print_endline line;
  print_string "Alphabet: [ ";
  List.iter (fun c -> print_char c; print_string ", ") machine.alphabet;
  print_string "]\n";
  print_string "States  : [ ";
  List.iter (fun s -> print_string s; print_string ", ") machine.states;
  print_string "]\n";
  Printf.printf "Initial : %s\n" machine.initial;
  print_string "Finals  : [ ";
  List.iter (fun s -> print_string s; print_string ", ") machine.finals;
  print_string "]\n";
  List.iter (fun (state, read) ->
    match Hashtbl.find_opt machine.transitions (state, read) with
    | None -> ()
    | Some t ->
      let action_str = match t.action with LEFT -> "LEFT" | RIGHT -> "RIGHT" in
      Printf.printf "(%s, %c) -> (%s, %c, %s)\n"
        state read t.to_state t.write action_str
  ) transitions_order;
  print_endline line

let run (machine : machine) (input : string) (transitions_order : (string * char) list) : unit =
  print_header machine transitions_order;
  let tape  = make_tape input in
  let head  = ref 0 in
  let state = ref machine.initial in

  let visited = Hashtbl.create 1024 in

  let rec loop () =
    if List.mem !state machine.finals then ()
    else begin


      let key  = (!state, !head) in
      let snap = tape_snapshot tape machine.blank in
      (match Hashtbl.find_opt visited key with
      | Some old_snap when old_snap = snap ->
          print_endline "Infinite loop detected!"; exit 1
      | Some _ -> ()
      | None   -> Hashtbl.add visited key snap);
      let c = tape_read tape !head machine.blank in
      match Hashtbl.find_opt machine.transitions (!state, c) with
      | None ->
          Printf.printf "BLOCKED: no transition for state '%s' reading '%c'\n"
            !state c;
          exit 1
      | Some t ->
          let action_str = match t.action with LEFT -> "LEFT" | RIGHT -> "RIGHT" in
          let trans_str  = Printf.sprintf "(%s, %c) -> (%s, %c, %s)"
            !state c t.to_state t.write action_str
          in
          display_tape tape !head machine.blank trans_str;


          if c = machine.blank && t.write = machine.blank && t.to_state = !state then begin
            print_endline "Infinite loop detected!"; exit 1
          end;
          tape_write tape !head t.write machine.blank;
          head  := !head + (match t.action with LEFT -> -1 | RIGHT -> 1);
          state := t.to_state;
          loop ()
    end
  in
  loop ()