#import "plugin.typ": komet-plugin

#let fft-impl(
  values, direction: "forward", norm: "backward"
) = {
  values = values.map(x => {
    if type(x) in (int, float) { return (float(x), 0.) }
    assert(
      type(x) == array and x.len() == 2,
      message: "A complex number can consist of one or two floats, got " + repr(x)
    )
    x.map(float)
  })

  let fft = if direction == "forward" { 
    komet-plugin.fft 
  } else { 
    komet-plugin.ifft 
  }

  let norm-code = if norm == "backward" { 1 } else if norm == "ortho" { 2 } else { 3 }

  cbor(fft(cbor.encode((norm-code, values))))
}


/// Computes the discrete Fourier transform (DFT). 
/// 
/// Returns an array of complex (i.e., real/imaginary pairs of floats) values. 
#let fft(

  /// An array of real (`float`) or complex (real/imaginary pairs of `float`) 
  /// values. 
  /// -> array
  values,

  /// How to normalize the output. Options are:
  /// - `"backward"`: the entire normalization of $1/N$ happens at the inverse DFT. 
  /// - `"forward"`: the entire normalization of $1/N$ happens at the forward DFT. 
  /// - `"ortho"`: the normalization is split across DFT and its inverse and to both the factor $1/√N$ is applied. 
  /// -> "backward" | "forward" | "ortho"
  norm: "backward"

) = fft-impl(values, direction: "forward", norm: norm)


/// Computes the inverse discrete Fourier transform (DFT). 
/// 
/// Returns an array of complex (i.e., real/imaginary pairs of floats) values. 
#let ifft(

  /// An array of real (`float`) or complex (real/imaginary pairs of `float`) 
  /// values. 
  /// -> array
  values,

  /// How to normalize the output. Options are:
  /// - `"backward"`: the entire normalization of $1/N$ happens at the inverse DFT. 
  /// - `"forward"`: the entire normalization of $1/N$ happens at the forward DFT. 
  /// - `"ortho"`: the normalization is split across DFT and its inverse and to both the factor $1/√N$ is applied. 
  /// -> "backward" | "forward" | "ortho"
  norm: "backward"

) = fft-impl(values, direction: "inverse", norm: norm)
