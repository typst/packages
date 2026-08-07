# Redistributing this work

Four different licenses are tangled up in this folder. **One of them
(the font) will block most redistribution** — read §1 first.

| Component | Origin | License |
|---|---|---|
| `fonts/xkcd-script.ttf`, `fonts/xkcd.otf` | ipython/xkcd-font | **CC BY-NC 3.0** ⚠️ |
| `xkcd.typ`, figure layout/geometry | derived from the TeX.SE answer | **CC BY-SA 4.0** (share-alike) |
| The `penciline` port (earlier work) | derived from a different TeX.SE answer | **CC BY-SA 3.0** |
| `plugin/src/lib.rs`, `xkcd-lib.typ` plumbing | written here | your choice (see §3) |
| CeTZ 0.5.2 | dependency, not bundled | LGPL-3.0-or-later |
| `wasm-minimal-protocol` 0.2.0 | compiled into `sketch.wasm` | Unlicense (public domain) |

---

## 1. The font is the blocker — deal with it first

`fonts/` is **CC BY-NC 3.0: NonCommercial**. GitHub's own classifier reports
`NOASSERTION` for the repo, meaning the licensing is not cleanly machine-readable.

That means **you may not redistribute this folder as-is** in:

- anything commercial, or on a monetised site/product,
- a Typst Universe package (bundling NC-licensed files is not appropriate for
  a general-purpose package),
- anything you want to call open source — **CC BY-NC is not an OSI/DFSG-free
  license**, and it is one-way incompatible with the CC BY-SA 4.0 on the
  figures.

Note also the original document asks for **Humor Sans**, which is not bundled
here at all and has its own separate terms.

### Recommended fix: delete the fonts, point at an OFL one

```bash
rm -rf fonts/
```

Then in `xkcd.typ` swap the font stack for an SIL Open Font License face
(OFL permits commercial use and redistribution, with the reserved-name rules):

```typst
#set text(font: ("Comic Neue", "Excalifont", "DejaVu Sans"), size: 11pt)
```

Verified OFL-1.1 options: **Comic Neue** (`crozynski/comicneue`) and
**Excalifont / Virgil** (`excalidraw/virgil`).

If you keep the xkcd fonts anyway — legitimate for a personal, non-commercial
project — you must retain `LICENSE` from the font repo, credit Randall Munroe,
and state the NonCommercial restriction.

## 2. Attribution you must keep (CC BY-SA)

Both Stack Exchange answers are copyleft, so attribution is **required, not
polite**. The source headers in `xkcd.typ`, `xkcd-lib.typ` and `penciline.typ`
already carry author, URL, retrieval date and license — **do not strip them.**

Share-alike means: if you distribute a modified version of the figures, that
derivative must also be **CC BY-SA 4.0**. It cannot be relicensed MIT.

The practical way to keep this sane is the split in §3.

## 3. Split the licensing (recommended)

The Rust decoration engine is *not* a derivative of the TeX code in the
copyright sense — it is an independent implementation of an algorithm, and
algorithms as such are not copyrightable. So license the two halves separately:

- `plugin/src/lib.rs` + `xkcd-lib.typ` → **MIT or Apache-2.0**, your copyright.
- `xkcd.typ` (the actual figures) → **CC BY-SA 4.0**, crediting Frunobulax.

Add a root `LICENSE` for your code and keep this file to explain the rest.
This is what lets the engine be reused freely while honouring share-alike on
the artwork.

## 4. CeTZ / LGPL — you are fine

CeTZ is **LGPL-3.0-or-later** but is *not* bundled: Typst fetches it from
the package registry at compile time. You are a user of it, not a
redistributor, so the LGPL relinking obligations are not triggered. If you
ever do vendor CeTZ into your repo, LGPL-3.0 terms then apply to that copy.

## 5. The committed `sketch.wasm`

`sketch.wasm` is a **compiled binary** containing code expanded from
`wasm-minimal-protocol` (Unlicense/public domain — no attribution required,
no restrictions). Shipping the binary is convenient for users without Rust,
but ship `plugin/src/lib.rs` alongside it so the binary is auditable and
reproducible. Anyone can verify with `./build.sh`.

## 6. Checklist

```
[ ] Removed fonts/ or confirmed your use is strictly non-commercial
[ ] Font stack points at an OFL face (Comic Neue / Excalifont)
[ ] Source-attribution headers left intact in the .typ files
[ ] Figures marked CC BY-SA 4.0; engine marked MIT/Apache-2.0
[ ] LICENSE file added for your own code
[ ] plugin/src/lib.rs shipped next to sketch.wasm
[ ] ./build.sh works from a clean checkout
```

*This is a practical summary, not legal advice. For commercial distribution,
have counsel confirm the CC BY-SA obligations.*
