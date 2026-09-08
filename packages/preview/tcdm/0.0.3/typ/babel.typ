#let _lang = sys.inputs.at("lang", default: "en")

#let babel(en: "", zh: "") = {
  let n-translated = int(en != "") + int(zh != "")
  let n-all = 2

  // Add “todo”
  if n-translated >= 1 {
    if zh == "" {
      zh = "TODO: 待译"
    }
    if en == "" {
      en = "TODO: to be translated"
    }
  }
  // Emit a warning
  if n-translated < n-all {
    let _warning = text(
      // Font names will be lowercased
      font: (
        "\n[WARNING] To be translated: babel(en: {en}, zh: {zh})"
      )
        .replace("{en}", repr(en))
        .replace("{zh}", repr(zh)),
      {},
    )
  }

  if _lang == "en" {
    en
  } else if _lang == "zh" {
    zh
  } else {
    assert(false, message: "Unknown language: " + _lang)
  }
}

/// A dictionary of reusable strings.
///
/// One-off strings are not saved here. They should be managed in place.
#let BABEL = (
  last-commit-pushed-at: babel(
    en: "the last commit was pushed at {}",
    zh: "最后一次提交推送于{}",
  ),
  latest-release-published-at: babel(
    en: "the latest release was published at {}",
    zh: "最新版本发布于{}",
  ),
  per-month: babel(
    en: " / month",
    zh: " / 月",
  ),
  monthly-downloads: babel(
    en: "{} downloads per month",
    zh: "每月{}次下载",
  ),
)
