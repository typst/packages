
import pkg/pyformats/percent
import pkg/wasm_minimal_protocol
import pkg/wasm_minimal_protocol/cbor_any
#export_typst_from_func `%`, typst_name
import std/typeinfo

proc sprintf(format: string, args: varargs[Any]): string{.export_typst.} =
  defer: collectCborAnyPool()
  Py_FormatEx(format, args, `disallow%b` = false)

proc sprintf_map(format: string, arg: Table[string, Any]): string{.export_typst_conv(ncTypst).} =
  defer: collectCborAnyPool()
  Py_FormatEx(format, arg, `disallow%b` = false)

genTypstFile()


