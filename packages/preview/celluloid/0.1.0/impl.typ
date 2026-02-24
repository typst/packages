// Copyright (C) 2025 Casey Dahlin <sadmac@google.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#let line_spacing(blanks) = 0.65em + blanks * 1.23em
#let characters = state("characters", array(()))
#let last_speaker = state("last_speaker", none)
#let dialogue_counter = counter("dialogue")

/// Document template for a screenplay.
#let screenplay(
  /// Title of the screenplay.
  title,
  /// Content of the screenplay. This is where your `#show` should direct the
  /// rest of the document.
  doc,
  /// Font to use. Industry standard dictates that this should be a Courier
  /// variant. There's debate about which variants are acceptable or preferable,
  /// this template defaults to looking for the most popular ones in order of
  /// preferability.
  ///
  /// Courier New is the least preferred, but will be used if nothing else is
  /// available. The author recommends downloading Courier Prime, which is
  /// freely available, if you don't already have a Courier other than Courier
  /// New.
  font: ("Courier Final Draft", "Courier", "Courier Prime", "Courier New"),
  /// Full name of the author.
  author: none,
  /// Contact info. Usuall begins with the author's name, an address, and an
  /// email. May also include a phone number. The template doesn't break this
  /// field down much further to avoid dictating preference.
  contact: none) = {
  set page(
    paper: "us-letter",
    margin: ( top: 1in, left: 1.5in, right: 1in, bottom: 0.5in),
    header-ascent: 0.5in,
  )
  set text(
    font: font,
    size: 12pt,
  )
  set par(spacing: line_spacing(1))

  show heading: h => {
    set text(size: 12pt, weight: "regular")
    set block(spacing: line_spacing(1))
    h
  }

  page({
    align(center, {
      upper(title)

      if author != none {
        block([Written By], above: 1in)
        block(author, spacing: 0.5in)
      }
    })

    if contact != none {
      align(right + bottom, box(align(left, contact)))
    }
    counter(page).update(0)
  }, margin: ( top: 2in, bottom: 1in ))

  set page(
    header: context {
      if counter(page).get().at(0) > 1 {
        align(right, counter(page).display("1."))
      }
    },
  )

  block("FADE IN:", spacing: line_spacing(0))
  doc
  align(right, block("FADE OUT.", spacing: line_spacing(1)))
  align(center, block("THE END", spacing: line_spacing(0)))
}

/// This function should be used to wrap the first occurance of a character's
/// name, which in turn must be before the first line of dialogue that character
/// speaks. It will force the name into all caps as per convention.
#let intro(character) = {
  context {
    let characters_local = characters.get()
    assert(
      characters_local.contains(upper(character.text)) == false,
      message: "Introduced character twice"
    )
    characters_local.push(upper(character.text))
    characters.update(characters_local)
    upper(character)
  }
}

/// A dialogue section. Takes a character name and the dialogue to speak.
///
/// The `paren` argument indicates a parenthetical to appear on the same line as
/// the character name, usually one of a few industry abbreviations like
/// `(O.S.)` or `(V.O.)`.
///
/// This function will validate that the character has been previously
/// introduced with the `intro` function.
#let dialogue(character, dialogue, paren: none) = {
  context {
    set par(spacing: line_spacing(0))
    let char_text = if type(character) == str {
      character
    } else {
      character.text
    }
    last_speaker.update(upper(char_text))
    assert(
      characters.get().contains(upper(char_text)),
      message: "Never introduced character"
    )
    dialogue_counter.step()
    let dialogue_count = dialogue_counter.get().at(0)
    let dialogue_header_counter = counter("dialogue_header" + str(dialogue_count))
    let dialogue_footer_counter = counter("dialogue_footer" + str(dialogue_count))
    grid(
      grid.header(block(par([#upper(context {
        dialogue_header_counter.step()
        let paren = if dialogue_header_counter.get() != (0,) {
          "CONT’D"
        } else {
          paren
        }
        character
        if paren != none {
          [ (#paren)]
        }
      })]), inset: (left: 1.5in))),
      block(dialogue, spacing: line_spacing(0)),
      grid.footer(block({
        dialogue_footer_counter.step()
        context {
          if dialogue_footer_counter.get() != dialogue_footer_counter.final() {
            [(MORE)]
          }
        }
      },inset: (left: 1.5in), spacing: line_spacing(0))),
      inset: (left: 1in, right: 1.5in),
      gutter: line_spacing(0),
    )
  }
}

/// A dialogue section that continues from the previous one. Will have a header
/// with the same character name as the previous dialogue section followed by
/// `(CONT'D)`. You should use this any time a dialogue section is broken up
/// with some brief description. You shouldn't use it across scene boundaries or
/// when a long beat separates two discontinuous pieces of dialogue from the
/// same character.
#let more-dialogue(d) = {
  context {
    assert(last_speaker.get() != none)
    dialogue(last_speaker.get(), d, paren: "CONT’D")
  }
}

/// A parenthetical within a dialogue section.
#let parenthetical(content) = {
  context{
    block(
      par([(#content)], hanging-indent: measure("(").width),
      inset: (left: 0.5in, right: 1in), spacing: line_spacing(0)
    )
  }
}

/// A scene header. The `int-ext` field is usually either `INT` or `EXT`
/// indicating an interior or exterior shot, the `location` field is a brief
/// description of the scene's location, and the `time` field is the time of day
/// when the scene occurs, usually one of `DAY` or `NIGHT`.
#let scene(int-ext, location, time) = {
  heading(block(upper([#int-ext. #location - #time]), above: line_spacing(2), below: line_spacing(1)))
}

/// Indicates some text to be shown on screen during the film.
#let title-over(title) = {
  block({
    block("TITLE OVER:", spacing: line_spacing(1))
    align(center, block(title))
  }, breakable: false, width: 100%, below: line_spacing(2))
}

/// A transition such as `CUT TO:` or `INTERPOSE WITH:`
#let transition(name) = {
  align(right, block([#upper(name):], spacing: line_spacing(1), inset: (right: 2em)))
}

/// An action header. This is like a mini-scene header used for fast-paced
/// scenes. It has no `INT./EXT.` and no time of day, and the content is more
/// free-form. See the example to better understand usage.
#let action(content) = {
  block(upper(content), spacing: line_spacing(1))
}
