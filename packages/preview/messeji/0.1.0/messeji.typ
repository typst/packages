#let parse-json(
  path,
) = {
  let chat-obj = json(path)
  return chat-obj.at("messages")
}

#let _to_int(s) = {
  let no_prefix = s.trim("0")
  if no_prefix.len() == 0 {
    return 0
  } else {
    return int(no_prefix)
  }
}

#let _parse_timestamp_iso_8601(s) = {
  let split = s.split("T")
  let day = split.at(0).trim()
  let time = split.at(1).trim()

  let day_parts = day.split("-")
  let time_parts = time.split(":")

  return datetime(
    year: _to_int(day_parts.at(0)),
    month: _to_int(day_parts.at(1)),
    day: _to_int(day_parts.at(2)),
    hour: _to_int(time_parts.at(0)),
    minute: _to_int(time_parts.at(1)),
    second: _to_int(time_parts.at(2)),
  )
}

#let chat-bubble(
  message,
  quote: "",
  msg-align: "left", // "left" or "right",
) = {
  // Global Settings
  let bubble-inset = 0.6em
  let radius = 0.8em
  let tail = true

  // Left / Right theme settings
  let me = (
    background-color: rgb("#3797F0"),
    color: white,
  )

  let other = (
    background-color: rgb(239, 239, 239),
    color: black,
  )

  // Rendering
  let is-right = msg-align == "right"
  let theme = other
  if is-right {
    theme = me
  }

  // optional: quoted message
  align(
    if is-right { right } else { left },
    block(
      breakable: false,
      stack(
        spacing: 2pt,
        if quote != "" {
          v(2pt)
          align(
            horizon,
            stack(
              dir: ltr,
              spacing: 4pt,
              if not is-right {
                rect(
                  width: 3pt,
                  height: 20pt,
                  radius: 1.5pt,
                  fill: other.at("background-color"),
                )
              },
              block(
                width: auto,
                inset: bubble-inset,
                fill: other.at("background-color"), // quotes are always in "other theme"
                radius: radius,
                align(
                  left,
                  text(
                    other.at("color"),
                    size: 0.875em,
                    quote,
                  ),
                ),
              ),
              if is-right {
                rect(
                  width: 3pt,
                  height: 20pt,
                  radius: 1.5pt,
                  fill: other.at("background-color"),
                )
              },
            ),
          )
        },
        // actual message
        block(
          width: auto,
          inset: bubble-inset,
          fill: theme.at("background-color"),
          radius: (
            top-left: radius,
            top-right: radius,
            bottom-left: if is-right or not tail { radius } else { 0pt },
            bottom-right: if is-right and tail { 0pt } else { radius },
          ),
          align(
            left,
            text(
              theme.at("color"),
              size: 0.9375em,
              message,
            ),
          ),
        ),
      ),
    ),
  )
}

#let messeji(
  // Parsed chat data, e.g., parse-json("path")
  // Required structure: [
  //    {...},
  //    ...
  // ]
  chat-data: none,
  date-changed-format: none,
  timestamp-format: "[year]-[month]-[day] [hour]:[minute]",
  theme: none, // used in later releases
) = {
  if chat-data.len() == 0 {
    return
  }

  let last_day = 0
  let previous_sender = chat-data.first().at("from_me")

  for (i, msg) in chat-data.enumerate() {
    // Alignment
    let msg_align = "left"
    if "from_me" in msg {
      if msg.at("from_me") {
        msg_align = "right"
      }
    }

    let time_str = ""
    let date_str = ""
    if "date" in msg {
      let date_val = msg.at("date")
      let parsed_date = _parse_timestamp_iso_8601(date_val)

      if date-changed-format != none and last_day != parsed_date.day() {
        date_str = parsed_date.display(date-changed-format)
        last_day = parsed_date.day()
      }
      // show time
      time_str = parsed_date.display(timestamp-format)
    }

    // add padding depending on
    if previous_sender != msg.at("from_me") {
      // different sender -> more padding
      previous_sender = msg.at("from_me")
      if not "date" in msg {
        v(16pt)
      } else {
        v(4pt)
      }
    } else {
      // same sender
      v(4pt)
    }

    let quote = ""
    if "ref" in msg {
      quote = msg.at("ref")
    }

    if "msg" in msg {
      block(
        breakable: false,
        width: 100%,
        stack(
          dir: ttb,
          if date_str != "" {
            align(center)[
              #v(16pt)
              #text(size: 1.5em, date_str)
              #v(8pt)
            ]
          },
          if time_str != "" {
            align(center)[
              #v(16pt)
              #text(rgb(101, 103, 107), time_str)
              #v(8pt)
            ]
          },
          chat-bubble(
            msg.at("msg"),
            quote: quote,
            msg-align: msg_align,
          ),
        ),
      )
    }
  }
}
