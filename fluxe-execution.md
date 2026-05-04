./ft_turing unary_sub.json "111-11="
        │
        ▼
    main.ml
    ├── Machine_parser.parse_machine "unary_sub.json"  → machine
    ├── Validation.validate_machine machine "111-11="  → unit (ou erreur)
    └── Tape.run machine "111-11="
            ├── make_tape "111-11="
            └── loop ()
                ├── display_tape ...
                ├── écrire sur le ruban
                ├── déplacer la tête
                └── recommencer jusqu'à état final