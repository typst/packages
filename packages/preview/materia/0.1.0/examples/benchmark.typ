#import "/lib.typ": import-xyz, molecule

// ~1000-atom accelerator benchmark (issue #32). Default engine=wasm so
// `make examples`/`make images` (and CI) stay fast; the pure-Typst reference
// is compiled manually with --input engine=typst (see README, Large scenes).
// Recorded timings (typst 0.14.2, Apple M2, macOS 14.6):
//   engine=wasm:  8.2 s    engine=typst: 90.0 s   (~11x speedup)
#set page(width: auto, height: auto, margin: 0.6cm)
#let eng = sys.inputs.at("engine", default: "wasm")
#molecule(import-xyz(path("/examples/data/nacl-1000.xyz")), engine: eng,
  bond-color: luma(120), legend: true, width: 10cm)
