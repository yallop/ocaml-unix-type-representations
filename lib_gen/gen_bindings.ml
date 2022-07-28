(*
 * Copyright (c) 2017 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

let () =
  let prefix = "utr_" in
  let stubs_oc = open_out "lib_test/generated_stubs.c" in
  let fmt = Format.formatter_of_out_channel stubs_oc in
  Format.fprintf fmt "#include <unistd.h>@.";
  Format.fprintf fmt "#include <sys/types.h>@.";
  Format.fprintf fmt "#include <dirent.h>@.";
  Cstubs.write_c fmt ~prefix (module Bindings.Bindings);
  close_out stubs_oc;

  let generated_oc = open_out "lib_test/generated_ml.ml" in
  let fmt = Format.formatter_of_out_channel generated_oc in
  Cstubs.write_ml fmt ~prefix (module Bindings.Bindings);
  close_out generated_oc
