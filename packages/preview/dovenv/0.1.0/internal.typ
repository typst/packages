
#let line-re = ```re
\s*(?:export\s+)?([\w.-]+)(?:\s*=\s*?|:\s+?)(\s*'(?:\\'|[^'])*'|\s*"(?:\\"|[^"])*"|\s*`(?:\\`|[^`])*`|[^#\r\n]+)?\s*(?:#.*)?
```;
#let line-re = regex(line-re.text.trim())

#let clear-line = regex("\r\n?")
#let quote-re(quote) = regex("^([" + quote + "])([\s\S]*)" + quote + "$")
#let quote-re = ("'", "\"", "`").map(quote-re)

/// Parses a dotenv-syntax content into a dictionary.
///
/// - lines (str): The content of the `.env` file.
/// -> dictionary
#let parse-env(lines) = {
  lines
    .replace(clear-line, "\n")
    .matches(line-re)
    .map(line => {
      let (key, value) = line.captures
      if value == none {
        value = ""
      }
      value = value.trim()
      if value.starts-with("'") {
        value = value.replace(quote-re.at(0), it => it.captures.at(1))
      } else if value.starts-with("\"") {
        value = value.replace(quote-re.at(1), it => it.captures.at(1)).replace("\\n", "\n").replace("\\r", "\r")
      } else if value.starts-with("`") {
        value = value.replace(quote-re.at(2), it => it.captures.at(1))
      }

      (key, value)
    })
    .to-dict()
}
