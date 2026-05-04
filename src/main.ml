let () =
  if Array.length Sys.argv < 3 then begin
    print_endline "usage: ft_turing [-h] jsonfile input";
    exit 1
  end;
  let json_file = Sys.argv.(1) in
  let input     = Sys.argv.(2) in
  let machine   = Machine_parser.parse_machine json_file in
  Validation.validate_machine machine input;
  Tape.run machine input machine.transitions_order