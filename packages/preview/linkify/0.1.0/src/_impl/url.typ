#import "@preview/based:0.2.0": base64;
#import "./bili.typ": av2bv
#import "@preview/percencode:0.1.0": url-encode

#import "./init.typ": missing

#let bili(
  ..args,
  uid: missing
) = {
  if uid != missing {
    // user homepage link
    assert.eq(type(uid), int)
    "https://space.bilibili.com/" + str(uid)
  } else {
    // video link
    let pos-args = args.pos()
    assert.eq(pos-args.len(), 1)
    let (bvid,) = pos-args

    if type(bvid) == int {
      // AVID
      bvid = av2bv(bvid, prefix: true)
    } else if type(bvid) == str {
      // BVID
      if bvid.len() == 10 {
        bvid = "BV" + bvid
      }
      assert.eq(bvid.len(), 12, message: "Invalid BVID format.")
    } else {
      panic("Invalid ID type. Expects either a `str` BVID or an `int` AVID")
    }

    "https://www.bilibili.com/video/" + bvid
  }
}

#let weixin(
  ..args,
  biz: missing
) = {
  if biz != missing {
    // An account
    let biz = if type(biz) == str {
      biz
    } else if type(biz) == int {
      base64.encode(str(biz))
    } else {
      panic("Invalid BIZ type. Expect an integer or a Base64 encoded string.")
    }
    "https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=" + biz
  } else {
    // An article
    let pos-args = args.pos()
    assert.eq(pos-args.len(), 1)
    let (article-id,) = pos-args
    assert.eq(type(article-id), str)
    "https://mp.weixin.qq.com/s/" + article-id
  }
}

#let zhihu(
  ..args,
  q: missing,
  a: missing,
  user: missing,
) = {
  if q != missing {
    // Question
    assert.eq(type(q), int)
    let url = "https://www.zhihu.com/question/" + str(q)
    if a != missing {
      // A specific answer to the question
      assert.eq(type(a), int)
      url += "/answer/" + str(a)
    }
    url
  } else if user != missing {
    // User profile
    assert.eq(type(user), int)
    "https://www.zhihu.com/people/" + str(user)
  } else {
    // Column article
    let pos-args = args.pos()
    assert.eq(pos-args.len(), 1)
    let (article-id,) = pos-args
    assert.eq(type(article-id), str)
    "https://zhuanlan.zhihu.com/p/" + article-id
  }
}

#let youtube(
  ..args,
  ch: missing
) = {
  if ch != missing {
    assert.eq(type(ch), str)
    "https://www.youtube.com/@" + id
  } else {
    let pos-args = args.pos()
    assert.eq(pos-args.len(), 1)
    let (video-id,) = pos-args
    assert.eq(type(video-id), str)
    "https://www.youtube.com/watch?v=" + video-id
  }
}

#let isbn-src = (
  douban: id => "https://book.douban.com/isbn/" + id,
  isbndb: id => "https://isbndb.com/book/" + id,
  google: id => "https://www.google.com/search?tbs=bks:1&q=isbn:" + id,
  amazon: id => "https://www.amazon.com/s?search-alias=stripbooks&field-isbn=" + id,
)

/// book reference by ISBN
///
/// ```example
/// _The Hitchhiker's Guide to the Galaxy_: #isbn("978-0-330-25864-8")
/// ```
///
/// - id (str): 13-digit ISBN code as string. Dashes may be inserted between digits, and will be rendered as-is.
/// - src (str): source of ISBN database. Currently supported values are:
/// #table(
///   columns: 2,
///   [`src`], [],
///   [`douban`], [Douban books],
///   [`google`], [Google search],
///   [`isbndb`], [ISBNDB],
///   [`amazon`], [Amazon book search],
/// )
/// - prefix (bool): whether to prepend `"ISBN "` to the render result
/// -> str
#let isbn(
  id,
  src: "douban",
) = {
  assert.eq(type(id), str)
  isbn-src.at(src)(id.replace("-", ""))
}

#let wiki(title, lang: "en") = {
  // ensure a valid language code to prevent injection
  assert(lang.match(regex("^[a-z]{2}$")) != none)
  "https://" + lang + ".wikipedia.org/wiki/" + url-encode(title)
}

#let moegirl(title) = {
  assert.eq(type(title), str)
  "https://zh.moegirl.org.cn/" + url-encode(title)
}

#let twitter(
  ..args,
) = {
  let pos-args = args.pos()
  if pos-args.len() == 1 {
    let (user-id,) = pos-args
    assert.eq(type(user-id), str)
    "https://x.com/" + user-id
  } else if pos-args.len() == 2 {
    let (user-id, post-id) = pos-args
    assert.eq(type(user-id), str)
    assert.eq(type(post-id), int)
    "https://x.com/" + user-id + "/status/" + str(post-id)
  } else {
    panic("Incorrect number of positional arguments.")
  }
}

