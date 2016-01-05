(*
 * Copyright (c) 2016 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

external nativeint_of_dir_handle : Unix.dir_handle -> nativeint
  = "nativeint_of_dir_handle_stub"

external dir_handle_of_nativeint : nativeint -> Unix.dir_handle
  = "dir_handle_of_nativeint_stub"

let int_of_file_descr : Unix.file_descr -> int = Obj.magic

let file_descr_of_int : int -> Unix.file_descr = Obj.magic

