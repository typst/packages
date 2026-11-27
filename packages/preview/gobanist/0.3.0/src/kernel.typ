// El kernel: el plugin de WebAssembly que juega la partida (capturas, territorio, regiones y puntaje). Su
// código está en kernel/; python kernel/build.py lo compila y deja aquí kernel.wasm.

#let wasm = plugin("kernel.wasm")

// La partida, como la describe kernel/src/lib.rs (Input), y lo que pasó (Output).
#let simulate(input) = json(wasm.run(bytes(json.encode(input))))

// Lo que se pregunta de un archivo SGF (data: sus bytes), como lo describe kernel/src/sgf.rs (Request).
#let sgf-query(data, request) = json(wasm.sgf(data, bytes(json.encode(request))))

// Una imagen (data: un PNG o un JPEG) con otra opacidad o hecha silueta, como lo describe kernel/src/images.rs
// (Request): un PNG.
#let image-transform(data, request) = wasm.image(data, bytes(json.encode(request)))
