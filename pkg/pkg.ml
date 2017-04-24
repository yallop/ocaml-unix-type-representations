#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let () =
  Pkg.describe "unix-type-representations"
    ~licenses:[Pkg.std_file "LICENSE"]
  @@ fun c ->
    Ok [ Pkg.mllib "lib/unix_type_representations.mllib";
         Pkg.lib "pkg/META";
         Pkg.doc "README.md";
         Pkg.clib "lib/libunix_type_representations_stubs.clib";
         Pkg.test ~dir:"lib_test" "lib_test/test"; ]
           
