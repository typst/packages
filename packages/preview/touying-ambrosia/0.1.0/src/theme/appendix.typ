#import "../touying.typ": appendix, touying-set-config


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
  touying-set-config(
    (appendix: true),
    defer: true,
    {
      counter(heading).update(0)
      set heading(numbering: numbering)
      body
    },
  )
}
