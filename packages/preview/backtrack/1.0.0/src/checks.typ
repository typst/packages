// Copyright © 2023 Luke Chambers
// This file is part of Backtrack.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy of
// the License at <http://www.apache.org/licenses/LICENSE-2.0>.
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations under
// the License.

// From the changelog:
// > Exposed content representation: Can be observed in hover tooltips or with
// > repr
#let v2023-03-21-supported = repr[a] != "[...]"

// Commit 50b0318:
// > Mark 3 symbols as combining accents (#2218)
#let v0-9-0-supported = if v2023-03-21-supported {
  math.accent("a", "↔").accent != "↔"
} else {
  false
}

// From the changelog:
// > Scripting: Types are now first-class values
#let v0-8-0-supported() = str(type(type(0))) == "type"

// From the changelog:
// > Math: Improved display of multi-primes (e.g. in $a''$)
#let v0-7-0-supported() = $a''$.body.has("base")

// From the changelog:
// > Math: Increased precedence of factorials in math mode ($1/n!$ works
// > correctly now)
#let v0-6-0-supported() = $0/a!$.body.has("num")

// From the changelog:
// > Math: The syntax rules for mathematical attachments were improved
#let v0-5-0-supported() = $a^b(0)$.body.has("base")

// From the changelog:
// > Scripting: Fixed replacement strings: They are now inserted completely
// > verbatim instead of supporting the previous (unintended) magic dollar
// > syntax for capture groups
#let v0-4-0-supported() = "a".replace(regex("a"), "$0") == "$0"

// From the changelog:
// > Added support for attachments (sub-, superscripts) that precede the base
// > symbol. The top and bottom arguments have been renamed to t and b.
#let v0-3-0-supported() = $a^b$.body.has("t")

// From the changelog:
// > Dictionaries now iterate in insertion order instead of alphabetical order.
#let v0-2-0-supported() = (b: 0, a: 0).keys().first() == "b"

// From the changelog:
// > Miscellaneous improvements: Fixed invalid parsing of language tag in raw
// > block with a single backtick
#let v0-1-0-supported() = not [`rust let`].has("lang")

// From the changelog:
// > Enumerations now require a space after their marker, that is, 1.ok must now
// > be written as 1. ok
#let v2023-03-28-supported() = [1.a].has("text")

// TODO: Add a check for v2023-02-25. This may be impossible.

// From the changelog:
// > The eval function now expects code instead of markup and returns an
// > arbitrary value. Markup can still be evaluated by surrounding the string
// > with brackets.
#let v2023-02-15-supported() = eval("0") == 0

// From the changelog:
// > Fixed parsing of not in operation
#let v2023-02-12-supported() = -1 not in (1, 2, 3)

// TODO: Add a check for v2023-02-02. This may be impossible.
