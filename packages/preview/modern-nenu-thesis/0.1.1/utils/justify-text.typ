//! Reference: https://github.com/nju-lug/modern-nju-thesis
// 双端对齐一段小文本，常用于表格的中文 key
#let justify-text(with-tail: false, tail: "：", dir: ltr, body) = {
  if with-tail and tail != "" {
    stack(dir: dir, stack(dir: dir, spacing: 1fr, ..body.split("").filter(it => it != "")), tail)
  } else {
    stack(dir: dir, spacing: 1fr, ..body.split("").filter(it => it != ""))
  }
}
