open Types

let tape_size = 1000

let make_tape (input : string) (blank : char) : char array =
  let tape = Array.make tape_size blank in
  String.iteri (fun i c -> tape.(i) <- c) input;
  tape

(* Affiche seulement jusqu'au dernier caractère non-blank + quelques blanks *)
let display_tape (tape : char array) (head : int) (blank : char) (trans_str : string) : unit =
  (* Trouve le dernier index non-blank *)
  let last = ref 0 in
  Array.iteri (fun i c -> if c <> blank then last := i) tape;
  let last = !last + 13 in (* quelques blanks après *)
  let last = max last head in (* toujours inclure la tête *)
  print_char '[';
  for i = 0 to last do
    let c = tape.(i) in
    if i = head then begin
      print_char '<'; print_char c; print_char '>'
    end else
      print_char c
  done;
  print_string "] ";
  print_endline trans_str

let print_header (machine : machine) (transitions_order : (string * char) list) : unit =
  let line = String.make 80 '*' in
  print_endline line;
  Printf.printf "*%78s*\n" "";
  (* Centre le nom *)
  let name = machine.name in
  let pad = (78 - String.length name) / 2 in
  Printf.printf "*%s%s%s*\n"
    (String.make pad ' ') name
    (String.make (78 - pad - String.length name) ' ');
  Printf.printf "*%78s*\n" "";
  print_endline line;

  (* Alphabet *)
  print_string "Alphabet: [ ";
  List.iter (fun c -> print_char c; print_string ", ") machine.alphabet;
  print_string "]\n";

  (* States *)
  print_string "States  : [ ";
  List.iter (fun s -> print_string s; print_string ", ") machine.states;
  print_string "]\n";

  Printf.printf "Initial : %s\n" machine.initial;

  print_string "Finals  : [ ";
  List.iter (fun s -> print_string s; print_string ", ") machine.finals;
  print_string "]\n";

  (* Transitions dans l'ordre du JSON *)
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
  let tape  = make_tape input machine.blank in
  let head  = ref 0 in
  let state = ref machine.initial in
  let rec loop () =
    if List.mem !state machine.finals then () (* cas de base : on s'arrête *)
    else begin
      if !head < 0 || !head >= tape_size then
        failwith "Head out of tape bounds";
      let c = tape.(!head) in
      match Hashtbl.find_opt machine.transitions (!state, c) with
      | None ->
          Printf.printf "BLOCKED: no transition for state '%s' reading '%c'\n"
            !state c;
          exit 1
      | Some t ->
          let action_str = match t.action with LEFT -> "LEFT" | RIGHT -> "RIGHT" in
          let trans_str = Printf.sprintf "(%s, %c) -> (%s, %c, %s)"
            !state c t.to_state t.write action_str
          in
          display_tape tape !head machine.blank trans_str;
          tape.(!head) <- t.write;
          head := !head + (match t.action with LEFT -> -1 | RIGHT -> 1);
          state := t.to_state;
          loop ()
    end
  in
  loop ()


  (* loop()          ← premier appel
  → applique transition
  → loop()      ← deuxième appel
      → applique transition
      → loop()  ← troisième appel
          → ...
          → état final trouvé → () ← cas de base, on remonte *)