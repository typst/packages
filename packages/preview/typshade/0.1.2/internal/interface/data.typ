// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../model/parser.typ" as _parser

#let alignment-data(source, format: auto) = _parser.read-alignment(source, format: format)

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
