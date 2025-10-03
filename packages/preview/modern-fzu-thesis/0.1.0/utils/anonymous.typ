#let anonymize(
  // documentclass 传入参数
  anonymous: false,
  // 其他参数
  info: (:),
  anonymous-info-keys: ("student-id", "author", "supervisor", "supervisor-ii", "department"),
  anonymous-keywords: ("福州大学", "FZU", "Fuzhou University"),
  doc,
) = {
  if not anonymous {
    doc
    return
  }

  let block-list = anonymous-keywords
  for (key, value) in info {
    if key in anonymous-info-keys {
      if type(value) == array {
        block-list = (block-list + (value.at(0),))
      } else if type(value) == str {
        block-list = (block-list + (value,))
      }
    }
  }
  block-list = block-list.filter(it => it != "")
  let block-regex = block-list.join("|")
  // [#block-regex]
  show regex(block-regex): it => context {
    let block-size = measure(it)
    box(rect(..block-size, fill: black))
  }

  doc
}

#show: (..args) => anonymize(
  ..args,
  anonymous: true,
  info: (
    "author": "test",
    "major": ("123", "456"),
  ),
)


if there 123123 123456is test in the context
