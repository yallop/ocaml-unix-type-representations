(*
 * Copyright (c) 2016 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)


module C = Bindings.Bindings(Generated_ml)

open OUnit2


let id x = x


module StringSet = Set.Make(String)

(** The contents of test-directory/ as a set *)
let test_directory_contents =
  Array.fold_right StringSet.add
    (Sys.readdir "test-directory")
    (StringSet.(union (singleton "..") (singleton ".")))

let string_of_stringset set =
  "{ "^ StringSet.fold (fun x y -> x ^" "^ y) set "}"

let assert_remove item items =
  let msg = Printf.sprintf "%s is in %s" item (string_of_stringset items) in
  begin
    assert_bool msg (StringSet.mem item items);
    StringSet.remove item items
  end


(**
 * Test that [file_descr] values are represented as [int]s.
 *)
let test_file_descr_representation _ =
  assert_equal Obj.int_tag
    Obj.(tag (repr Unix.stdin))
    ~printer:string_of_int

(**
 * Test that [dir_handle] values are represented as abstract values.
 *)
let test_dir_handle_representation _ =
  assert_equal Obj.abstract_tag
    Obj.(tag (repr (Unix.opendir".")))
    ~printer:string_of_int

(**
 * Test converting from a [file_descr] value to an [int] and back.
 *)
let test_file_descr_round_trip _ =
  let fd = Unix.(openfile "test-file" [O_RDONLY] 0) in
  let fd_int = Unix_representations.int_of_file_descr fd in
  let fd' = Unix_representations.file_descr_of_int fd_int in
  let buf = Bytes.create 1 in
  begin
    assert_equal 1
      (Unix.read fd buf 0 1)
      ~printer:string_of_int;
    assert_equal "a" (Bytes.to_string buf)
      ~printer:id;

    assert_equal 1
      (Unix.read fd' buf 0 1)
      ~printer:string_of_int;
    assert_equal "b" (Bytes.to_string buf)
      ~printer:id;
  end


(**
 * Test converting from a [dir_handle] value to a [nativeint] and back.
 *)
let test_dir_handle_round_trip _ =
  let dh = Unix.opendir "test-directory" in
  let dh_int = Unix_representations.nativeint_of_dir_handle dh in
  let dh' = Unix_representations.dir_handle_of_nativeint dh_int in
  let entries = test_directory_contents in
  let entries = assert_remove (Unix.readdir dh) entries in
  let entries = assert_remove (Unix.readdir dh') entries in
  let entries = assert_remove (Unix.readdir dh) entries in
  ignore entries


(**
 * Test converting a [file_descr] value to an [int] and using the result
 * with {!Ctypes}.
 *)
let test_use_file_descr_with_ctypes _ =
  let fd = Unix.(openfile "test-file" [O_RDONLY] 0) in
  let fd_int = Unix_representations.int_of_file_descr fd in
  let buf = Bytes.create 1 in
  begin
    ignore (C.read fd_int (Ctypes.ocaml_bytes_start buf) Unsigned.Size_t.one);
    assert_equal "a" (Bytes.to_string buf)
      ~printer:id;

    assert_equal 1
      (Unix.read fd buf 0 1)
      ~printer:string_of_int;
    assert_equal "b" (Bytes.to_string buf)
      ~printer:id;
  end


(**
 * Test converting a [dir_handle] value to a [nativeint] and using the result
 * with {!Ctypes}.
 *)
let test_use_dir_handle_with_ctypes _ =
  (* Open a directory with Ctypes and read it with Unix *)
  let dir_ptr = C.opendir "test-directory" in
  let raw_ptr = Ctypes.raw_address_of_ptr dir_ptr in
  let dh = Unix_representations.dir_handle_of_nativeint raw_ptr in
  let entries = test_directory_contents in
  let entries = assert_remove (Unix.readdir dh) entries in
  let entries = assert_remove (Unix.readdir dh) entries in
  ignore entries;
  Unix.closedir dh;

  (* Open a directory with Unix and close it with Ctypes *)
  let dh = Unix.opendir "test-directory" in
  let raw_ptr = Unix_representations.nativeint_of_dir_handle dh in
  begin
    ignore (C.closedir (Ctypes.ptr_of_raw_address raw_ptr));
    try
      ignore (Unix.readdir dh);
      assert_failure "readdir after close"
    with End_of_file | Unix.Unix_error _ ->
      ()
  end


let suite = "Unix type representation tests" >:::
  ["file_descr representation"
   >:: test_file_descr_representation;

   "dir_handle representation"
    >:: test_dir_handle_representation;

   "file_descr round trip"
    >:: test_file_descr_round_trip;

   "dir_handle round trip"
    >:: test_dir_handle_round_trip;

   "use file_descr with ctypes"
    >:: test_use_file_descr_with_ctypes;

   "use dir_handle with ctypes"
    >:: test_use_dir_handle_with_ctypes;
  ]


let _ =
  run_test_tt_main suite
