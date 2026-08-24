// Mirrors upstream src/xyzrender/inputs.py.
//
// Scope note: upstream `inputs.py` parses QM (quantum-mechanics) input
// files — Gaussian/ORCA route sections, Quantum Espresso, CP2K, VASP
// POSCAR, SIESTA fdf, etc. — extracting atoms, charge, multiplicity,
// and unit cell. All of that is out of scope for v1 (PLAN.md:23-29);
// v1 consumes XYZ and PDB.
//
// What lives here instead is a Typst-package-specific concern with no
// upstream parallel: dispatching the first positional argument of
// `xyzrender(...)` (bytes, inline string, or bare file path) into the
// raw bytes the WASM plugin consumes, plus (when known) the file
// extension, so `readers.typ` can skip content-sniffing.
//
// IMPORTANT: Typst's `read()` resolves paths relative to the file
// containing the `read()` call. A package cannot resolve paths
// relative to the user's document by itself. There are two ways
// around this:
//   1. Call `read("mol.xyz", encoding: none)` yourself and pass the
//      resulting bytes.
//   2. Bind a `reader` once — `#let xyzrender = xyzrender.with(reader:
//      p => read(p, encoding: none))` — and pass bare path strings
//      thereafter. This works because the closure's `read(...)` call
//      is lexically part of *your* document, so it resolves relative
//      to your document even though it's invoked from inside this
//      package (verified empirically; the same mechanism lets user
//      content blocks use relative `image()` paths when passed into
//      other packages).

#let resolve-input(source, reader: none) = {
  if type(source) == bytes {
    (bytes: source, ext: none)
  } else if type(source) == str {
    if source.contains("\n") {
      // Inline xyz/pdb content.
      (bytes: bytes(source), ext: none)
    } else if reader != none {
      let content = reader(source)
      if type(content) != bytes {
        panic(
          "xyzrender: `reader` must return bytes (e.g. `read(p, encoding: "
            + "none)`); got " + repr(type(content)),
        )
      }
      let ext = if source.contains(".") {
        lower(source.split(".").last())
      } else {
        none
      }
      (bytes: content, ext: ext)
    } else {
      panic(
        "xyzrender: a bare string was passed that looks like a file path "
          + "(\"" + source + "\"). Typst packages can't resolve paths "
          + "relative to your document, so either call `read(\"" + source
          + "\", encoding: none)` yourself and pass the bytes:\n"
          + "    #xyzrender(read(\"" + source + "\", encoding: none), ...)\n"
          + "or bind a reader once:\n"
          + "    #let xyzrender = xyzrender.with(reader: p => read(p, encoding: none))\n"
          + "    #xyzrender(\"" + source + "\")\n"
          + "Supported formats: XYZ (standard/extended), PDB (ATOM/HETATM "
          + "+ CONECT/CRYST1) — auto-detected.",
      )
    }
  } else {
    panic(
      "xyzrender: `source` must be bytes (from `read(..., encoding: none)`), "
        + "an inline XYZ/PDB string with newlines, or a bare path string "
        + "when `reader:` is bound; got " + repr(type(source)),
    )
  }
}
