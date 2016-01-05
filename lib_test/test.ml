(*
 * Copyright (c) 2016 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)


open OUnit2


let id x = x


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
  begin
    assert_equal ".."
      (Unix.readdir dh)
      ~printer:id;

    assert_equal "a"
      (Unix.readdir dh')
      ~printer:id;

    assert_equal "b"
      (Unix.readdir dh)
      ~printer:id;
  end


(**
 * Test converting a [file_descr] value to an [int] and using the result
 * with {!Ctypes}.
 *)
let test_use_file_descr_with_ctypes _ =
  let ctypes_read = Foreign.foreign "read"
      Ctypes.(int @-> ocaml_bytes @-> PosixTypes.size_t @-> returning PosixTypes.ssize_t)
  in
  let fd = Unix.(openfile "test-file" [O_RDONLY] 0) in
  let fd_int = Unix_representations.int_of_file_descr fd in
  let buf = Bytes.create 1 in
  begin
    ignore (ctypes_read fd_int (Ctypes.ocaml_bytes_start buf) Unsigned.Size_t.one);
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
  let ctypes_opendir = Foreign.foreign "opendir"
      Ctypes.(string @-> returning (ptr void))
  in
  let ctypes_closedir = Foreign.foreign "closedir"
      Ctypes.(ptr void @-> returning int)
  in
  (* Open a directory with Ctypes and read it with Unix *)
  let dir_ptr = ctypes_opendir "test-directory" in
  let raw_ptr = Ctypes.raw_address_of_ptr dir_ptr in
  let dh = Unix_representations.dir_handle_of_nativeint raw_ptr in
  begin
    assert_equal ".."
      (Unix.readdir dh)
      ~printer:id;

    assert_equal "a"
      (Unix.readdir dh)
      ~printer:id;

    Unix.closedir dh;
  end;

  (* Open a directory with Unix and close it with Ctypes *)
  let dh = Unix.opendir "test-directory" in
  let raw_ptr = Unix_representations.nativeint_of_dir_handle dh in
  begin
    ctypes_closedir (Ctypes.ptr_of_raw_address raw_ptr);
    try
      Unix.readdir dh;
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
