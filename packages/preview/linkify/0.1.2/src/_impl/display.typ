/// Generate nicely formatted, clickable links to media contents that can be directly inserted into articles. The media contents are mostly displayed by their content IDs. For example:
///
/// - The video BVID or AVID in monospaced font is used for Bilibili videos.
/// - Bilibili or Twitter (X) usernames are displayed in monospaced font preceded by an `@` symbol.
/// - Wikipedia and Moegirl Pedia's entries are displayed as their entry titles in formatted text.
///
/// If you want to customize the display content instead of using the default content ID, you can use the `linkify.url` sub-libray to generate string URLs and put it in a `link` element with custom content instead.
///
///
/// 为互联网内容平台的内容生成格式化的超链接。在大部分的情况下，链接文本会显示为对应平台的内容 ID, 例如：
///
/// - B 站视频以等宽字体显示为 BVID 或 AVID.
/// - B 站、推特 (X) 用户显示为以 `@` 开头的用户名。
/// - 维基百科和萌娘百科的条目以常规文本字体显示为格式化的条目名。
///
/// 如果希望自定义显示内容，而不是使用默认的内容 ID, 可以使用 `linkify.url` 子模块生成字符串链接，结合 `link` 元素显示自定义内容。

#import "./init.typ": missing
#import "./url.typ" as url_
#import "../bili.typ" as bili_
#import "./utils.typ": with-smartquote

#let url-prefixes = ("mailto", "tel")

/// Turn `link` elements that directly displays a URL into `raw` format.
/// This function is intended to be used in a  `show` rule and will not affect `link` elements that have alternative content specified.
///
/// ```example
/// #show: url-as-raw
/// #link("https://typst.app/docs") and            // This will be affected
/// #link("https://typst.app/docs")[Typst Docs]    // But this will not
/// ```
///
/// - it (content): the content to apply the `show` rule to
/// -> content
#let /*pub*/ url-as-raw(body) = {
  show link: it => {
    if (
      it.body.func() == text and
      type(it.dest) == str
    ) {
      let src = it.dest
      for prefix in url-prefixes {
        if src.starts-with(prefix + ":") {
          src = src.slice(prefix.len() + 1)
          break
        }
      }
      if src == it.body.text {
        link(it.dest, raw(src))
      } else { it }
    } else { it }
  }
  body
}

#let /*pub*/ bili(..args, uid: missing, format: auto, prefix: true) = {
  let pos-args = args.pos()
  if uid != missing {
    assert.eq(type(uid), int)
    let display-text = if pos-args.len() == 0 {
      "uid" + str(uid)
    } else if pos-args.len() == 1 {
      let (username,) = pos-args
      assert.eq(type(username), str)
      "@" + username
    } else {
      panic("Too many positional arguments.")
    }
    let url = url_.bili(uid: uid)
    link(url, raw(display-text))
  } else {
    assert.eq(pos-args.len(), 1, message: "Incorrect number of positional arguments")
    let (video-id,) = pos-args
    let url = url_.bili(video-id)
    let display-text = bili_.video-id-fmt(
      video-id,
      format: format,
      prefix: prefix
    )
    link(url, raw(display-text))
  }
}

#let /*pub*/ youtube(..args, ch: missing) = {
  if ch != missing {
    let url = url_.youtube(ch: ch)
    link(url, raw("@" + ch))
  } else {
    let url = url_.youtube(..args)
    let (video-id,) = args.pos()
    link(url, raw(video-id))
  }
}

#let /*pub*/ weixin(..args) = {
  let pos-args = args.pos()
  if pos-args.len() == 1 {
    let (article-id,) = pos-args
    let url = url_.weixin(article-id)
    link(url, raw(article-id))
  } else if pos-args.len() == 2 {
    let (biz, account-name) = pos-args
    assert(type(account-name) == str or type(account-name) == content)
    let url = url_.weixin(biz: biz)
    link(url, account-name)
  } else {
    panic("Invalid number of positional arguments.")
  }
}

#let /*pub*/ wiki(
  title,
  lang: "en",
  section: none,
  delimiter: [ #sym.section],
  ..args,
) = {
  let pos-args = args.pos()
  let url = url_.wiki(title, lang: lang, section: section)
  let display-content = if pos-args.len() > 0 {
    pos-args.at(0)
  } else {
    text(
      with-smartquote(title.replace("_", " ")) +
      if section != none {
        delimiter + with-smartquote(section.replace("_", " "))
      },
      lang: lang
    )
  }
  link(url, display-content)
}

#let moegirl-replacements = (
  "o": "○",
  "x": "×",
)

#let moegirl-title-replace(title) = {
  title
  .replace("_", " ")
  // replace wildcard characters `oo` and `xx`
  .replace(
    regex("([a-np-wy-z]?)(o{2,}|x{2,})([a-np-wy-z]?)"),
    ((text, captures)) => {
      if captures.at(0) == "" and captures.at(2) == "" {
        let count = captures.at(1).len()
        let sym = captures.at(1).at(0)
        moegirl-replacements.at(sym) * count
      } else {
        text
      }
    }
  )
}

#let /*pub*/ moegirl(
  title,
  ..args,
  section: none,
  delimiter: [ #sym.section],
) = {
  let url = url_.moegirl(title, ..args, section: section)
  let display-content = (
    with-smartquote(moegirl-title-replace(title)) +
    if section != none {
      delimiter + with-smartquote(moegirl-title-replace(section))
    }
  )
  link(url, display-content)
}

#let /*pub*/ twitter(user-id) = {
  let url = url_.twitter(user-id)
  link(url, raw("@" + user-id))
}

#let /*pub*/ isbn(id, ..args, prefix: true, dash: true) = {
  let url = url_.isbn(id, ..args)
  let id = if dash { id } else { id.replace("-", "") }
  let display-text = if prefix { "ISBN " } + id
  link(url, raw(display-text))
}


#let /*pub*/ B站 = bili
#let /*pub*/ 微信 = weixin
#let /*pub*/ 油管 = youtube
#let /*pub*/ 维基 = wiki
#let /*pub*/ 萌百 = moegirl
#let /*pub*/ 推特 = twitter
#let /*pub*/ X = twitter