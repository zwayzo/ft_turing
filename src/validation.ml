open Types

let validate_machine machine input =

  (* blank doit être dans l'alphabet *)
  if not (List.mem machine.blank machine.alphabet) then begin
    print_endline "Blank character must be part of the alphabet";
    exit 1
  end;

  (* initial doit être dans states *)
  if not (List.mem machine.initial machine.states) then begin
    print_endline "Initial state must be part of the states";
    exit 1
  end;

  (* finals doit être un sous-ensemble de states *)
  List.iter (fun f ->
    if not (List.mem f machine.states) then begin
      print_endline ("Final state '" ^ f ^ "' not in states");
      exit 1
    end
  ) machine.finals;

  (* chaque char de l'input doit être dans l'alphabet et pas le blank *)
  String.iter (fun c ->

    if not (List.mem c machine.alphabet) then begin
      print_endline
        ("Input character '" ^ String.make 1 c ^ "' not in alphabet");
      exit 1
    end;

    if c = machine.blank then begin
      print_endline "Input must not contain the blank character";
      exit 1
    end

  ) input;

  (* chaque transition doit référencer des états et chars valides *)
  Hashtbl.iter (fun (state, read) t ->

    if not (List.mem state machine.states) then begin
      print_endline
        ("Transition state '" ^ state ^ "' not in states");
      exit 1
    end;

    if not (List.mem read machine.alphabet) then begin
      print_endline
        ("Transition read char not in alphabet");
      exit 1
    end;

    if not (List.mem t.write machine.alphabet) then begin
      print_endline
        ("Transition write char not in alphabet");
      exit 1
    end;

    if not (List.mem t.to_state machine.states) then begin
      print_endline
        ("Transition to_state '" ^ t.to_state ^ "' not in states");
      exit 1
    end

  ) machine.transitions