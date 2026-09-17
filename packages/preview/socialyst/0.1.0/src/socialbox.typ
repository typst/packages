// ===========================================================================
//  socialyst/socialbox.typ — social-network post boxes, after ProfCollege's
//  PfCReseauxSociaux (Twitter, Facebook, Instagram, Snapchat, Mastodon).
//
//    #import "socialyst/lib.typ": *
//    #tweetbox(author: [Maxime], handle: [maxime])[A tweet.]
//    #facebookbox(author: [Léa], published: true, thread: (...))[A post.]
//    #instabox(author: [nora], caption: [sunset])[#rect(...)]
//    #snapbox(author: [Yanis])[A snap.]
//    #mastodonbox(author: [Ada], handle: [ada@mathstodon.xyz])[A toot.]
//
//  Icons: @preview/fontawesome (Font Awesome 7 Free / Brands must be
//  installed on the system, or passed with --font-path). No fonts ship
//  with this package. Labels follow text.lang (en / fr / ar).
// ===========================================================================

/// True when the surrounding text runs right-to-left.
#let is-rtl() = {
  let rtl-langs = ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi")
  if text.dir == auto { rtl-langs.contains(text.lang) } else { text.dir == rtl }
}

// ---------------------------------------------------------------------------
//  Font Awesome icons (@preview/fontawesome — desktop fonts not bundled)
// ---------------------------------------------------------------------------

#import "@preview/fontawesome:0.6.2": fa-icon

#let _fa(name, s: 11pt, paint: luma(70), solid: false, tight: false) = fa-icon(
  name, solid: solid, fill: paint, size: s,
  top-edge: if tight { "bounds" } else { "baseline" },
  bottom-edge: if tight { "bounds" } else { "baseline" })

/// A stroke circle with a FA glyph sat on its geometric centre.
/// `dir: ltr` + `place(center)` so RTL does not walk the icon sideways.
#let _circled(name, size: 0.72cm, paint: luma(40), solid: true, turn: 0deg, glyph: 0.46) = {
  let s = size * glyph
  let it = _fa(name, s: s, paint: paint, solid: solid, tight: true)
  box(width: size, height: size, radius: 50%, stroke: 1pt + paint, {
    set text(dir: ltr)
    place(center + horizon,
      if turn == 0deg { it }
      else { rotate(turn, origin: center + horizon, reflow: false, it) })
  })
}

#let ico-dots(s: 11pt, paint: luma(120), vertical: false) = {
  let it = _fa("ellipsis", s: s, paint: paint, solid: true)
  if vertical { rotate(90deg, reflow: false, it) } else { it }
}

#let ico-comment(s: 11pt, paint: luma(70)) = _fa("comment", s: s, paint: paint)
#let ico-heart(s: 11pt, paint: luma(70), filled: false) = _fa(
  "heart", s: s, paint: paint, solid: filled)
#let ico-repost(s: 11pt, paint: luma(70)) = _fa(
  "retweet", s: s, paint: paint, solid: true)
#let ico-share(s: 11pt, paint: luma(70)) = _fa("share-from-square", s: s, paint: paint)
#let ico-thumb(s: 11pt, paint: luma(70)) = _fa("thumbs-up", s: s, paint: paint)
#let ico-plane(s: 11pt, paint: luma(70)) = _fa("paper-plane", s: s, paint: paint)
#let ico-bookmark(s: 11pt, paint: luma(70), filled: false) = _fa(
  "bookmark", s: s, paint: paint, solid: filled)
#let ico-camera(s: 12pt, paint: luma(40)) = _fa(
  "camera", s: s, paint: paint, solid: true)
#let ico-send(s: 11pt, paint: luma(40)) = rotate(-40deg, reflow: false,
  _fa("location-arrow", s: s, paint: paint, solid: true))
#let ico-bell(s: 11pt, paint: luma(70)) = _fa("bell", s: s, paint: paint)
#let ico-globe(s: 11pt, paint: luma(90)) = _fa(
  "earth-americas", s: s, paint: paint, solid: true)
#let ico-reply(s: 11pt, paint: luma(70)) = _fa(
  "reply", s: s, paint: paint, solid: true)
#let ico-star(s: 11pt, paint: luma(70), filled: false) = _fa(
  "star", s: s, paint: paint, solid: filled)
#let ico-plus(s: 10pt, paint: luma(160)) = _fa(
  "circle-plus", s: s, paint: paint, solid: true)
#let ico-spock(s: 11pt, paint: rgb("#F5C518")) = _fa("hand-spock", s: s, paint: paint)

// ---------------------------------------------------------------------------
//  chrome
// ---------------------------------------------------------------------------

#let _labels() = {
  let lang = text.lang
  if lang == "fr" {
    (
      like: [J'aime], comment: [Commenter], share: [Partager],
      likes: [J'aime], add: [Ajouter un commentaire…],
      comments: [commentaires], shares: [partages],
      send: [Envoyer un Chat],
      reply: [Répondre], write: [Écrire un commentaire…],
      ago-s: n => [Il y a #n secondes],
      ago-m: n => [il y a #n min],
    )
  } else if lang == "ar" {
    (
      like: [أعجبني], comment: [تعليق], share: [مشاركة],
      likes: [إعجاب], add: [أضف تعليقاً…],
      comments: [تعليقات], shares: [مشاركات],
      send: [إرسال دردشة],
      reply: [رد], write: [اكتب تعليقاً…],
      ago-s: n => [منذ #n ثانية],
      ago-m: n => [منذ #n د],
    )
  } else {
    (
      like: [Like], comment: [Comment], share: [Share],
      likes: [likes], add: [Add a comment…],
      comments: [comments], shares: [shares],
      send: [Send a Chat],
      reply: [Reply], write: [Write a comment…],
      ago-s: n => [#n seconds ago],
      ago-m: n => [#n min ago],
    )
  }
}

#let _today() = datetime.today().display("[day padding:none] [month repr:short] [year]")

#let _initial(author) = {
  if type(author) == str {
    let t = author.trim()
    if t.len() == 0 { "•" } else { upper(t.at(0)) }
  } else { "•" }
}

#let _avatar(src, author, colour, size: 0.78cm) = {
  if src == none { none }
  else if src == auto {
    box(width: size, height: size, fill: colour, radius: 50%,
      align(center + horizon,
        text(fill: white, weight: "bold", size: size * 0.42, dir: ltr,
          _initial(author))))
  } else {
    box(width: size, height: size, clip: true, radius: 50%,
      align(center + horizon, src))
  }
}

#let _ig-ring(inner, size: 0.78cm) = {
  let ring = size + 0.11cm
  box(width: ring, height: ring, radius: 50%,
    fill: gradient.linear(
      rgb("#F58529"), rgb("#DD2A7B"), rgb("#8134AF"), rgb("#515BD4"),
      angle: 45deg),
    align(center + horizon,
      box(width: size + 0.04cm, height: size + 0.04cm, radius: 50%, fill: white,
        align(center + horizon, inner))))
}

#let _rule() = box(width: 100%, height: 0.45pt, fill: luma(226))

#let _count(n) = if n == none or n == false { [] } else {
  h(0.12em)
  text(size: 0.78em, fill: luma(90), str(n))
}

/// `@handle` as an LTR isolate, so digits in the date cannot glue to `@`.
#let _at(handle, size: 0.88em, paint: luma(120)) = if handle == none { none } else {
  box(text(dir: ltr, fill: paint, size: size)[\@#handle])
}

#let _dot() = text(fill: luma(140), size: 0.82em)[·]

/// Facebook’s blue like disc. Tight FA bounds + place(center), circle a bit larger.
#let _like-badge(size: 0.50cm) = {
  let it = _fa("thumbs-up", s: size * 0.52, paint: white, solid: true, tight: true)
  box(width: size, height: size, fill: rgb("#1877F2"), radius: 50%, {
    set text(dir: ltr)
    place(center + horizon, it)
  })
}

#let _card(W, header, body, footer, radius: 0.16cm, frame: luma(214)) = {
  block(width: W, fill: white, radius: radius,
    stroke: 0.7pt + frame, clip: true,
    {
      header
      body
      footer
    })
}

#let _header-row(avatar, names, trail, rtl) = {
  pad(x: 0.30cm, top: 0.26cm, bottom: 0.16cm,
    grid(
      columns: if avatar == none { (1fr, auto) } else { (auto, 1fr, auto) },
      column-gutter: 0.22cm, align: horizon,
      ..{
        let cells = ()
        if avatar != none { cells.push(avatar) }
        cells.push(names)
        cells.push(trail)
        cells
      },
    ))
}

#let _AV-PAL = (
  rgb("#1D9BF0"), rgb("#E91E63"), rgb("#43A047"),
  rgb("#FB8C00"), rgb("#8E24AA"), rgb("#00897B"),
)

#let _norm-reply(it, i) = {
  let d = if type(it) == dictionary { it } else { (body: it) }
  (
    author: d.at("author", default: "Anon"),
    handle: d.at("handle", default: none),
    body: d.at("body", default: d.at("text", default: [])),
    likes: d.at("likes", default: 0),
    liked: d.at("liked", default: false),
    time: d.at("time", default: none),
    avatar: d.at("avatar", default: auto),
    colour: d.at("colour", default: _AV-PAL.at(calc.rem(i, _AV-PAL.len()))),
  )
}

/// One reply / comment row. `kind` is tweet | facebook | instagram | mastodon.
#let _reply-row(kind, item, i, body-dir) = {
  let r = _norm-reply(item, i)
  let av = _avatar(r.avatar, r.author, r.colour, size: 0.56cm)
  let heart-c = if r.liked { rgb("#F91880") } else { luma(140) }
  let thumb-c = if r.liked { rgb("#1877F2") } else { luma(140) }
  let like-n = if r.likes == 0 { [] } else {
    text(size: 0.72em, fill: if r.liked { heart-c } else { luma(110) }, str(r.likes))
  }
  pad(x: 0.30cm, y: 0.14cm, {
    set text(dir: body-dir)
    grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0.18cm,
      align: (top, top, top),
      av,
      {
        set align(start)
        if kind == "instagram" {
          text(weight: "bold", size: 0.84em, r.author)
          h(0.22em)
          text(size: 0.84em, r.body)
          if r.time != none or r.likes != 0 {
            v(0.08cm)
            {
              set text(size: 0.70em, fill: luma(130))
              if r.time != none { box(text(dir: ltr, r.time)) }
              if r.time != none and r.likes != 0 {
                h(0.14em)
                _dot()
                h(0.14em)
              }
              if r.likes != 0 { box(text(dir: ltr, str(r.likes))) }
            }
          }
        } else if kind == "facebook" {
          block(width: 100%, fill: luma(244), radius: 0.28cm,
            inset: (x: 0.22cm, y: 0.14cm), {
              text(weight: "bold", size: 0.84em, r.author)
              v(0.08cm)
              text(size: 0.86em, r.body)
            })
          v(0.08em, weak: true)
          text(size: 0.70em, fill: luma(120), weight: "bold", {
            if r.liked { text(fill: rgb("#1877F2"), _labels().like) }
            else { _labels().like }
            [ · ]
            _labels().reply
            if r.time != none {
              [ · ]
              box(text(dir: ltr, r.time))
            }
          })
        } else {
          // tweet / mastodon
          text(weight: "bold", size: 0.86em, r.author)
          if r.handle != none {
            h(0.20em)
            _at(r.handle, size: 0.78em)
          }
          if r.time != none {
            h(0.16em)
            _dot()
            h(0.14em)
            box(text(dir: ltr, fill: luma(140), size: 0.76em, r.time))
          }
          v(0.09cm)
          text(size: 0.90em, r.body)
        }
      },
      {
        set align(center)
        if kind == "facebook" {
          if r.likes != 0 {
            box(inset: (top: 0.28cm), {
              ico-thumb(s: 9pt, paint: thumb-c)
              v(0.07cm)
              text(size: 0.68em, fill: thumb-c, str(r.likes))
            })
          }
        } else {
          ico-heart(s: 9pt, paint: heart-c, filled: r.liked)
          if r.likes != 0 {
            v(0.07cm)
            like-n
          }
        }
      },
    )
  })
}

#let _thread-block(kind, items, body-dir) = {
  if items == none or items == () { none }
  else {
    _rule()
    for (i, it) in items.enumerate() {
      if i > 0 and kind != "facebook" {
        pad(x: 0.30cm, box(width: 100%, height: 0.4pt, fill: luma(236)))
      }
      _reply-row(kind, it, i, body-dir)
    }
  }
}

// ---------------------------------------------------------------------------
//  tweetbox  (Twitter / X)
// ---------------------------------------------------------------------------

/// A tweet / X post. After ProfCollege `Twitter`.
#let tweetbox(
  body,
  author: [Name],
  handle: none,
  date: auto,
  avatar: auto,
  avatar-colour: rgb("#1D9BF0"),
  published: false,
  comments: auto,
  reposts: auto,
  likes: auto,
  liked: false,
  thread: (),
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let when = if date != auto { date } else { _today() }
  let av = _avatar(avatar, author, avatar-colour)
  let n-c = if comments != auto { comments }
            else if thread.len() > 0 { thread.len() }
            else if published { 3 } else { none }
  let n-r = if reposts != auto { reposts } else if published { 5 } else { none }
  let n-l = if likes != auto { likes } else if published { 12 } else { none }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let names = {
      set text(dir: body-dir)
      text(weight: "bold", author)
      if handle != none {
        h(0.28em)
        _at(handle)
      }
      h(0.22em)
      _dot()
      h(0.16em)
      box(text(fill: luma(130), size: 0.82em, when))
    }
    let header = _header-row(av, names, ico-dots(), rtl)
    let main = pad(x: 0.30cm, bottom: 0.20cm, top: 0.04cm, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let heart-c = if liked { rgb("#F91880") } else { luma(70) }
    let footer = {
      pad(x: 0.42cm, y: 0.20cm, {
        set text(dir: ltr)
        grid(columns: (1fr, 1fr, 1fr, 1fr), align: center + horizon,
          [#ico-comment() #_count(n-c)],
          [#ico-repost() #_count(n-r)],
          [#ico-heart(paint: heart-c, filled: liked) #_count(n-l)],
          ico-share(),
        )
      })
      _thread-block("tweet", thread, body-dir)
    }
    _card(W, header, main, footer)
  })
}

#let twitterbox = tweetbox

// ---------------------------------------------------------------------------
//  facebookbox
// ---------------------------------------------------------------------------

/// A Facebook post. After ProfCollege `Facebook`.
#let facebookbox(
  body,
  author: [Name],
  date: auto,
  time: [15:14],
  avatar: auto,
  avatar-colour: rgb("#1877F2"),
  published: false,
  likes: auto,
  comments: auto,
  shares: auto,
  liked: false,
  thread: (),
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let L = _labels()
  let when = if date != auto { date } else { _today() }
  let av = _avatar(avatar, author, avatar-colour)
  let n-l = if likes != auto { likes } else if published { 48 } else { none }
  let n-c = if comments != auto { comments }
            else if thread.len() > 0 { thread.len() }
            else if published { 6 } else { none }
  let n-s = if shares != auto { shares } else if published { 2 } else { none }
  let show-stats = n-l != none or n-c != none or n-s != none

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let names = {
      set text(dir: body-dir)
      text(weight: "bold", author)
      linebreak()
      box(text(size: 0.72em, fill: luma(125), when))
      text(size: 0.72em, fill: luma(125))[, ]
      box(text(dir: ltr, size: 0.72em, fill: luma(125), time))
    }
    let header = _header-row(av, names, ico-dots(), rtl)
    let main = pad(x: 0.30cm, bottom: 0.18cm, top: 0.06cm, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let stats = if not show-stats { none } else {
      pad(x: 0.30cm, bottom: 0.12cm, {
        set text(dir: body-dir, size: 0.78em, fill: luma(90))
        grid(columns: (1fr, auto), align: (start + horizon, end + horizon),
          {
            _like-badge(size: 0.50cm)
            h(0.18em)
            if n-l != none { str(n-l) }
          },
          {
            if n-c != none [#n-c #L.comments]
            if n-c != none and n-s != none [ · ]
            if n-s != none [#n-s #L.shares]
          },
        )
      })
    }
    let like-c = if liked { rgb("#1877F2") } else { luma(70) }
    let actions = pad(x: 0.20cm, y: 0.16cm, {
      set text(dir: body-dir, size: 0.82em, weight: "bold", fill: luma(70))
      grid(columns: (1fr, 1fr, 1fr), align: center + horizon,
        text(fill: like-c)[#ico-thumb(paint: like-c) #h(0.18em) #L.like],
        [#ico-comment() #h(0.18em) #L.comment],
        [#ico-share() #h(0.18em) #L.share],
      )
    })
    let composer = if thread.len() == 0 { none } else {
      pad(x: 0.30cm, bottom: 0.18cm, top: 0.04cm, {
        set text(dir: body-dir)
        grid(columns: (auto, 1fr), column-gutter: 0.16cm, align: horizon,
          _avatar(auto, author, avatar-colour, size: 0.48cm),
          box(width: 100%, height: 0.56cm, radius: 0.28cm, fill: luma(244),
            align(horizon, pad(x: 0.22cm,
              text(size: 0.80em, fill: luma(140), L.write)))),
        )
      })
    }
    let footer = {
      if stats != none { stats }
      _rule()
      actions
      _thread-block("facebook", thread, body-dir)
      composer
    }
    _card(W, header, main, footer)
  })
}

// ---------------------------------------------------------------------------
//  instabox
// ---------------------------------------------------------------------------

/// An Instagram post. After ProfCollege `Instagram`.
/// `body` is the media (photo, drawing, …). `caption` is the text under it.
#let instabox(
  body,
  author: [name],
  caption: none,
  avatar: auto,
  avatar-colour: rgb("#DD2A7B"),
  likes: 18,
  liked: false,
  time: 34,
  thread: (),
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let L = _labels()
  let av0 = _avatar(avatar, author, avatar-colour, size: 0.70cm)
  let av = if av0 == none { none } else { _ig-ring(av0, size: 0.70cm) }
  let av-small = _avatar(avatar, author, avatar-colour, size: 0.48cm)

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let names = {
      set text(dir: body-dir)
      text(weight: "bold", size: 0.92em, author)
    }
    let header = {
      _header-row(av, names,
        ico-dots(vertical: true),
        rtl)
      _rule()
    }
    let media = block(width: 100%, {
      set text(dir: body-dir)
      set align(center)
      body
    })
    let footer = {
      _rule()
      pad(x: 0.28cm, top: 0.16cm, bottom: 0.06cm, {
        set text(dir: ltr)
        grid(columns: (1fr, auto), align: horizon,
          text(size: 1.05em)[
            #ico-heart(s: 13pt,
              paint: if liked { rgb("#E1306C") } else { luma(70) },
              filled: liked) #h(0.28em)
            #ico-comment(s: 13pt) #h(0.28em)
            #ico-plane(s: 13pt)
          ],
          ico-bookmark(s: 13pt),
        )
      })
      pad(x: 0.28cm, y: 0.06cm, {
        set text(dir: body-dir)
        text(weight: "bold", size: 0.86em)[#likes #L.likes]
      })
      if caption != none {
        pad(x: 0.28cm, bottom: 0.08cm, {
          set text(dir: body-dir, size: 0.88em)
          text(weight: "bold", author)
          h(0.25em)
          caption
        })
      }
      if thread.len() > 0 {
        _thread-block("instagram", thread, body-dir)
      }
      pad(x: 0.28cm, y: 0.10cm, {
        set text(dir: body-dir)
        grid(columns: (auto, 1fr, auto), column-gutter: 0.16cm, align: horizon,
          av-small,
          text(fill: luma(160), size: 0.82em, L.add),
          {
            ico-heart(s: 10pt, paint: rgb("#E1306C"), filled: true)
            h(0.14em)
            ico-spock(s: 10pt)
            h(0.14em)
            ico-plus(s: 10pt)
          },
        )
      })
      pad(x: 0.28cm, bottom: 0.16cm,
        text(size: 0.72em, fill: luma(130), (L.ago-s)(time)))
    }
    _card(W, header, media, footer)
  })
}

#let instagrambox = instabox

// ---------------------------------------------------------------------------
//  snapbox
// ---------------------------------------------------------------------------

/// A Snapchat card. After ProfCollege `Snapchat`.
#let snapbox(
  body,
  author: [Name],
  time: 4,
  avatar: auto,
  avatar-colour: rgb("#FFFC00"),
  action: auto,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let L = _labels()
  let act = if action != auto { action } else { L.send }
  // yellow avatar reads better with dark initials
  let av = if avatar == auto {
    box(width: 0.78cm, height: 0.78cm, fill: rgb("#FFFC00"), radius: 50%,
      stroke: 0.7pt + luma(40),
      align(center + horizon,
        text(fill: luma(20), weight: "bold", size: 0.34cm, dir: ltr,
          _initial(author))))
  } else {
    _avatar(avatar, author, rgb("#FFFC00"))
  }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let names = {
      set text(dir: body-dir)
      text(weight: "bold", author)
      linebreak()
      text(size: 0.72em, fill: luma(125), (L.ago-m)(time))
    }
    let trail = {
      ico-bell()
      h(0.28em)
      ico-dots(vertical: true)
    }
    let header = _header-row(av, names, trail, rtl)
    let main = pad(x: 0.30cm, y: 0.10cm, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let footer = pad(x: 0.28cm, top: 0.12cm, bottom: 0.22cm, {
      set text(dir: body-dir)
      grid(columns: (auto, 1fr, auto), column-gutter: 0.22cm, align: horizon,
        _circled("camera", size: 0.72cm, glyph: 0.44),
        box(width: 100%, height: 0.72cm, radius: 0.36cm,
          stroke: 1pt + luma(40),
          align(center + horizon, text(size: 0.86em, act))),
        _circled("location-arrow", size: 0.72cm, turn: -38deg, glyph: 0.42),
      )
    })
    _card(W, header, main, footer, frame: luma(200))
  })
}

#let snapchatbox = snapbox

// ---------------------------------------------------------------------------
//  mastodonbox
// ---------------------------------------------------------------------------

/// A Mastodon toot. After ProfCollege `Mastodon`.
#let mastodonbox(
  body,
  author: [Name],
  handle: none,
  date: [2 d],
  avatar: auto,
  avatar-colour: rgb("#6364FF"),
  published: false,
  replies: auto,
  liked: false,
  thread: (),
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let av = _avatar(avatar, author, avatar-colour)
  let thread = if type(replies) == array { replies } else { thread }
  let n-r = if type(replies) == int { replies }
            else if thread.len() > 0 { thread.len() }
            else if replies != auto { replies }
            else if published { 4 } else { none }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let names = {
      set text(dir: body-dir)
      text(weight: "bold", author)
      if handle != none {
        linebreak()
        _at(handle, size: 0.82em)
      }
    }
    let trail = {
      set text(size: 0.78em, fill: luma(110))
      ico-globe(s: 10pt)
      h(0.18em)
      date
    }
    let header = _header-row(av, names, trail, rtl)
    let main = pad(x: 0.30cm, bottom: 0.18cm, top: 0.08cm, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let footer = pad(x: 0.36cm, y: 0.18cm, {
      set text(dir: ltr)
      grid(columns: (1fr, 1fr, 1fr, 1fr, auto), align: center + horizon,
        [#ico-reply() #_count(n-r)],
        ico-repost(),
        ico-star(),
        ico-bookmark(),
        ico-dots(),
      )
    })
    _card(W, header, main, footer)
  })
}

#let tootbox = mastodonbox

// ---------------------------------------------------------------------------
//  dispatcher
// ---------------------------------------------------------------------------

/// One entry point. `kind` is tweet | facebook | instagram | snapchat | mastodon.
#let socialbox(body, kind: "tweet", ..args) = {
  let k = kind
  if k == "tweet" or k == "twitter" or k == "x" {
    tweetbox(body, ..args)
  } else if k == "facebook" or k == "fb" {
    facebookbox(body, ..args)
  } else if k == "instagram" or k == "ig" {
    instabox(body, ..args)
  } else if k == "snapchat" or k == "snap" {
    snapbox(body, ..args)
  } else if k == "mastodon" or k == "toot" {
    mastodonbox(body, ..args)
  } else {
    tweetbox(body, ..args)
  }
}
