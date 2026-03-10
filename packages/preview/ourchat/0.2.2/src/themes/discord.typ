/// Discord theme
#import "../components.typ": *
#import "../utils.typ": auto-mention-rule, resolve-layout, resolve-theme, stretch-cover

// discord peeps only use da dak deme
#let default-theme = (
  background: oklab(21.9499%, 0.00211129, -0.00744916),
  text-normal: oklab(95.2331%, 0.000418991, -0.00125992),
  text-muted: oklab(61.1686%, 0.00218612, -0.0118227),
  text-link: oklab(67.0158%, -0.038477, -0.141411),
  text-username: oklab(98.8044%, 0.0000450313, 0.0000197887),
  divider-color: rgb(151, 151, 159, 12%),
  code-background: oklab(57.738%, 0.0140701, -0.208587, 07.84314%),
  code-border: oklab(67.8888%, 0.00325716, -0.011175, 20%) + 0.8pt,
)

#let builtin-themes = (
  default: default-theme,
)

/// Layout constants that can be overridden
#let default-layout = (
  // Overall layout
  content-scale: 75%,
  content-inset: (y: 16pt),
  group-spacing-start: 1.0625em,
  message-margin-left: 72pt,
  message-margin-right: 24pt,
  avatar-size: 40pt,
  // Text sizing
  main-text-size: 17pt,
  message-text-size: 1em,
  username-text-size: 1em,
  timestamp-text-size: 0.75em,
  code-block-text-size: 0.85em,
  code-inline-text-size: 0.85em,
  // Paragraph formatting
  par-leading: 0.375em, // line-height: 1.375em
  par-spacing: 0.25em + 0.375em, // spacing: 0.25em
  markup-line-height: 1.375em,
  username-line-height: 1.375em,
  // Time divider styling
  divider-above: 1.5em,
  divider-below: 0.5em,
  divider-left: 1.0em,
  divider-right: 0.875em,
  time-line-stroke: 0.8pt,
  // Others
  code-border-radius: 4pt,
  code-block-inset: 0.5em,
  code-inline-inset: (x: 0.2em),
  code-inline-outset: (y: 0.375em),
)

/// Discord newbie badge icon.
#let newbie = image(width: 15pt, "../assets/discord-newbie.svg")

/// A pre-configured user with Discord's newbie badge.
///
/// This is a convenience user that comes with the Discord newbie badge as a title.
/// Perfect for showcasing new Discord users in chat mockups.
#let newbie-user = user.with(badge: newbie)

/// Create a Discord-style mention element.
///
/// This function creates a styled mention box that resembles Discord's `@username` mentions.
/// The mention has a blue background with rounded corners and specific Discord colors.
///
/// This component is hard to customize due to lack of custom element. You can create your own
/// mention component for a different style.
///
/// - body (content): The username or text to be mentioned.
/// -> content: Styled mention box
#let mention(body) = {
  box(
    fill: oklab(57.738%, 0.0140701, -0.208587, 23.9216%),
    inset: (x: 2pt),
    outset: (y: 0.375em / 2),
    radius: 3pt,
    text(fill: oklab(80.1297%, 0.00579226, -0.0997229), weight: "medium", align(horizon)[\@#body]),
  )
}

/// Create a show rule for Discord-style code blocks.
///
/// This function returns a show rule that styles code blocks with Discord's
/// characteristic dark background, border, and padding.
///
/// - sty (dictionary): Style dictionary containing Discord theme values.
/// - body (content): The code block content to be styled.
/// -> content: Styled code block
#let raw-block-rule(sty, body) = {
  show: pad.with(right: sty.message-margin-left)
  set text(size: sty.code-block-text-size)
  show: block.with(
    width: 100%,
    inset: sty.code-block-inset,
    fill: sty.code-background,
    stroke: sty.code-border,
    radius: sty.code-border-radius,
  )
  body
}

/// Create a show rule for Discord-style inline code.
///
/// This function returns a show rule that styles inline code with Discord's
/// characteristic background and subtle border styling.
///
/// - sty (dictionary): Style dictionary containing Discord theme values.
/// - body (content): The inline code content to be styled.
/// -> content: Styled inline code
#let raw-inline-rule(sty, body) = {
  set text(size: sty.code-inline-text-size)
  show: box.with(
    outset: sty.code-inline-outset,
    inset: sty.code-inline-inset,
    fill: sty.code-background,
    stroke: sty.code-border,
    radius: sty.code-border-radius,
  )
  body
}

/// Create a Discord style chat.
///
/// - theme (str, dictionary): The chat theme.
/// - layout (dictionary): Override layout constants.
/// - width (length): The width of the content block.
/// - validate (bool): Validate the style fields.
/// - messages: The items created by `time` or `message`.
///
/// -> content
#let chat(
  theme: auto,
  layout: (:),
  width: 640pt,
  validate: true,
  auto-mention: true,
  ..messages,
) = {
  let sty = (
    resolve-theme(builtin-themes, theme, default: "default", validate: validate)
      + resolve-layout(layout, default-layout, validate: validate)
  )

  show: scale.with(sty.content-scale, reflow: true)
  show: block.with(
    width: width,
    inset: sty.content-inset,
    fill: sty.background,
  )
  set text(size: sty.main-text-size)
  set par(leading: sty.par-leading, spacing: sty.par-spacing)
  show raw.where(block: true): raw-block-rule.with(sty)
  show raw.where(block: false): raw-inline-rule.with(sty)

  show: auto-mention-rule(auto-mention, mention)

  for (i, msg) in messages.pos().enumerate() {
    if msg.kind == "time" {
      show: block.with(
        width: 100%,
        height: 0pt,
        above: sty.divider-above,
        below: sty.divider-below,
        inset: (
          left: sty.divider-left,
          right: sty.divider-right,
        ),
      )
      show: block.with(width: 100%, stroke: (top: sty.divider-color + sty.time-line-stroke))
      set align(horizon + center)
      show: block.with(height: 13pt, inset: (x: 4pt, y: 2pt), fill: sty.background)
      set text(
        fill: sty.text-muted,
        cjk-latin-spacing: none,
        size: 12pt,
        weight: 600,
      )
      msg.body
    } else if msg.kind == "message" or msg.kind == "plain" {
      let user = msg.user

      let avatar-block = {
        set align(center)
        show: block.with(width: sty.avatar-size, height: sty.avatar-size, radius: 50%, clip: true)
        stretch-cover(user.avatar)
      }

      let header-block = {
        show: block.with(height: sty.username-line-height)
        set align(horizon)
        set text(
          size: sty.username-text-size,
          fill: sty.text-username,
          cjk-latin-spacing: none,
          weight: 500,
        )
        let items = (
          if user.name != none {
            text(
              fill: sty.text-username,
              user.name,
            )
          },
          user.badge,
          if msg.time != none {
            text(
              fill: sty.text-muted,
              size: sty.timestamp-text-size,
              msg.time,
            )
          },
        )
        stack(dir: ltr, spacing: 0.5em, ..items.filter(it => it != none))
      }

      let message-block = {
        set text(size: sty.message-text-size, fill: sty.text-normal, cjk-latin-spacing: none)
        show link: set text(fill: sty.text-link)

        if msg.kind == "message" {
          block(width: 100%, align(left, msg.body))
        }
      }

      show: block.with(above: sty.group-spacing-start)
      place(left, dx: sty.message-margin-left / 2, dy: 4pt - 0.125em, place(center, avatar-block))
      show: pad.with(left: sty.message-margin-left, right: sty.message-margin-right, y: 0.125em)
      header-block
      v(6pt, weak: true)
      message-block
    }
  }
}
