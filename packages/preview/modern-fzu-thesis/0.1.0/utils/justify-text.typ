// 双端对齐一段小文本，常用于表格的中文 key
#let justify-text(with-tail: false, tail: "：", body) = {
  if with-tail and tail != "" {
    stack(dir: ltr, stack(dir: ltr, spacing: 1fr, ..body.split("").filter(it => it != "")), tail)
  } else {
    stack(dir: ltr, spacing: 1fr, ..body.split("").filter(it => it != ""))
  }
}

