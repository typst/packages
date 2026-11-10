// Vertical-spacing helpers: the TeX→Typst baseline-grid conversion used
// everywhere in this template. See DESIGN.md "Heading / block vertical spacing".
//
// TeX sets lines on a rigid \baselineskip independent of font metrics; we pin
// Typst's line box to the font size (`set text(top-edge: 1em, bottom-edge: 0pt)`
// in lib.typ) to get the same. Two consequences, both captured here:
//
//   * Intra-block line gap (Typst `leading`) must be `baselineskip - size`, so
//     consecutive baselines are exactly `baselineskip` apart.  -> comp()
//
//   * A TeX vertical skip `s` between baselines yields a pitch of
//     `baselineskip + s` (the following line's interline glue is added on top of
//     the explicit skip). A Typst gap `g` yields a pitch of `g + size`. Matching
//     them gives `g = s + (baselineskip - size)` = `s + comp`.  -> tex-skip()
//
// `baselineskip`/`size` are always the FOLLOWING line's, selected by `sz` from
// the format dict's size steps (default "normalsize", i.e. body text). For body
// text `bls.normalsize`/`size.normalsize` equal `cfg.baselineskip`/`font-size`.

// Line-box compensation = intra-block leading at font-size step `sz`.
#let comp(cfg, sz: "normalsize") = cfg.bls.at(sz) - cfg.size.at(sz)

// Convert a TeX vertical skip into a Typst block/`v()` gap before a block whose
// first line is at font-size step `sz`.
#let tex-skip(cfg, skip, sz: "normalsize") = skip + comp(cfg, sz: sz)
