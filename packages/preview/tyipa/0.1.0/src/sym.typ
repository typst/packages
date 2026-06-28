/// Module providing IPA symbols.

/***** Latin minuscles *****/

/// IPA symbol "a" and derived forms.
/// 
/// Variants:
///   - `a`: Two-storey a.
///   - `a.cursive`: Alias for `alpha`.
///   - `a.cursive.raised`: Alias for `alpha.raised`.
///   - `a.cursive.turned`: Alias for `alpha.turned`.
///   - `a.cursive.turned.raised`: Alias for `alpha.turned.raised`.
///   - `a.raised`: Raised/superscript two-storey a.
///   - `a.script`: Alias for `alpha`.
///   - `à.script.raised`: Alias for `alpha.raised`.
///   - `a.script.turned`: Alias for `alpha.turned`.
///   - `a.script.turned.raised`: Alias for `alpha.turned.raised`.
///   - `a.single-storey`: Alias for `alpha`.
///   - `a.single-storey.raised`: Alias for `alpha.raised`.
///   - `a.single-storey.turned`: Alias for `alpha.turned`.
///   - `a.single-storey.turned.raised`: Alias for `alpha.turned.raised`.
///   - `a.turned`: Turned two-storey a.
///   - `a.turned.raised`: Raised/superscript turned two-storey a.
#let a = symbol(
  "a",
  ("cursive", "ɑ"),                      // Alias for alpha
  ("cursive.raised", "ᵅ"),               // Alias for alpha.raised
  ("cursive.turned", "ɒ"),               // Alias for alpha.turned
  ("cursive.turned.raised", "ᶛ"),        // Alias for alpha.turned
  ("raised", "ᵃ"),
  ("script", "ɑ"),                       // Alias for alpha
  ("script.raised", "ᵅ"),                // Alias for alpha.raised
  ("script.turned", "ɒ"),                // Alias for alpha.turned
  ("script.turned.raised", "ᶛ"),         // Alias for alpha.turned
  ("single-storey", "ɑ"),                // Alias for alpha
  ("single-storey.raised", "ᵅ"),         // Alias for alpha.raised
  ("single-storey.turned", "ɒ"),         // Alias for alpha.turned
  ("single-storey.turned.raised", "ᶛ"),  // Alias for alpha.turned
  ("turned", "ɐ"),
  ("turned.raised", "ᵄ"),
)
/// IPA symbol "b" and derived forms.
/// 
/// Variants:
///   - `b`: b.
///   - `b.hook-top`: Hook-top b.
///   - `b.raised`: Raised/superscript b.
#let b = symbol(
  "b",
  ("hook-top", "ɓ"),
  ("raised", "ᵇ"),
)
/// IPA symbol "c" and derived forms.
/// 
/// Variants:
///   - `c`: c.
///   - `c.cedilla`: c-cedilla.
///   - `c.hook-top`: Hook-top c (obsolete).
///   - `c.raised`: Raised/superscript c.
///   - `c.stretched`: Stretched c (obsolete).
///   - `c.tail`: Alias for `c.tail.curly`.
///   - `c.tail.curly`: Curly-tail c.
///   - `c.tail.curly.raised`: Raised/superscript curly-tail c.
///   - `c.tail.raised`: Alias for `c.tail.curly.raised`.
#let c = symbol(
  "c",
  ("cedilla", "ç"),
  ("hook-top", "ƈ"),           // Obsolete
  ("raised", "ᶜ"),
  ("streched", "ʗ"),           // Obsolete
  ("tail", "ɕ"),               // Alias for c.tail.curly
  ("tail.curly", "ɕ"),
  ("tail.curly.raised", "ᶝ"),
  ("tail.raised", "ᶝ"),        // Alias for c.tail.curly
)
/// IPA symbol "d" and derived forms.
/// 
/// Variants:
///   - `d`: d.
///   - `d.raised`: Raised/superscript d.
///   - `d.retroflex`: Alias for `d.tail.right`
///   - `d.tail`: Alias for `d.tail.right`.
///   - `d.tail.right`: Right-tail d.
#let d = symbol(
  "d",
  ("hook-top", "ɗ"),
  ("raised", "ᵈ"),
  ("retroflex", "ɖ"),        // Alias for d.tail.right
  ("tail", "ɖ"),        // Alias for d.tail.right
  ("tail.right", "ɖ"),
)
/// IPA symbol "e" and derived forms.
/// 
/// Variants:
///   - `e`: e.
///   - `e.raised`: Raised/superscript e.
///   - `e.reversed`: Reversed e.
///   - `e.turned`: Alias for `schwa`.
///   - `e.turned.hook`: Alias for `schwa.hook`.
///   - `e.turned.raised`: Alias for `schwa.raised`.
#let e = symbol(
  "e",
  ("raised", "ᵉ"),
  ("reversed", "ɘ"),
  ("turned", "ə"),        // Alias for schwa
  ("turned.hook", "ɚ"),   // Alias for schwa.hook
  ("turned.raised", "ᵊ")  // Alias for schwa.raised
)
/// IPA symbol "f" and derived forms.
/// 
/// Variants:
///   - `f`: f.
///   - `f.raised`: Raised/superscript f.
#let f = symbol(
  "f",
  ("raised", "ᶠ"),
)
/// IPA symbol "g" and derived forms.
/// 
/// Variants:
///   - `g`: Single-storey g.
///   - `g.hook-top`: Hook-top single-storey g.
///   - `g.raised`: Raised/superscript single-storey g.
///   - `g.single-storey`: Alias for `g`.
///   - `g.single-storey.hook-top`: Alias for `g.hook-top`.
///   - `g.single-storey.raised`: Raised/superscript single-storey g.
#let g = symbol(
  "ɡ",
  ("hook-top", "ɠ"),
  ("raised", "ᶢ"),
  ("single-storey", "ɡ"),          // Alias for g
  ("single-storey.hook-top", "ɡ"), // Alias for g.hook-top
  ("single-storey.raised", "ᶢ"),
)
/// IPA symbol "h" and derived forms.
/// 
/// Variants:
///   - `h`: h.
///   - `h.barred`: Barred h.
///   - `h.barred.raised`: Raised/superscript barred h.
///   - `h.engma`: Hengma.
///   - `h.engma.hook-top`: Hook-top hengma.
///   - `h.engma.hook-top.raised`: Raised/superscript hook-top hengma.
///   - `h.engma.raised`: Raised/superscript hengma.
///   - `h.hook-top`: Hook-top h.
///   - `h.hook-top.raised`: Raised/superscript hook-top h.
///   - `h.raised`: Raised/superscript h.
///   - `h.turned`: Turned h.
///   - `h.turned.fish-hook`: Fish-hook turned h (non-standard; sinology).
///   - `h.turned.fish-hook.tail`: Alias for `h.turned.fish-hook.tail.right`.
///   - `h.turned.fish-hook.tail.right`: Right-tail fish-hook turned h (non-standard; sinology).
///   - `h.turned.raised`: Raised/superscript turned h.
#let h = symbol(
  "h",
  ("barred", "ħ"),
  ("barred.raised", "𐞕"),
  ("engma", "ꜧ"),
  ("engma.hook-top", "ɧ"),
  ("engma.hook-top.raised", "𐞗"),
  ("engma.raised", "ꭜ"),
  ("hook-top", "ɦ"),
  ("hook-top.raised", "ʱ"),
  ("raised", "ʰ"),
  ("turned", "ɥ"),
  ("turned.fish-hook", "ʮ"),            // Non-standard, used in sinology
  ("turned.fish-hook.tail", "ʯ"),       // Alias for h.turned.fish-hook.tail.right
  ("turned.fish-hook.tail.right", "ʯ"), // Non-standard, used in sinology
  ("turned.raised", "ᶣ"),
)
/// IPA symbol "i" and derived forms.
/// 
/// Variants:
///   - `i`: i.
///   - `i.barred`: Barred i.
///   - `i.barred.raised`: Raised/superscript barred i.
///   - `i.raised`: Raised/superscript i.
#let i = symbol(
  "i",
  ("barred", "ɨ"),
  ("barred.raised", "ᶤ"),
  ("raised", "ⁱ"),
)
/// IPA symbol "j" and derived forms.
/// 
/// Variants:
///   - `j`: j.
///   - `j.dotless`: Dotless j (non-standard; base for `j.dotless.barred`).
///   - `j.dotless.barred`: Barred dotless j.
///   - `j.dotless.barred.hook-top`: Hook-top barred dotless j.
///   - `j.dotless.barred.hook-top.raised`: Raised/superscript hook-top barred dotless j.
///   - `j.dotless.barred.raised`: Raised/superscript barred dotless j.
///   - `j.raised`: Raised/superscript j.
///   - `j.tail`: Alias for `j.tail.curly`.
///   - `j.tail.curly`: Curly-tail j.
///   - `j.tail.curly.raised`: Raised/superscript curly-tail j.
///   - `j.tail.raised`: Alias for `j.tail.curly.raised`.
#let j = symbol(
  "j",
  ("dotless", "ȷ"),                  // Only used as base for j.dotless.barred
  ("dotless.barred", "ɟ"),
  ("dotless.barred.hook-top", "ʄ"),
  ("dotless.barred.hook-top.raised", "𐞘"),
  ("dotless.barred.raised", "ᶡ"),
  ("raised", "ʲ"),
  ("tail", "ʝ"),                     // Alias for j.tail.curly
  ("tail.curly", "ʝ"),
  ("tail.curly.raised", "ᶨ"),
  ("tail.raised", "ᶨ"),                     // Alias for j.tail.curly.raised
)
/// IPA symbol "k" and derived forms.
/// 
/// Variants:
///   - `k`: k.
///   - `k.hook-top`: Hook-top k (obsolete).
///   - `k.raised`: Raised/superscript k.
///   - `k.turned`: Turned k (obsolete).
#let k = symbol(
  "k",
  ("hook-top", "ƙ"),  // Obsolete
  ("raised", "ᵏ"),
  ("turned", "ʞ"),    // Obsolete
)
/// IPA symbol "l" and derived forms.
/// 
/// Variants:
///   - `l`: l.
///   - `l.belted`: Belted l.
///   - `l.belted.raised`: Raised/superscript belted l.
///   - `l.raised`: Raised/superscript l.
///   - `l.retroflex`: Alias for `l.tail.right`.
///   - `l.retroflex.raised`: Alias for `l.tail.right.raised`.
///   - `l.tail`: Alias for `l.tail.right`.
///   - `l.tail.raised`: Alias for `l.tail.right.raised`.
///   - `l.tail.right`: Right-tail l.
///   - `l.tail.right.raised`: Raised right-tail l.
///   - `l.tilde`: l with middle-tilde.
///   - `l.tilde.raised`: Raised/superscript l with middle-tilde.
#let l = symbol(
  "l",
  ("belted", "ɬ"),
  ("belted.raised", "𐞛"),
  ("raised", "ˡ"),
  ("retroflex", "ɭ"),         // Alias for l.tail.right
  ("retroflex.raised", "ᶩ"),  // Alias for l.tail.right.raised
  ("tail", "ɭ"),              // Alias for l.tail.right
  ("tail.raised", "ᶩ"),  // Alias for l.tail.right.raised
  ("tail.right", "ɭ"),
  ("tail.right.raised", "ᶩ"),
  ("tilde", "ɫ"),
  ("tilde.raised", "ꭞ"),
)
/// IPA symbol "m" and derived forms.
/// 
/// Variants:
///   - `m`: m.
///   - `m.engma`: Mengma.
///   - `m.engma.raised`: Raised mengma.
///   - `m.raised`: Raised/superscript m.
///   - `m.turned`: Turned m.
///   - `m.turned.raised`: Raised/superscript turned m.
///   - `m.turned.right-leg`: Right-leg turned m.
///   - `m.turned.right-leg.raised`: Raised/superscript right-leg turned m.
#let m = symbol(
  "m",
  ("engma", "ɱ"),
  ("engma.raised", "ᶬ"),
  ("raised", "ᵐ"),
  ("turned", "ɯ"),
  ("turned.raised", "ᶬ"),
  ("turned.right-leg", "ɰ"),
  ("turned.right-leg.raised", "ᶭ"),
)
/// IPA symbol "n" and derived forms.
/// 
/// Variants:
///   - `n`: n.
///   - `engma`: Engma.
///   - `engma.raised`: Raised/superscript engma.
///   - `raised`: Raised n.
///   - `retroflex`: Alias for `n.tail.right`.
///   - `retroflex.raised`: Alias for `n.tail.right.raised`.
///   - `tail`: Alias for `n.tail.right`.
///   - `tail.raised`: Alias for `n.tail.right.raised`.
///   - `tail.right`: Right-tail n.
///   - `tail.right.raised`: Raised/superscript right-tail n.
///   - `tail.left`: Left-tail n.
///   - `tail.left.raised`: Raised/superscript left-tail n.
#let n = symbol(
  "n",
  ("engma", "ŋ"),
  ("engma.raised", "ᵑ"),
  ("raised", "ⁿ"),
  ("retroflex", "ɳ"),         // Alias for n.tail.right
  ("retroflex.raised", "ᶯ"),  // Alias for n.tail.right.raised
  ("tail", "ɳ"),              // Alias for n.tail.right
  ("tail.raised", "ᶯ"),       // Alias for n.tail.right.raised
  ("tail.right", "ɳ"),
  ("tail.right.raised", "ᶯ"),
  ("tail.left", "ɲ"),
  ("tail.left.raised", "ᶮ"),
)
/// IPA symbol "o" and derived forms.
/// 
/// Variants:
///   - `o`: o.
///   - `o.barred`: Barred o.
///   - `o.barred.raised`: Raised/superscript barred o.
///   - `o.open`: Open o.
///   - `o.open.raised`: Raised/superscript open o.
///   - `o.raised`: Raised o.
///   - `o.slashed`: Slashed o.
///   - `o.slashed.raised`: Raised/superscript slashed o.
#let o = symbol(
  "o",
  ("barred", "ɵ"),
  ("barred.raised", "ᶱ"),
  ("open", "ɔ"),
  ("open.raised", "ᵓ"),
  ("raised", "ᵒ"),
  ("slashed", "ø"),
  ("slashed.raised", "𐞢"),
)
/// IPA symbol "p" and derived forms.
/// 
/// Variants:
///   - `p`: p.
///   - `p.hook-top`: Hook-top p (obsolete).
///   - `p.raised`: Raised/superscript p.
#let p = symbol(
  "p",
  ("hook-top", "ƥ"),  // Obsolete
  ("raised", "ᵖ"),
)
/// IPA symbol "q" and derived forms.
/// 
/// Variants:
///   - `q`: q.
///   - `q.hook-top`: Hook-top q (obsolete).
///   - `q.hook-top.raised`: Raised/superscript hook-top q (obsolete).
///   - `q.raised`: Raised/superscript q.
#let q = symbol(
  "q",
  ("hook-top", "ʠ"),         // Obsolete
  ("hook-top.raised", "𐞍"),  // Obsolete
  ("raised", "𐞥"),
)
/// IPA symbol "r" and derived forms.
/// 
/// Variants:
///   - `r`: r.
///   - `r.fish-hook`: Fish-hook r.
///   - `r.fish-hook.raised`: Raised/superscript fish-hook r.
///   - `r.fish-hook.reversed`: Reversed fish-hook r (non-standard; sinology).
///   - `r.long-leg`: Long-leg r (obsolete).
///   - `r.long-leg.turned`: Turned long-leg r.
///   - `r.raised`: Raised/superscript r.
///   - `r.retroflex`: Alias for `r.tail.right`.
///   - `r.retroflex.raised`: Alias for `r.tail.right.raised`.
///   - `r.tail.raised`: Alias for `r.tail.right.raised`.
///   - `r.tail`: Alias for `r.tail.right`.
///   - `r.tail.righ`: Right-tail r.
///   - `r.tail.right.raised`: Raised/superscript right-tail r.
///   - `r.turned`: Turned r.
///   - `r.turned.raised`: Raised/superscript turned r.
///   - `r.turned.retroflex`: Alais for `r.turned.tail.right`.
///   - `r.turned.retroflex.raised`: Alais for `r.turned.tail.right`.
///   - `r.turned.tail`: Alais for `r.turned.tail.right`.
///   - `r.turned.tail.raised`: Alais for `r.turned.tail.right.raised`.
///   - `r.turned.tail.right`: Right-tail turned r.
///   - `r.turned.tail.right.raised`: Raised/superscript right-tail turned r.
#let r = symbol(
  "r",
  ("fish-hook", "ɾ"),
  ("fish-hook.raised", "𐞩"),
  ("fish-hook.reversed", "ɿ"),  // Non-standard, used in sinology
  ("long-leg", "ɼ"),            // Obsolete
  ("long-leg.turned", "ɺ"),
  ("raised", "ʳ"),
  ("retroflex", "ɽ"),           // Alias for r.tail.right
  ("retroflex.raised", "𐞩"),   // Alias for r.tail.right.raised
  ("tail.raised", "𐞩"),          // Alias for r.tail.right.raised
  ("tail", "ɽ"),                // Alias for r.tail.right
  ("tail.right", "ɽ"),
  ("tail.right.raised", "𐞩"),
  ("turned", "ɹ"),
  ("turned.raised", "ʴ"),
  ("turned.retroflex", "ɻ"),         // Alias for r.turned.tail.right
  ("turned.retroflex.raised", "ʴ"),  // Alias for r.turned.tail.right.raised
  ("turned.tail", "ɻ"),         // Alias for r.turned.tail.right
  ("turned.tail.raised", "ʴ"),         // Alias for r.turned.tail.right
  ("turned.tail.right", "ɻ"),
  ("turned.tail.right.raised", "ʵ"),
)
/// IPA symbol "s" and derived forms.
/// 
/// Variants:
///   - `s`: s.
///   - `s.raised`: Raised/superscript s.
///   - `s.retroflex`: Alias for `s.tail.right`.
///   - `s.retroflex.raised`: Alias for `s.tail.right.raised`.
///   - `s.tail`: Alias for `s.tail.right`.
///   - `s.tail.raised`: Alias for `s.tail.right.raised`.
///   - `s.tail.right`: Right-tail s.
///   - `s.tail.right.raised`: Raised/superscript right-tail s.
#let s = symbol(
  "s",
  ("raised", "ˢ"),
  ("retroflex", "ʂ"),         // Alias for s.tail.right
  ("retroflex.raised", "ᶳ"),  // Alias for s.tail.right.raised
  ("tail", "ʂ"),              // Alias for s.tail.right
  ("tail.raised", "ᶳ"),       // Alias for s.tail.right.raised
  ("tail.right", "ʂ"),
  ("tail.right.raised", "ᶳ"),
)
/// IPA symbol "t" and derived forms.
/// 
/// Variants:
///   - `t`: t.
///   - `t.hook-top`: Hook-top t (obsolete).
///   - `t.raised`: Raised/superscript t.
///   - `t.retroflex`: Alias for `t.tail.right`.
///   - `t.retroflex.raised`: Alias for `t.tail.right.raised`.
///   - `t.tail`: Alias for `t.tail.right`.
///   - `t.tail.raised`: Alias for `t.tail.right.raised`.
///   - `t.tail.right`: Right-tail t.
///   - `t.tail.right.raised`: Raised/superscript right-tail t.
///   - `t.turned`: Turned t (obsolete).
#let t = symbol(
  "t",
  ("hook-top", "ƭ"),        // Obsolete
  ("raised", "ᵗ"),
  ("retroflex", "ʈ"),       // Alias for t.tail.right
  ("retroflex.raised", "𐞯"), // Alias for t.tail.right.raised
  ("tail", "ʈ"),            // Alias for t.tail.right
  ("tail.raised", "𐞯"),     // Alias for t.tail.right.raised
  ("tail.right", "ʈ"),
  ("tail.right.raised", "𐞯"),
  ("turned", "ʇ"),          // Obsolete
)
/// IPA symbol "u" and derived forms.
/// 
/// Variants:
///   - `u`: u.
///   - `u.barred`: Barred u.
///   - `u.barred.raised`: Raised/superscript barred u.
///   - `u.horseshoe`: Alias for `upsilon`.
///   - `u.horseshoe.raised`: Alias for `upsilon.raised`.
///   - `u.raised`: Raised/superscript u.
#let u = symbol(
  "u",
  ("barred", "ʉ"),
  ("barred.raised", "ᶶ"),
  ("horseshoe", "ʊ"),         // Alias for upsilon
  ("horseshoe.raised", "ᶷ"),  // Alias for upsilon.raised
  ("raised", "ᵘ"),
)
/// IPA symbol "v" and derived forms.
/// 
/// Variants:
///   - `v`: v.
///   - `v.cursive`: Cursive v.
///   - `v.cursive.raised`: Raised/superscript cursive v.
///   - `v.hook-top`: Hook-top v.
///   - `v.hook-top.raised`: Raised/superscript hook-top v.
///   - `v.raised`: Raised/superscript v.
///   - `v.script`: Alias for `v.cursive`.
///   - `v.script.raised`: Alias for `v.cursive.raised`.
///   - `v.turned`: Turned v.
///   - `v.turned.raised`: Raised/superscript turned v.
#let v = symbol(
  "v",
  ("cursive", "ʋ"),
  ("cursive.raised", "ᶹ"),
  ("hook-top", "ⱱ"),
  ("hook-top.raised", "𐞰"),
  ("raised", "ᵛ"),
  ("script", "ʋ"),         // Alias for v.cursive
  ("script.raised", "ᶹ"),  // Alias for v.cursive.raised
  ("turned", "ʌ"),
  ("turned.raised", "ᶺ"),
)
/// IPA symbol "w" and derived forms.
/// 
/// Variants:
///   - `w`: w.
///   - `w.raised`: Raised/superscript w.
///   - `w.turned`: Turned w.
///   - `w.turned.raised`: Raised turned w.
#let w = symbol(
  "w",
  ("raised", "ʷ"),
  ("turned", "ʍ"),
  ("turned.raised", "ꭩ"),
)
/// IPA symbol "x" and derived forms.
/// 
/// Variants:
///   - `x`: x.
///   - `x.raised`: Raised/superscript x.
#let x = symbol(
  "x",
  ("raised", "ˣ"),
)
/// IPA symbol "y" and derived forms.
/// 
/// Variants:
///   - `y`: y.
///   - `y.raised`: Raised/superscript y.
///   - `y.turned`: Turned y.
///   - `y.turned.raised`: Raised/superscript turned y.
#let y = symbol(
  "y",
  ("raised", "ʸ"),
  ("turned", "ʎ"),
  ("turned.raised", "𐞠"),
)
/// IPA symbol "z" and derived forms.
/// 
/// Variants:
///   - `z`: z.
///   - `z.raised`: Raised/superscript z.
///   - `z.retroflex`: Alias for `z.tail.right`.
///   - `z.retroflex.raised`: Alias for `z.tail.right.raised`.
///   - `z.tail`: Alias for `z.tail.right`.
///   - `z.tail.raised`: Alias for `z.tail.right.raised`.
///   - `z.tail.right`: Right-tail z.
///   - `z.tail.right.raised`: Raised/superscript right-tail z.
///   - `z.tail.curly`: Curly-tail z.
///   - `z.tail.curly.raised`: Raised/superscript curly-tail z.
#let z = symbol(
  "z",
  ("raised", "ʸ"),
  ("retroflex", "ʐ"),         // Alias for z.tail.right
  ("retroflex.raised", "ᶼ"),  // Alias for z.tail.right.raised
  ("tail", "ʐ"),              // Alias for z.tail.right
  ("tail.raised", "ᶼ"),       // Alias for z.tail.right.raised
  ("tail.right", "ʐ"),
  ("tail.right.raised", "ᶼ"),
  ("tail.curly", "ʑ"),
  ("tail.curly.raised", "ᶽ"),
)

/***** Latin majuscles *****/

/// IPA symbol "B" and derived forms.
/// 
/// Variants:
///   - `B`: Small-capital B.
///   - `B.raised`: Raised/superscript small-capital B.
#let B = symbol(
  "ʙ",
  ("raised", "𐞄"),
)
/// IPA symbol "G" and derived forms.
/// 
/// Variants:
///   - `G`: Small-capital G.
///   - `G.hook-top`: Hook-top small-capital G.
///   - `G.hook-top.raised`: Raised/superscript hook-top small-capital G.
///   - `G.raised`: Raised/superscript small-capital G.
#let G = symbol(
  "ɢ",
  ("hook-top", "ʛ"),
  ("hook-top.raised", "𐞔"),
  ("raised", "𐞒"),
)
/// IPA symbol "H" and derived forms.
/// 
/// Variants:
///   - `H`: Small-capital H.
///   - `H.raised`: Raised/superscript small-capital H.
#let H = symbol(
  "ʜ",
  ("raised", "𐞖"),
)
/// IPA symbol "I" and derived forms.
/// 
/// Variants:
///   - `I`: Small-capital I.
///   - `I.raised`: Raised/superscript small-capital I.
#let I = symbol(
  "ɪ",
  ("raised", "ᶦ"),
)
/// IPA symbol "Y" and derived forms.
/// 
/// Variants:
///   - `Y`: Small-capital Y.
///   - `Y.raised`: Raised/superscript small-capital Y.
#let Y = symbol(
  "ʏ",
  ("raised", "𐞲"),
)
/// IPA symbol "L" and derived forms.
/// 
/// Variants:
///   - `L`: Small-capital L.
///   - `L.raised`: Raised/superscript small-capital L.
#let L = symbol(
  "ʟ",
  ("raised", "ᶫ"),
)
/// IPA symbol "N" and derived forms.
/// 
/// Variants:
///   - `N`: Small-capital N.
///   - `N.raised`: Raised/superscript small-capital N.
#let N = symbol(
  "ɴ",
  ("raised", "ᶰ"),
)
/// IPA symbol "R" and derived forms.
/// 
/// Variants:
///   - `R`: Small-capital R.
///   - `R.inverted`: Inverted small-capital R.
///   - `R.inverted.raised`: Raised/superscript inverted small-capital R.
///   - `R.raised`: Raised/superscript small-capital R.
#let R = symbol(
  "ʀ",
  ("inverted", "ʁ"),
  ("inverted.raised", "ʶ"),
  ("raised", "𐞪"),
)

/***** Greek *****/

/// IPA symbol "alpha" and derived forms.
/// 
/// Variants:
///   - `alpha`: alpha.
///   - `alpha.raised`: Raised/superscript alpha.
///   - `alpha.turned`: Turned alpha.
///   - `alpha.turned.raised`: Raiser/superscript turned alpha.
#let alpha = symbol(
  "ɑ",
  ("raised", "ᵅ"),
  ("turned", "ɒ"),
  ("turned.raised", "ᶛ"),
)
/// IPA symbol "beta" and derived forms.
/// 
/// Variants:
///   - `beta`: beta.
///   - `beta.raised`: Raised/superscript beta.
#let beta = symbol(
  "β",
  ("raised", "ᵝ"),
)
/// IPA symbol "gamma" and derived forms.
/// 
/// Variants:
///   - `gamma`: gamma.
///   - `gamma.raised`: Raised/superscript gamma.
#let gamma = symbol(
  "ɣ",
  ("raised", "ˠ"),
)
/// IPA symbol "epsilon" and derived forms.
/// 
/// Variants:
///   - `epsilon`: epsilon.
///   - `epsilon.raised`: Raised/superscript epsilon.
///   - `epsilon.reversed`: Reversed epsilon.
///   - `epsilon.reversed.closed`: Closed reversed epsilon.
///   - `epsilon.reversed.closed.raised`: Raised/superscript closed reversed epsilon.
///   - `epsilon.reversed.hook`: Reversed epsilon with hook.
///   - `epsilon.reversed.raised`: Raised/superscript reversed epsilon.
#let epsilon = symbol(
  "ɛ",
  ("raised", "ᵋ"),
  ("reversed", "ɜ"),
  ("reversed.closed", "ɞ"),
  ("reversed.closed.raised", "𐞏"),
  ("reversed.hook", "ɝ"),
  ("reversed.raised", "ᶟ"),
)
/// IPA symbol "theta" and derived forms.
/// 
/// Variants:
///   - `theta`: theta.
///   - `theta.raised`: Raised theta.
#let theta = symbol(
  "θ",
  ("raised", "ᶿ"),
)
/// IPA symbol "iota" and derived forms.
/// 
/// Variants:
///   - `iota`: iota (obsolete).
#let iota = symbol(
  "ɩ",                 // Obsolete
)
/// IPA symbol "upsilon" and derived forms.
/// 
/// Variants:
///   - `upsilon`: upsilon.
///   - `upsilon.raised`: Raised upsilon.
#let upsilon = symbol(
  "ʊ",
  ("raised", "ᶷ"),
)
/// IPA symbol "phi" and derived forms.
/// 
/// Variants:
///   - `phi`: theta.
///   - `phi.raised`: Raised phi.
#let phi = symbol(
  "ɸ",
  ("raised", "ᶲ"),
)
/// IPA symbol "chi" and derived forms.
/// 
/// Variants:
///   - `chi`: chi.
///   - `chi.raised`: Raised chi.
#let chi = symbol(
  "χ",
  ("raised", "ᵡ"),
)
/// IPA symbol "omega" and derived forms.
/// 
/// Variants:
///   - `omega`: omega (non-standard; base for `omega.closed`).
///   - `omega.closed`: Closed omega (obsolete).
///   - `omega.closed.raised`: Raised closed omega (obsolete).
#let omega = symbol(
  "ω",                     // Only used as base for omega.closed
  ("closed", "ɷ"),         // Obsolete
  ("closed.raised", "𐞤"),  // Obsolete
)

/***** Ligatures, digraphs and other bases *****/

/// IPA symbol "ae" and derived forms.
/// 
/// Variants:
///   - `ae`: ae ligature.
///   - `ae.raised`: Raised/superscript ae ligature.
#let ae = symbol(
  "æ",
  ("raised", "𐞃"),
)
/// IPA symbol "bulls-eye" and derived forms.
/// 
/// Variants:
///   - `bulls-eye`: Bull's eye.
///   - `bulls-eye.raised`: Raised/superscript bull's eye.
#let bulls-eye = symbol(
  "ʘ",
  ("raised", "𐞵"),
)
/// Alias for `n.engma`
#let engma = symbol(
  "ŋ",
  ("raised", "ᵑ"),
)
/// IPA symbol "esh" and derived forms.
/// 
/// Variants:
///   - `esh`: esh.
///   - `esh.raised`: Raised/superscript esh.
///   - `esh.reversed`: Reversed esh.
///   - `esh.tail.curly`: Curly-tail esh (obsolete).
#let esh = symbol(
  "ʃ",
  ("raised", "ᶴ"),
  ("reversed", "ʅ"),    // Unofficial, used in sinology
  ("tail.curly", "ʆ"),  // Obsolete
)
/// IPA symbol "esh" and derived forms.
/// 
/// Variants:
///   - `eth`: eth.
///   - `eth.raised`: Raised/superscript eth.
#let eth = symbol(
  "ð",
  ("raised", "ᶞ"),
)
#let ezh = symbol(
  "ʒ",
  ("raised", "ᶾ"),
  ("tail.curly", "ʓ"),  // Obsolete
)
/// Alias for `eth`
#let edh = symbol(
  "ð",
  ("raised", "ᶞ"),
)
/// IPA symbol "exclamation-mark" and derived forms.
/// 
/// Variants:
///   - `exclamation-mark`: Exclamation mark.
///   - `exclamation-mark.raised`: Raised/superscript exclamation mark.
#let exclamation-mark = symbol(
  "ǃ",
  ("raised", "ꜝ"),
)
/// IPA symbol "glottal-stop" and derived forms.
/// 
/// Variants:
///   - `glottal-stop`: Glottal stop.
///   - `glottal-stop.raised`: Raised/superscript glottal stop.
///   - `glottal-stop.reversed`: Reversed glottal stop.
///   - `glottal-stop.reversed.barred`: Barred reversed glottal stop.
///   - `glottal-stop.reversed.barred.raised`: Raised/superscript barred reversed glottal stop.
#let glottal-stop = symbol(
  "ʔ",
  ("raised", "ˀ"),
  ("reversed", "ʕ"),
  ("reversed.barred", "ʢ"),
  ("reversed.barred.raised", "𐞴"),
  ("reversed.raised", "ˤ"),
  ("barred", "ʡ"),
  ("barred.raised", "𐞳"),
  ("inverted", "ʖ"),   // Obsolete
)
// Alias for `h.engma`
#let hengma = symbol(
  "ꜧ",
  ("hook-top", "ɧ"),
  ("hook-top.raised", "𐞗"),
  ("raised", "ꭜ"),
)
/// IPA symbol "lezh" and derived forms.
/// 
/// Variants:
///   - `lezh`: lezh ligature.
///   - `lezh.raised`: Raised/superscript lezh ligature.
#let lezh = symbol(
  "ɮ",
  ("raised", "𐞞"),
)
// Alias for `m.engma`
#let mengma = symbol(
  "ɱ",
  ("raised", "ᶬ"),
)
/// IPA symbol "oe" and derived forms.
/// 
/// Variants:
///   - `oe`: oe ligature.
///   - `oe.raised`: Raised/superscript oe ligature.
#let oe = symbol(
  "œ",
  ("raised", "ꟹ"),
)
/// IPA symbol "OE" and derived forms.
/// 
/// Variants:
///   - `oe`: OE ligature.
///   - `oe.raised`: Raised/superscript OE ligature.
#let OE = symbol(
  "ɶ",
  ("raised", "𐞣"),
)
/// IPA symbol "pipe" and derived forms.
/// 
/// Variants:
///   - `pipe`: Pipe.
///   - `pipe.double`: Double pipe.
///   - `pipe.double.raised`: Raised/superscript double pipe.
///   - `pipe.double-barred`: Double-barred pipe.
///   - `pipe.double-barred.raised`: Raised/superscript double-barred pipe.
///   - `pipe.raised`: Raised/superscript pipe.
#let pipe = symbol(
  "ǀ",
  ("double", "ǁ"),
  ("double.raised", "𐞷"),
  ("double-barred", "ǂ"),
  ("double-barred.raised", "𐞸"),
  ("raised", "𐞶"),
)
/// IPA symbol "rams-horn" and derived forms.
/// 
/// Variants:
///   - `rams-horn`: Ram's horn.
///   - `rams-horn.raised`: Raised/superscript ram's horn.
#let rams-horn = symbol(
  "ɤ",
  ("raised", "𐞑"),
)
/// IPA symbol "schwa" and derived forms.
/// 
/// Variants:
///   - `schwa`: Schwa.
///   - `schwa.hook`: Schwa with hook.
///   - `schwa.raised`: Raised/superscript schwa.
#let schwa = symbol(
  "ə",
  ("hook", "ɚ"),
  ("raised", "ᵊ")
)
/// Alias for `v.turned`
#let wedge = symbol(
  "ʌ",
  ("raised", "ᶺ"),
)
/// Placeholder symbol.
/// 
/// Placeholder which can be used as a base to attach diacritics for
/// illustration.
/// 
/// Variants:
///   - `placeholder`: Alias for `placeholder.circle`.
///   - `placeholder.circle`: Dotted circle placeholder.
///   - `placeholder.blank`: Non-breaking space.
#let placeholder = symbol(
  "◌",
  ("circle", "◌"),
  ("blank", "\u{00a0}"),
)

/***** Suprasegmentals *****/

/// IPA symbol "rundertie" and derived forms.
/// 
/// Variants:
///   - `undertie`: Undertie.
#let undertie = symbol(
  "‿"
)
/// IPA symbol "stress-mark" and derived forms.
/// 
/// Variants:
///   - `stress-mark`: Alias for `stress-mark.primary`.
///   - `stress-mark.primary`: Primary stress mark.
///   - `stress-mark.secondary`: Secondary stress mark.
#let stress-mark = symbol(
  "ˈ",
  ("primary", "ˈ"),
  ("secondary", "ˌ"),
)
/// IPA symbol "syllable-break" and derived forms.
/// 
/// Variants:
///   - `syllable-break`: Syllable break.
#let syllable-break = symbol(
  "."
)
/// IPA symbol "length-mark" and derived forms.
/// 
/// Variants:
///   - `length-mark`: Alias for `length-mark.long`.
///   - `length-mark.long`: Long length mark.
///   - `length-mark.half-long`: Half-long length mark.
#let length-mark = symbol(
  "ː",
  ("long", "ː"),
  ("half-long", "ˑ"),
)
/// IPA symbol "group-mark" and derived forms.
/// 
/// Variants:
///   - `group-mark`: Alias for `group-mark.major`.
///   - `group-mark.major`: Major group mark.
///   - `group-mark.minor`: Minor group mark.
#let group-mark = symbol(
  "‖",
  ("major", "‖"),
  ("minor", "|"),
)
/// IPA symbol "upstep" and derived forms.
/// 
/// Variants:
///   - `upstep`: Upstep.
#let upstep = symbol(
  "ꜛ",
)
/// IPA symbol "downstep" and derived forms.
/// 
/// Variants:
///   - `downstep`: Downstep.
#let downstep = symbol(
  "ꜜ"
)
/// IPA symbol "global-rise" and derived forms.
/// 
/// Variants:
///   - `global-rise`: Global rise.
#let global-rise = symbol(
  "↗",
)
/// IPA symbol "global-fall" and derived forms.
/// 
/// Variants:
///   - `global-fall`: Global fall.
#let global-fall = symbol(
  "↘",
)
/// IPA symbol "tone-bar" and derived forms.
/// 
/// Variants:
///   - `tone-bar.extra-high`: Extra-high tone-bar.
///   - `tone-bar.high`: High tone-bar.
///   - `tone-bar.mid`: Mid tone-bar.
///   - `tone-bar.low`: Low tone-bar.
///   - `tone-bar.extra-low`: Extra-low tone-bar.
#let tone-bar = symbol(
  ("extra-high", "\u{02e5}"),
  ("high", "\u{02e6}"),
  ("mid", "\u{02e7}"),
  ("low", "\u{02e8}"),
  ("extra-low", "\u{02e9}"),
)
/// Brackets used for IPA transcriptions.
/// 
/// Variants:
///   - `angle.left`: 〈
///   - `angle.left.double`: ⟪
///   - `angle.right`: 〉
///   - `angle.right.double`: ⟫
///   - `paren.left`: (
///   - `paren.left.double`: ⦅
///   - `paren.left.raised`: ⁽
///   - `paren.right`: )
///   - `paren.right.double`: ⦆
///   - `paren.right.raised`: 
///   - `square.left`: [
///   - `square.left.double`: ⟦
///   - `square.right`: ]
///   - `square.right.double`: ⟧
#let bracket = symbol(
  ("angle.left", "⟨"),
  ("angle.double.left", "⟪"),
  ("angle.right", "〉"),
  ("angle.double.right", "⟫"),
  ("paren.left", "("),
  ("paren.double.left", "⦅"),
  ("paren.left.raised", "⁽"),
  ("paren.right", ")"),
  ("paren.double.right", "⦆"),
  ("paren.right.raised", "⁾"),
  ("slash", "/"),
  ("slash.double", "⫽"),
  ("square.left", "["),
  ("square.double.left", "⟦"),
  ("square.right", "]"),
  ("square.double.right", "⟧"),
)

/***** Deprecated *****/

/// IPA symbol "dezh" and derived forms.
/// 
/// Deprecated: Should use `diac.tie(sym.d + sym.ezh)` instead.
/// 
/// Variants:
///   - `dezh`: dezh ligature.
///   - `dezh.raised`: Raised/superscript dezh ligature.
#let dezh = symbol(
  "ʤ",
  ("raised", "𐞊"),
)
/// IPA symbol "dz" and derived forms.
/// 
/// Deprecated: Should use `diac.tie(sym.d + sym.z)` instead.
/// 
/// Variants:
///   - `dz`: dz ligature.
///   - `dz.raised`: Raised/superscript dz ligature.
#let dz = symbol(
  "ʣ",
  ("raised", "𐞇"),
  ("curly", "ʥ"),
  ("curly.raised", "𐞉"),
)
/// IPA symbol "tesh" and derived forms.
/// 
/// Deprecated: Should use `diac.tie(sym.t + sym.esh)` instead.
/// 
/// Variants:
///   - `tesh`: tesh ligature.
///   - `tesh.raised`: Raised/superscript tesh ligature.
#let tesh = symbol(
  "ʧ",
  ("raised", "𐞮"),
)
/// IPA symbol "ts" and derived forms.
/// 
/// Deprecated: Should use `diac.tie(sym.t + sym.s)` instead.
/// 
/// Variants:
///   - `ts`: ts ligature.
///   - `ts.raised`: Raised/superscript ts ligature.
#let ts = symbol(
  "ʦ",
  ("raised", "𐞬"),
)
/// IPA symbol "tc" and derived forms.
/// 
/// Deprecated: Should use `diac.tie(sym.t + sym.c.curly)` instead.
/// 
/// Variants:
///   - `tc.tail.curly`: Curly-tail tc ligature.
///   - `tc.tail.curly.raised`: Raised/superscript curly-tail tc ligature.
#let tc = symbol(
  ("tail", "ʨ"),              // Alias for `tc.tail.curly`
  ("tail.raised", "𐞫"),       // Alias for `tc.tail.curly.raised`
  ("tail.curly", "ʨ"),
  ("tail.curly.raised", "𐞫"),
)
