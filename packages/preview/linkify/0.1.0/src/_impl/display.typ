#import "./init.typ": missing
#import "./url.typ" as url_
#import "../bili.typ" as bili_
#import "./utils.typ": with-smartquote

#let url-prefixes = ("mailto", "tel")

/// Turn `link` elements that directly displays a URL into `raw` format.
/// This function is intended to be used in a  `show` rule and will not affect `link` elements that have alternative content specified.
///
/// ```example
/// #show link: url-as-raw
/// #link("https://typst.app/docs") and            // This will be affected
/// #link("https://typst.app/docs")[Typst Docs]    // But this will not
/// ```
///
/// - it (content): a `link` element
/// -> content
#let url-as-raw(it) = {
  assert.eq(type(it), content)
  assert.eq(it.func(), link)
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

#let bili(..args, format: auto, prefix: true) = {
  let pos-args = args.pos()
  if pos-args.len() == 1 {
    let (video-id,) = pos-args
    let url = url_.bili(video-id)
    let display-text = bili_.video-id-fmt(
      video-id,
      format: format,
      prefix: prefix
    )
    link(url, raw(display-text))
  } else if pos-args.len() == 2 {
    let (user-id, username) = pos-args
    let url = url_.bili(user: user-id)
    assert.eq(type(username), str)
    link(url, raw("@" + username))
  } else {
    panic("Invalid number of positional arguments.")
  }
}

#let youtube(..args, ch: missing) = {
  if ch != missing {
    let url = url_.youtube(ch: ch)
    link(url, raw("@" + ch))
  } else {
    let url = url_.youtube(args)
    let (video-id,) = args.pos()
    link(url, raw(video-id))
  }
}

#let weixin(..args) = {
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

#let wiki(title, lang: "en") = {
  let url = url_.wiki(title, lang: lang)
  let display-content = text(with-smartquote(title.replace("_", " ")), lang: lang)
  link(url, display-content)
}

#let moegirl(title) = {
  let url = url_.moegirl(title)
  let display-content = with-smartquote(title.replace("_", " "))
  link(url, display-content)
}

#let twitter(user-id) = {
  let url = url_.twitter(user-id)
  link(url, raw("@" + user-id))
}

#let isbn(id, ..args, prefix: true, dash: true) = {
  let url = url_.isbn(id, ..args)
  let id = if dash { id } else { id.replace("-", "") }
  let display-text = if prefix { "ISBN " } + id
  link(url, raw(display-text))
}
