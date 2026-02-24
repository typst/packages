#import "@preview/tidy:0.4.0": *


#let data = ```typ
/// Create an URL.
/// -> str
#let url(
  /// Host part of the URL.
  /// -> str
  host,
  /// URL scheme to use.
  ///
  /// *!! Causes tidy to fail parsing the module without an error.*
  ///
  /// -> str
  scheme: "https://"
) = scheme + host
```.text

#let m = parse-module(data)
#show-module(m)

#m
