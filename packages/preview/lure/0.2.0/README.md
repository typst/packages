# typst-lure

Parse and normalize URLs, based on the [WHATWG URL Standard](https://url.spec.whatwg.org/), powered by [rust-url](https://crates.io/crates/url) and [WebAssembly](https://typst.app/docs/reference/foundations/plugin/).

For convenience, this package also provides several functions to create URLs from existing ones.

## Example usages

### Normalize URLs

```typst
#import "@preview/lure:0.2.0": normalize
#normalize("https://ja.wikipedia.org/wiki/アルベルト・アインシュタイン")
// ⇒ https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AB%E3%83%99%E3%83%AB%E3%83%88%E3%83%BB%E3%82%A2%E3%82%A4%E3%83%B3%E3%82%B7%E3%83%A5%E3%82%BF%E3%82%A4%E3%83%B3
```

As the following example, you can create a wrapper of [`link`](https://typst.app/docs/reference/model/link/) to safely use [URLs containing non-ASCII characters](https://typst-doc-cn.github.io/clreq/#links-containing-non-ascii-characters-are-wrong-when-viewing-pdf-in-safari-ascii-safari-pdf), 
before the official Typst compiler fixes [#6128](https://github.com/typst/typst/issues/6128).

```typst
#import "@preview/lure:0.2.0": normalize
#let link(dest, ..body) = {
  assert.eq(body.named(), (:))
  assert(body.pos().len() <= 1)

  std.link(
    normalize(dest),
    body.pos().at(0, default: dest.replace(regex("^(mailto|tel)://"), "")),
  )
}

#link("https://law.go.kr/법령/보건의료기본법/제3조")[UTF-8 percent-encode automatically]
#link("https://w3c.github.io/clreq/README.zh-Hans.html#%E8%AE%A8%E8%AE%BA")[Keep it as it is if already encoded]
```

Unlike [percencode](https://typst.app/universe/package/percencode), this package will not re-encode.

### Convert between absolute and relative URLs

```typst
#import "@preview/lure:0.2.0": join, make-relative

#let base = "https://owner.github.io/repo/"

#let absolute = join(base, "/repo/image.png")
#assert.eq(absolute, "https://owner.github.io/repo/image.png")

#let relative = make-relative(base, absolute)
#assert.eq(relative, "image.png")
```

### Parse URLs

```typst
#import "@preview/lure:0.2.0": parse, parse-supplementary

// Parse into components
#assert.eq(
  parse("ssh://git@ssh.github.com:443/YDX-2147483647/typst-lure.git"),
  (
    scheme: "ssh",
    cannot-be-a-base: false,
    username: "git",
    password: none,
    host: "ssh.github.com",
    port: 443,
    path: "/YDX-2147483647/typst-lure.git",
    query: none,
    fragment: none,
  ),
)

// Get supplementary information
#assert.eq(
  parse-supplementary("https://typst.app/universe/search/?q=url"),
  (
    origin: ("https", "typst.app", 443),
    is-special: true,
    authority: "typst.app",
    domain: "typst.app",
    port-or-known-default: 443,
    path-segments: ("universe", "search", ""),
    query-pairs: (("q", "url"),),
  ),
)
```

URLs can be tricky. Please refer to the documentation (hover docs for typst functions, or [rust docs](https://docs.rs/url/latest/url/struct.Url.html)) for detailed explanation of each field.

### Change query pairs

```typst
#import "@preview/lure:0.2.0": parse-supplementary, with-query-pairs

// Add search parameters to a URL
#assert.eq(
  with-query-pairs("https://typst.app/universe/search/", (q: "url", openSource: "true")),
  "https://typst.app/universe/search/?q=url&openSource=true",
)

// Modify existing query pairs
#{
  let url = "https://www.bilibili.com/video/BV1ys411472E/?vd_source=33a2db04ee4f097f3613aeb5caacc90b&spm_id_from=333.788.videopod.episodes&p=15"

  let query = parse-supplementary(url).query-pairs
  // Set time to 0:42
  query += (t: str(42)).pairs()
  // Remove trackings
  query = query.filter(((key, _value)) => not ("vd_source", "spm_id_from").contains(key))

  assert.eq(
    with-query-pairs(url, query),
    "https://www.bilibili.com/video/BV1ys411472E/?p=15&t=42",
  )
}
```

## Changelog

### 0.2.0

Add `with-query-pairs(url, query)` function.

Bump rust-url to 2.5.8.

### 0.1.0

Initial release with rust-url 2.5.4.
