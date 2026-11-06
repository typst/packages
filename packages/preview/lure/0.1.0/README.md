# typst-lure

Parse and normalize URLs, based on the [WHATWG URL Standard](https://url.spec.whatwg.org/), powered by [rust-url](https://crates.io/crates/url) and [WebAssembly](https://typst.app/docs/reference/foundations/plugin/).

## Example usages

### Normalize URLs

```typst
#import "@preview/lure:0.1.0": normalize
#normalize("https://ja.wikipedia.org/wiki/アルベルト・アインシュタイン")
// ⇒ https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AB%E3%83%99%E3%83%AB%E3%83%88%E3%83%BB%E3%82%A2%E3%82%A4%E3%83%B3%E3%82%B7%E3%83%A5%E3%82%BF%E3%82%A4%E3%83%B3
```

As the following example, you can create a wrapper of [`link`](https://typst.app/docs/reference/model/link/) to safely use [URLs containing non-ASCII characters](https://typst-doc-cn.github.io/clreq/#links-containing-non-ascii-characters-are-wrong-when-viewing-pdf-in-safari-ascii-safari-pdf), 
before the official Typst compiler fixes [#6128](https://github.com/typst/typst/issues/6128).

```typst
#import "@preview/lure:0.1.0": normalize
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
#import "@preview/lure:0.1.0": join, make-relative

#let base = "https://owner.github.io/repo/"

#let absolute = join(base, "/repo/image.png")
#assert.eq(absolute, "https://owner.github.io/repo/image.png")

#let relative = make-relative(base, absolute)
#assert.eq(relative, "image.png")
```

### Parse URLs

```typst
#import "@preview/lure:0.1.0": parse, parse-supplementary

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

URLs can be tricky. Please refer to the documentation for detailed explanation of each field.
