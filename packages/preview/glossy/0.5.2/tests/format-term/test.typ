#import "/lib.typ": *

#let myGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
    group: "Web"),
  css: (
    short: "CSS",
    long: "Cascading Style Sheets",
    description: "A language used for describing the presentation of a document",
    group: "Web"),
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document on how to run all the test procedures"),
  concise: "Concise syntax!",
  shortonly: (
    short: "shortonly!!!"),
  unused: "Unused term, which shouldn't print in the glossary."
)

#set page(width: 6.5in, height: auto, margin: 1em)

#let test-content = {
  table(
    columns: 3,
    table.header(
      [`short`], [`long`], [`both`],
    ),

    [@html:short],      [@html:long],      [@html:both],
    [@css:short],       [@css:long],       [@css:both],
    [@tps:short],       [@tps:long],       [@tps:both],
    [@concise:short],   [@concise:long],   [@concise:both],
    [@shortonly:short], [@shortonly:long], [@shortonly:both],

    table.hline(stroke: 2pt),

    [@html:short:cap],        [@html:long:cap],        [@html:both:cap],
    [@a:css:short],           [@a:css:long],           [@a:css:both],
    [@tps:short:pl],          [@tps:long:pl],          [@tps:both:pl],
    [@concise:a:cap:short],   [@concise:a:cap:long],   [@concise:a:cap:both],
    [@an:shortonly:short],    [@an:shortonly:long],    [@an:shortonly:both],
  )

  [@a:tps:cap is @tps:def.]
}

// ---------------------------------------------------------------------------------

#let format-basic(mode, short-form, long-form) = {
  if mode == "short" {
    short-form
  } else if mode == "long" {
  long-form
  } else {
    long-form + " (" + short-form + ")"
  }
}

#init-glossary(myGlossary, format-term: format-basic)[#test-content]

// ---------------------------------------------------------------------------------

#let format-reverse(mode, short-form, long-form) = {
  if mode == "short" {
    short-form
  } else if mode == "long" {
    long-form
  } else {
    short-form + " [" + long-form + "]"
  }
}

#init-glossary(myGlossary, format-term: format-reverse)[#test-content]

// ---------------------------------------------------------------------------------

#let format-uppercase-short(mode, short-form, long-form) = {
  let short-up = upper(short-form);
  if mode == "short" {
    short-up
  } else if mode == "long" {
    long-form
  } else {
    long-form + " (" + short-up + ")"
  }
}

#init-glossary(myGlossary, format-term: format-uppercase-short)[#test-content]

// ---------------------------------------------------------------------------------

#let format-prefix-suffix(mode, short-form, long-form) = {
  if mode == "short" {
    "Term: " + short-form + "."
  } else if mode == "long" {
    "Term: " + long-form + "."
  } else {
    "Term: " + long-form + " (" + short-form + ")."
  }
}

#init-glossary(myGlossary, format-term: format-prefix-suffix)[#test-content]

// ---------------------------------------------------------------------------------

#let format-conditional-separator(mode, short-form, long-form) = {
  let separator = if short-form.len() > 4 { " / " } else { ", " };
  let has_long = long-form != none and long-form != "";

  if mode == "short" {
    short-form
  } else if mode == "long" {
    if has_long { long-form } else { short-form }
  } else {
    if has_long {
      long-form + separator + short-form
    } else {
      short-form
    }
  }
}

#init-glossary(myGlossary, format-term: format-conditional-separator)[#test-content]

// ---------------------------------------------------------------------------------
// 1. Braces and Labels
// Idea: Use different bracket styles and labels based on the mode.
#let format-braces(mode, short-form, long-form) = {
  if mode == "short" {
    "{" + short-form + "}"
  } else if mode == "long" {
    "[" + long-form + "]"
  } else {
    long-form + " <" + short-form + ">"
  }
}

#init-glossary(myGlossary, format-term: format-braces)[#test-content]

// ---------------------------------------------------------------------------------
// 2. Mode-Based Prefix
// Idea: Add a prefix indicating the mode, and then show the term(s).
#let format-mode-prefix(mode, short-form, long-form) = {
  let prefix = if mode == "short" { "S:" } else if mode == "long" { "L:" } else { "B:" };
  if mode == "short" {
    prefix + short-form
  } else if mode == "long" {
    prefix + long-form
  } else {
    prefix + long-form + " & " + short-form
  }
}

#init-glossary(myGlossary, format-term: format-mode-prefix)[#test-content]

// ---------------------------------------------------------------------------------
// 3. Conditional Fallback for Missing Long
// Idea: If no long-form is provided, use the short-form in all cases.
#let format-fallback-long(mode, short-form, long-form) = {
  let has_long = long-form != none and long-form != "";
  if mode == "short" {
    short-form
  } else if mode == "long" {
    if has_long { long-form } else { short-form }
  } else {
    if has_long { long-form + " (" + short-form + ")" } else { short-form }
  }
}

#init-glossary(myGlossary, format-term: format-fallback-long)[#test-content]

// ---------------------------------------------------------------------------------
// 4. Uppercase Both Terms in Both Mode
// Idea: Always uppercase for both mode, normal otherwise.
#let format-uppercase-both(mode, short-form, long-form) = {
  if mode == "short" {
    short-form
  } else if mode == "long" {
    long-form
  } else {
    upper(long-form) + " (" + upper(short-form) + ")"
  }
}

#init-glossary(myGlossary, format-term: format-uppercase-both)[#test-content]

// ---------------------------------------------------------------------------------
// 5. Append Length Info
// Idea: In both mode, append the length of each string.
#let format-length-info(mode, short-form, long-form) = {
  let s_len = str(short-form.len())
  let l_len = if long-form != none and long-form != "" { str(long-form.len()) } else { "0" }

  if mode == "short" {
    short-form + " [len:" + s_len + "]"
  } else if mode == "long" {
    long-form + " [len:" + l_len + "]"
  } else {
    long-form + " (" + short-form + ") [L:" + l_len + ", S:" + s_len + "]"
  }
}

#init-glossary(myGlossary, format-term: format-length-info)[#test-content]

