# Llama Compiler -- a functional compiler (mostly) for free

The Llama compiler is a compiler for a small untyped lambda calculus endowed with integers and primitives for adding integers and printing integers. The construction of this compiler is mostly for free as it interfaces directly with the backend of the OCaml compiler and takes advantage of its native compilation pipeline. Although, this compiler only supports x86, it could with little effort support multiple architectures simultaneous, and with a bit more effort it could even support cross-platform compilation. Since the compiler interfaces directly with the OCaml compiler tool-chain it can in principle do whatever the OCaml compiler tool-chain can do.

This project is intended to serve as an illustrative example of how to build a compiler by interfacing with the OCaml backend.

## Abstract syntax

The Llama language is itself not terribly exciting; it is essentially the untyped lambda calculus with integers and a few operations on integers.
```
M, N ::= Int i           (* integers *)
       | Var x           (* variables *)
       | Abs (x, M)      (* \x.M *)
       | App (M, N)      (* M N *)
       | PrimApp (P, N*) (* primitive N* *)

P ::= Plus
    | Print_int
```
For convenience the abstract syntax differentiates applications of non-primitive terms and primitive terms. Note, primitive application is n-ary, whilst regular application is unary.

## Semantics

The only defined behaviour is that all behaviour is undefined.

## Compilation pipeline

Most of the source code for the compiler is contained within the directory `comp`

* `syntax.ml` is the abstract syntax of Llama along with some convenient functions for writing Llama examples
* `lambdaIr.ml` is a thin wrapper around the `lambda.ml` module in the OCaml backend
* `translate.ml` translates Llama abstract syntax to that of OCaml's Lambda; the module is parameterised by a `LambdaIr.LambdaWrapper`
* `backend.ml` constructs the code generator by cherry picking existing parts of the OCaml backend infrastructure
* `main.ml` is the main entry point for the executable
* `utils.ml` contains a few convenient utilities

The root of the repository contains the module `llama_Builtins.ml` and its signature file. This file provides definitions for the Llama primitives that require more than one Lambda primitive instruction to implement.

**DOCUMENTATION TO BE COMPLETED**
