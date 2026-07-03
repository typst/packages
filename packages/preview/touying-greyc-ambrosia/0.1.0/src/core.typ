#import "@preview/touying:0.6.2": appendix, touying-set-config
#import "@preview/numbly:0.1.0": numbly


/// Appendix for the presentation. The last-slide-counter will be frozen at the last slide before the appendix. It is simple wrapper for `touying-set-config`, just like `#show: touying-set-config.with((appendix: true))`.
/// A metadata is injected.
///
/// Example: `#show: appendix`
///
/// - body (content): The content of the appendix.
///
/// -> content
#let appendix(
  numbering: none,
  body,
) = {
  [#metadata((kind: "touying-appendix"))<touying-metadata>]
  counter(heading).update(0)
  set heading(numbering: numbering)
  touying-set-config(
    (appendix: true),
    body,
  )
}
