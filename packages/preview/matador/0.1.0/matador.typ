#let mat = {
  let wasm = plugin("matador.wasm");

  (source, transpose: false, keep-unit-dims: false) => {
    if type(source) == str {
      panic("'mat' cannot take a path directly, you need to read the file with 'read(path, encoding: none)'");
    }
    if type(transpose) != bool {
      panic("expected 'transpose' to be a boolean");
    }
    if type(keep-unit-dims) != bool {
      panic("expected 'keep-unit-dims' to be a boolean");
    }

    let options = (
      transpose: transpose,
      keep-unit-dims: keep-unit-dims,
    );

    let output = cbor(wasm.parse_mat(source, cbor.encode(options)));

    if "error" in output {
      panic(output.error);
    }

    output.data
  }
};
