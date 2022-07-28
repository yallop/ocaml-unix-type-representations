module Bindings (F: Ctypes.FOREIGN) =
struct
  open Ctypes
  open F

  let read = foreign "read"
    (int @-> ocaml_bytes @-> PosixTypes.size_t @-> returning PosixTypes.ssize_t)

  let opendir = foreign "opendir"
    (string @-> returning (ptr void))

  let closedir = foreign "closedir"
    (ptr void @-> returning int)
end
