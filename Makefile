.PHONY: all clean
.DEFAULT_GOAL: all

all: builtins
	dune exec llamac

llamac: builtins
	dune build -p llamac @install

builtins: llama_Builtins.mli llama_Builtins.ml
	ocamlopt -c llama_Builtins.mli llama_Builtins.ml

clean:
	dune clean
	rm -rf *.install
	rm -rf links linx
	rm -rf *.cmx *.cmi *.o
	rm -rf a.out
