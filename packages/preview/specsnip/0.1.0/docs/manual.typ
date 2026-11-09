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


#import "@preview/tidy:0.4.3": *
#import "template.typ": *


#let version = toml("../typst.toml").package.version

#show: project.with(
  abstract: "A package to query C-Headers for function- and/or type definition line ranges.",
  authors: ("Nikolai Neff-Sarnow",),
  title: "SpecSnip",
  version: version,
  url: "https://github.com/nineff/specsnip",
)

#let docs = parse-module(read("../lib.typ"), name: "SpecSnip")
#show-module(docs, style: styles.default, first-heading-level: 1, sort-functions: none)
