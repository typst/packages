// SPDX-FileCopyrightText: Copyright (C) 2025 Andrew Voynov
//
// SPDX-License-Identifier: AGPL-3.0-only

// crates/typst-library/src/text/lang.rs
#let rtl-languages = (
  "ar",
  "dv",
  "fa",
  "he",
  "ks",
  "pa",
  "ps",
  "sd",
  "ug",
  "ur",
  "yi",
)

/// Get resolved `text.dir` value: `ltr` or `rtl`.
/// Must be used inside `context`.
/// -> direction
#let text-dir() = {
  if text.dir != auto { return text.dir }
  if text.lang in rtl-languages { rtl } else { ltr }
}
