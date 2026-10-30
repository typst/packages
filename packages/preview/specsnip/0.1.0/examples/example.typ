// Copyright 2026 Nikolai Neff-Sarnow

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "@local/specsnip:0.1.0": *

#let code = read("icd.h")

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#show: codly-init.with()

= Original Source Code:
#raw(code, block: true, lang: "h")

= Get Code-Excerpts by Name:

== Functions:
#let r = function-linerange(code, "icd_process")
#codly-range(r.start, ..r)
#raw(code, block: true, lang: "h")

#divider()
#let r = function-linerange(code, "icd_initialize")
//Example usage without codly:
#let code2 = code.split("\n").slice(r.start - 1, r.end).join("\n")
#raw(code2, block: true, lang: "h")

== Type Definitions:
#let t = typedef-linerange(code, "ICD_Status")
#codly-range(t.start, ..t)
#raw(code, block: true, lang: "h")

= Checking Identifier Existance
#let q = contains_identifier(
  code,
  "main",
)
The `main` function is #{ if not q [not] } listed in the source code.

= Arbitray Queries
#let query = "((type_definition (type_identifier) @type.name) @definition (#eq? @type.name \"ICD_Data\"))"
#let result = query_code(code, query)
#let first_capture = result.at(0).captures.at(0)
#raw(code.slice(first_capture.start_byte, first_capture.end_byte), block: true, lang: "h")

= Get the entire Tree
#get_tree(code)
