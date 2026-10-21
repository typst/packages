# 01 Plan Prototype

The goal of this task is to emit a plan in `plans/02_prototype.md`. The resulting plan is meant to be executed by an agent, and reviewed by a human. It should detail the necessary steps (in words) in order to arrive at a prototype; it should contain only minimal amounts of code (blocks).

## Reference

As the definitive reference, the theme uses _Trees, maps, and theorems_ by Jean-luc Doumont. For structuring and formatting a presentation Doumont suggests the following principles:

- Plan for a (very) wide margin and set everything left against it.
- Coordinate all sizes and positions, for structure and harmony.
- With each slide, convey one message (only).
- The presentation has one main message, supported by 2-5 main points, each developed by 2-5 subpoints. Each subpoint is conveyed with a slide.
- Structure the presentation like so:
  - Attention getter (A way to lead the audience to the need efficiently)
  - Need (A difference between actual and desired situations)
  - Task (What I decided/was asked to do to adress the need)
  - Main message (The one sentence I want my audience to remember)
  - Preview (A map of the body \[ideally three main points, minimum two, up to a maximum of five])
  - Point 1
  - Transition
  - Point 2
  - Transition
  - ...
  - Review (A recap of the body, leading to the conclusion)
  - Conclusion (What the above means to the audience in the end)
  - Close (A way to end the presentation clearly and elegantly)

## Template

The template should be

- simple,
- composable, and
- configurable

in that order. Specifically, the template's configuration options should compose with typst native configuration options. For example, instead of passing a `text` map/dict to a function, using `#set text(font: "Libertinus Serif", size: 11pt)` is preferable (if possible). Reference <https://typst.app/docs/tutorial/advanced-styling/> and <https://typst.app/docs/tutorial/making-a-template/> as well as <https://typst.app/docs/reference/> to produce an idiomatic template.

A non-title[^1] slide has a (configurable, per default 33%) area/margin on the left. The main content is on the right. Provide a way to insert text into the margin on the left, if needed. A usecase of this is having an image on the right, and some labels in the margin (on the left).

[^1]: Except if there is a logo. See below.

The theme should support the Preview/Transition/Review slides natively (their common terminology is _Overview_). The transition slides usually have some points muted (suppressed), while Preview/Review show all main points.

A point has a statement and an optional substatement. The statement is the what the audience should be conveyed, the substatement supports the statement. The overview slides show the point's statements (accent) and below the substatement.

Non-title slides have a message, that should be the slide's title. It should be possible to optimize the linebreaks in the message.

The footer of all non-title slides should show the current slide number out of the total slide number in the bottom right (excluding the backmatter. The backmatter optionally includes qa slides and the bibliography and is numbered with roman numerals).

The theme should support incorporating a logo. If added the logo is shown in the margin of the title slide and overview slide. On the other slides it is left of the slide's title (square). The user can configure the logo and a square version. If the square version is omitted, it is derived via the fullsize version.

Instruct the agent to read <https://github.com/typst/packages/blob/main/docs/manifest.md> to ensure adherence to typst packaging standards.

## Structure

- `lib.typ` - package entrypoint
- `src/` - contributing modules/functions (if necessary)
- `theme.typ` - theme implementation
- `examples/` - showcase/testing
- `typst.toml` - typst package manifest

## Colours

The reference suggests only using a limited set of colours. Specifically using only one accent colour.

Here are the default values (that should be configurable):

- background: #ffffff
- foreground: #221f21
- accent: #f9ab1a
- suppressed: #7a7d80

Additionally, the user should be able to overwrite accent tints that are derived from the base accent colour. For example, the reference derives #fdd9a3 (similar hue, less saturation, similar value).

## Fonts

The main (sans) font is _Noto Sans_, the main serif font is _Noto Serif_ and for monospace use _Noto Sans Mono_.

## Guidelines

- Do not reference this or any other plans.
- If necessary, copy information instead of referencing (avoiding context pollution).
- Ask the user for visual feedback/confirmation; the agent shouldn't try to verify visual details, instead they should give the user a prompt which can be answered with yes/no + explanation.
- The package is called _Prinzipien_ (German for Latin Principiae) as a homage to the [principae.be homepage](https://www.principiae.be)
