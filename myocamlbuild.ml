open Ocamlbuild_plugin;;
open Ocamlbuild_pack;;

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
  | _ -> ()
end;;
