open Types
let validate_machine machine input =
  (* blank doit être dans l'alphabet *)
  if not (List.mem machine.blank machine.alphabet) then
    failwith "Blank character must be part of the alphabet";

  (* initial doit être dans states *)
  if not (List.mem machine.initial machine.states) then
    failwith "Initial state must be part of the states";

  (* finals doit être un sous-ensemble de states *)
  List.iter (fun f ->
    if not (List.mem f machine.states) then
      failwith ("Final state '" ^ f ^ "' not in states")
  ) machine.finals;

  (* chaque char de l'input doit être dans l'alphabet et pas le blank *)
  String.iter (fun c ->
    if not (List.mem c machine.alphabet) then
      failwith ("Input character '" ^ String.make 1 c ^ "' not in alphabet");
    if c = machine.blank then
      failwith "Input must not contain the blank character"
  ) input;

  (* chaque transition doit référencer des états et chars valides *)
  Hashtbl.iter (fun (state, read) t ->
    if not (List.mem state machine.states) then
      failwith ("Transition state '" ^ state ^ "' not in states");
    if not (List.mem read machine.alphabet) then
      failwith ("Transition read char not in alphabet");
    if not (List.mem t.write machine.alphabet) then
      failwith ("Transition write char not in alphabet");
    if not (List.mem t.to_state machine.states) then
      failwith ("Transition to_state '" ^ t.to_state ^ "' not in states")
  ) machine.transitions