(*
 * Copyright (c) 2016 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

val nativeint_of_dir_handle : Unix.dir_handle -> nativeint
(** Retrieve the [DIR] pointer underlying a {!Unix.dir_handle} value *)

val dir_handle_of_nativeint : nativeint -> Unix.dir_handle
(** Build a {!Unix.dir_handle} value from a [DIR] pointer. *)

val int_of_file_descr : Unix.file_descr -> int
(** Convert a {!Unix.file_descr} to an [int]. *)

val file_descr_of_int : int -> Unix.file_descr
(** Convert an [int] to a {!Unix.file_descr}. *)
