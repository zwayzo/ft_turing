NAME = ft_turing

SRC = src/types.ml src/machine_parser.ml src/validation.ml src/tape.ml src/main.ml

OCAMLC   = ocamlfind ocamlc
OCAMLOPT = ocamlfind ocamlopt

PACKAGES = yojson
FLAGS    = -package $(PACKAGES) -linkpkg -I src

all: byte

byte:
	$(OCAMLC) $(FLAGS) -o $(NAME) $(SRC)

native:
	$(OCAMLOPT) $(FLAGS) -o $(NAME) $(SRC)

clean:
	rm -f src/*.cmi src/*.cmo src/*.cmx src/*.o $(NAME)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all byte native clean fclean re