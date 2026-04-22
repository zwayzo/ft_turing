NAME = ft_turing

SRC =  src/Parser.ml 

OCAMLC = ocamlfind ocamlc
OCAMLOPT = ocamlfind ocamlopt

PACKAGES = yojson
FLAGS = -package $(PACKAGES) -linkpkg

all: byte

byte:
	$(OCAMLC) $(FLAGS) -o $(NAME) $(SRC)

native:
	$(OCAMLOPT) $(FLAGS) -o $(NAME) $(SRC)

clean:
	rm -f src/*.cmi* src/*cmo *.o

fclean: clean
	rm -f $(NAME) $(NAME)

re: fclean all

.PHONY: all byte native clean fclean re