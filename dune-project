(lang dune 3.7)
(name unix-type-representations)

(using ctypes 0.3)
(formatting (enabled_for dune))
(generate_opam_files true)

(authors "Jeremy Yallop <yallop@gmail.com>")
(maintainers "Jeremy Yallop <yallop@gmail.com>")
(source (github yallop/ocaml-unix-type-representations))
(license "MIT")

(package
 (name unix-type-representations)
 (synopsis "Functions that expose the underlying types of some abstract types in the Unix module")
 (depends
  base-unix
  (ctypes :with-test)
  (ounit2 :with-test)))
