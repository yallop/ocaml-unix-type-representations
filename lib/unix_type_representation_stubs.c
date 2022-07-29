/*
 * Copyright (c) 2016 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 */

#include <stdint.h>

#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/unixsupport.h>

#ifdef HAS_DIRENT
#include <dirent.h>
#else
#include <sys/dir.h>
#endif

value nativeint_of_dir_handle_stub(value dir_handle)
{
  return caml_copy_nativeint((intptr_t)DIR_Val(dir_handle));
}

value dir_handle_of_nativeint_stub(value nativeint)
{
  DIR *d = (DIR *)(intptr_t)Nativeint_val(nativeint);
  value res = caml_alloc_small(1, Abstract_tag);
  DIR_Val(res) = d;
  return res;
}

void dir_handle_clean_stub(value dir_handle)
{
  CAMLparam1(dir_handle);
  DIR_Val(dir_handle) = (DIR *) NULL;
  CAMLreturn0;
}
