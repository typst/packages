#import "core.typ": default-matchers, error-message, i18n-item-matchers-check

// 多语言字典的数据契约：
// Multilingual dictionary contract:
// dictionary<key: str, dictionary<language: str, text: str>>
// i18n-dict-check 是内部类型检查器，符合契约返回 true，否则返回 false。
// i18n-dict-check is internal: true if the contract holds, false otherwise.
// 不添加类型标记、方法或包装字段。
// Do not add type tags, methods, or wrapper fields.
#let i18n-dict-check(dict) = {
  if type(dict) != dictionary { return false }
  for (key, translations) in dict {
    if type(key) != str or type(translations) != dictionary { return false }
    for (language, value) in translations {
      if type(language) != str or language == "" or type(value) != str {
        return false
      }
    }
  }
  true
}

// files 为语言名称到文件路径的字典；路径接受 str 或 path。
// files maps language names to file paths; values accept str or path.
// 字符串以本文件为基准，path 保留调用方创建时的位置。
// Strings resolve relative to this file; paths retain their creation location.
// 每个 TOML 文件直接保存 key = "文本"；首个文件提供基准键集合。
// Each TOML file stores key = "text" directly; the first file supplies the baseline keys.
#let i18n-dict-from(
  files,
  allow-missing: false,
  matchers: default-matchers,
) = {
  if not (i18n-item-matchers-check(matchers)) {
    assert(false, message: error-message("matchers"))
  }
  if not (type(allow-missing) == bool) {
    assert(false, message: error-message(
      "boolean",
      matchers: matchers,
      fields: (field: "allow-missing"),
    ))
  }
  if not (type(files) == dictionary) {
    assert(false, message: error-message("files", matchers: matchers))
  }
  let result = (:)
  let baseline = none
  for (language, file) in files {
    if not (language != "") {
      assert(false, message: error-message("language", matchers: matchers))
    }
    if not (type(file) == str or type(file) == path) {
      assert(false, message: error-message("file-path", matchers: matchers))
    }
    let texts = toml(file)
    if baseline == none {
      baseline = texts.keys()
    } else if not allow-missing {
      for key in texts.keys() {
        if not (key in baseline) {
          assert(false, message: error-message(
            "new-key",
            matchers: matchers,
            fields: (
              file: if type(file) == str { file } else { repr(file) },
              key: key,
            ),
          ))
        }
      }
      for key in baseline {
        if not (key in texts) {
          assert(false, message: error-message(
            "missing-key",
            matchers: matchers,
            fields: (
              file: if type(file) == str { file } else { repr(file) },
              key: key,
            ),
          ))
        }
      }
    }
    for (key, value) in texts {
      if not (type(value) == str) {
        assert(false, message: error-message(
          "translation",
          matchers: matchers,
          fields: (key: key),
        ))
      }
      let translations = result.at(key, default: (:))
      translations.insert(language, value)
      result.insert(key, translations)
    }
  }
  result
}
