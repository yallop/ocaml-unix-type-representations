open Ocamlbuild_plugin;;
open Ocamlbuild_pack;;

let ctypes_libdir =
  try
    run_and_read ("ocamlfind query ctypes")
    |> String.trim
  with Failure _ -> ""

let () = dispatch begin
  function
  | After_rules ->
    dep ["ocaml"; "link"; "byte"; "use_unix_type_representations_stubs"]
      ["lib/dllunix_type_representations_stubs"-.-(!Options.ext_dll)];
    flag ["ocaml"; "link"; "byte"; "use_unix_type_representations_stubs"] &
    S[A"-dllib"; A"-lunix_type_representations_stubs";A"-I"; A"lib";];

    dep ["ocaml"; "link"; "native"; "use_unix_type_representations_stubs"]
      ["lib/libunix_type_representations_stubs"-.-(!Options.ext_lib)];
    flag ["ocaml"; "link"; "native"; "use_unix_type_representations_stubs"] &
    S[A"-cclib"; A"-lunix_type_representations_stubs"; A"-I"; A"lib";];

    dep ["ocaml"; "link"; "native"; "use_generated_test_stubs"]
      ["lib_test/generated_stubs"-.-(!Options.ext_obj)];

    flag ["c"; "compile"; "use_ctypes"] & S[A"-I"; A ctypes_libdir];

    rule "cstubs: lib_test/x_bindings.ml -> x_stubs.c, x_generated.ml"
      ~prods:["lib_test/generated_stubs.c"; "lib_test/generated_ml.ml"]
      ~deps: ["lib_gen/gen_bindings.byte"]
      (fun env build ->
        Cmd (A(env "lib_gen/gen_bindings.byte")));
  | _ -> ()
end;;
