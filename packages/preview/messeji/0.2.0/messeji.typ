#let default-theme = (
  timestamp-color: rgb(101, 103, 107),
  timestamp-size: .9em,
  date-changed-color: black,
  date-changed-size: 1.5em,
  me-right: (
    color: white,
    background-color: rgb("#3797F0"),
    quote-color: black,
    quote-background-color: rgb(239, 239, 239),
  ),
  other-left: (
    color: black,
    background-color: rgb(239, 239, 239),
    quote-color: black,
    quote-background-color: rgb(239, 239, 239),
  ),
)

#let _fill_dict_default(
  actual,
  default,
) = {
  // iterate over every key of default

  let result = (:)

  for (key, value) in default.pairs() {
    // if key exists in actual dictionary, use its value
    if key in actual {
      // check for nested dictionary -> recursive call
      if type(actual.at(key)) == dictionary {
        result.insert(key, _fill_dict_default(actual.at(key), default.at(key)))
      } else {
        result.insert(key, actual.at(key))
      }
    } else {
      // insert value from default dictionary
      result.insert(key, value)
    }
  }

  return result
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
  theme, // dictionary, see default-theme
  message,
  quote: "",
  msg-align: "left", // "left" or "right",
) = {
  // Global Settings
  let bubble-inset = 0.6em
  let radius = 0.8em
  let tail = true

  // Rendering
  let is-right = msg-align == "right"
  let curr-theme = theme.other-left
  if is-right {
    curr-theme = theme.me-right
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
                // vertical line next to quoted message
                rect(
                  width: 3pt,
                  height: 20pt,
                  radius: 1.5pt,
                  fill: curr-theme.at("quote-background-color"),
                )
              },
              block(
                width: auto,
                inset: bubble-inset,
                fill: curr-theme.at("quote-background-color"),
                radius: radius,
                align(
                  left,
                  text(
                    curr-theme.at("quote-color"),
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
                  fill: curr-theme.at("quote-background-color"),
                )
              },
            ),
          )
        },
        // actual message
        block(
          width: auto,
          inset: bubble-inset,
          fill: curr-theme.at("background-color"),
          radius: (
            top-left: radius,
            top-right: radius,
            bottom-left: if is-right or not tail { radius } else { 0pt },
            bottom-right: if is-right and tail { 0pt } else { radius },
          ),
          align(
            left,
            text(
              curr-theme.at("color"),
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
  chat-data: [], // array of messages
  date-changed-format: none,
  timestamp-format: "[year]-[month]-[day] [hour]:[minute]",
  theme: (:), // theme dictionary, if value is not filled, default is used
) = {
  if chat-data.len() == 0 {
    return
  }

  let curr-theme = _fill_dict_default(theme, default-theme)

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
              #text(curr-theme.at("date-changed-color"), size: curr-theme.at("date-changed-size"), date_str)
              #v(8pt)
            ]
          },
          if time_str != "" {
            align(center)[
              #v(16pt)
              #text(curr-theme.at("timestamp-color"), size: curr-theme.at("timestamp-size"), time_str)
              #v(8pt)
            ]
          },
          chat-bubble(
            curr-theme,
            msg.at("msg"),
            quote: quote,
            msg-align: msg_align,
          ),
        ),
      )
    }
  }
}
