// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Public alignment parsing and normalized data access.

#import "../model/parser.typ" as _parser

/// Parse an alignment into Typshade's normalized data model.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - format (str, auto): Input format, or `auto` to detect it.
/// -> dictionary
#let alignment-data(source, format: auto) = _parser.read-alignment(source, format: format)

/// Parse alignment text into Typshade's normalized data model.
///
/// - text (str, content): Text displayed by the generated annotation or label.
/// - format (str, auto): Input format, or `auto` to detect it.
/// -> dictionary
#let parse-alignment(text, format: "fasta") = {
  let source = _parser._source-text(text)
  let normalized = _parser._lower(str(format))
  if normalized == "msf" {
    _parser.parse-msf(source)
  } else if normalized == "aln" or normalized == "clustal" {
    _parser.parse-aln(source)
  } else {
    _parser.parse-fasta(source)
  }
}
