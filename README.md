# Llama Compiler -- a functional compiler (mostly) for free

The Llama compiler is a compiler for a small untyped lambda calculus endowed with integers and primitives for adding integers and printing integers. The compiler is realised mostly for free by utilising the native compilation pipeline of the OCaml compiler.

This project is intended to serve as an illustrative example of how to build a compiler by interfacing with the OCaml backend.

## Abstract syntax

The Llama language is essentially the untyped lambda calculus with integers and a few operations on integers.
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

**DOCUMENTATION TO BE COMPLETED**
