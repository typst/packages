
/// Default light theme
#let light-theme = (
  right-text-color: rgb("#0f170a"),
  left-text-color: rgb("#191919"),
  right-link-color: rgb("#576b95"),
  left-link-color: rgb("#576b95"),
  name-color: rgb("#888888"),
  left-bubble-color: rgb("#ffffff"),
  right-bubble-color: rgb("#95ec69"),
  bg-color: rgb("#ededed"),
)

/// Default dark theme
#let dark-theme = (
  right-text-color: rgb("#06120b"),
  left-text-color: rgb("#d5d5d5"),
  right-link-color: rgb("#375082"),
  left-link-color: rgb("#7d90a9"),
  name-color: rgb("#888888"),
  left-bubble-color: rgb("#2c2c2c"),
  right-bubble-color: rgb("#3eb575"),
  bg-color: rgb("#111111"),
)

/// The default profile of Ourchat
#let default-profile = image("default-profile.png")

/// Create a datetime item.
///
/// - body (content): The datetime body.
#let datetime(body) = {
  (kind: "datetime", body: body)
}

/// Create a message item.
///
/// - side: The message side (left | right).
/// - body (content): The message body.
/// - name (content): The name of sender.
/// - profile (content): The profile of sender.
#let message(side, body, name: none, profile: none) = {
  (kind: "message", side: side, body: body, name: name, profile: profile)
}

/// Create a plain item. Different from `message`, it does not have padding.
///
/// - side: The image side (left | right).
/// - body (content): The image body.
/// - name (content): The name of sender.
/// - profile (content): The profile of sender.
#let plain(side, body, name: none, profile: none) = {
  (kind: "plain", side: side, body: body, name: name, profile: profile)
}

/// Create a chat.
///
/// - messages: The items created by `datetime` or `message`.
/// - theme (str, dictionary): The chat theme.
/// - width (length): The width of the whole block.
/// - left-profile (content): The default profile for the left user.
/// - right-profile (content): The default profile for the right user.
///
/// -> content
#let chat(
  ..messages,
  theme: "light",
  width: 270pt,
  left-profile: none,
  right-profile: none,
) = {
  // prepare theme
  let color-theme = if theme == "light" {
    light-theme
  } else if theme == "dark" {
    dark-theme
  } else {
    assert(type(theme) == dictionary, message: "the custom theme should be a dictionary!")
    light-theme + theme
  }
  let left-theme = (
    text-color: color-theme.left-text-color,
    link-color: color-theme.left-link-color,
    bubble-color: color-theme.left-bubble-color,
    sign: 1,
    profile-x: 0,
  )
  let right-theme = (
    text-color: color-theme.right-text-color,
    link-color: color-theme.right-link-color,
    bubble-color: color-theme.right-bubble-color,
    sign: -1,
    profile-x: 2,
  )

  set par(leading: 0.575em, spacing: 0.65em)

  let cells = ()

  for (i, msg) in messages.pos().enumerate() {
    if msg.kind == "datetime" {
      let cell = block(
        height: 1.4em,
        align(center + horizon, text(size: 0.7em, fill: color-theme.name-color, cjk-latin-spacing: none, msg.body)),
      )
      cells.push(grid.cell(x: 1, y: i, align: center, cell))
    } else if msg.kind == "message" or msg.kind == "plain" {
      let sub-theme = if msg.side == left {
        left-theme
      } else {
        right-theme
      }
      let profile = msg.profile
      if profile == none {
        profile = if msg.side == left {
          left-profile
        } else {
          right-profile
        }
      }

      let body-block = {
        set block(spacing: 1pt)
        set text(size: 11.5pt)
        show link: set text(sub-theme.link-color)

        // sender name
        if msg.name != none {
          block(
            height: 1em,
            align(horizon, text(size: 0.7em, fill: color-theme.name-color, cjk-latin-spacing: none, msg.name)),
          )
        }

        if msg.kind == "message" {
          let bubble-color = sub-theme.bubble-color

          // small tip
          place(
            msg.side,
            dy: 9pt,
            rotate(
              45deg * sub-theme.sign,
              origin: top,
              rect(width: 6pt, height: 6pt, radius: 1pt, fill: bubble-color),
            ),
          )

          // message body
          block(
            fill: bubble-color,
            radius: 2.5pt,
            inset: 0.8em,
            text(fill: sub-theme.text-color, align(left, msg.body)),
          )
        } else if msg.kind == "plain" {
          block(radius: 2.5pt, clip: true, msg.body)
        }
      }

      let profile-block = block(width: 100%, radius: 2.5pt, clip: true, profile)
      cells.push(grid.cell(x: 1, y: i, align: msg.side, body-block))
      cells.push(grid.cell(x: sub-theme.profile-x, y: i, profile-block))
    }
  }

  show: block.with(width: width, fill: color-theme.bg-color, inset: 8pt)
  grid(columns: (27pt, 1fr, 27pt), row-gutter: 0.65em, column-gutter: 7.5pt, ..cells)
}
