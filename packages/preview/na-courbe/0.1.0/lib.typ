// na-courbe v0.1.0 : حزمة متكاملة لرسم المنحنيات فوق CeTZ
#import "@preview/cetz:0.3.2": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot
// ── أدوات داخلية ────────────────────────────────────────────
// أنواع الخط: continu | tirets | pointille | mixte  (و points | lie للنقاط)
#let _dash(tr) = if tr == "tirets" { "dashed" } else if tr == "pointille" { "dotted" } else if tr == "mixte" { "dash-dotted" } else { none }

// طول بالسنتيمتر (يقبل عددًا أو طولًا مثل 3mm)
#let _cm(v) = if type(v) == length { v / 1cm } else { v }

// نوع الشبكة: true/"principale" | "secondaire" | "toutes" | "millimetre" | false/"aucune"
#let _grille(g) = {
  if g == "millimetre" or g == "milli" or g == "mm" or g == "papier" { "milli" } else if g == true or g == "major" or g == "principale" { true } else if g == false or g == none or g == "aucune" { false } else if g == "minor" or g == "secondaire" { "minor" } else if g == "both" or g == "toutes" { "both" } else { true }
}

// ── الترقيم المثلثي: القيمة v على شكل مضاعف للعدد π بمقام d ──
#let _pi-label(v, d) = {
  let dd = int(d)
  let k = int(calc.round(v / calc.pi * dd))
  if k == 0 { return $0$ }
  let g = calc.gcd(calc.abs(k), dd)
  let n = calc.quo(k, g)
  let m = calc.quo(dd, g)
  let an = calc.abs(n)
  let t = if an == 1 { "pi" } else { str(an) + " pi" }
  let s = if m == 1 { t } else { "display(frac(" + t + ", " + str(m) + "))" }
  let sg = if n < 0 { "-" } else { "" }
  eval("$" + sg + s + "$")
}

// دالة تنسيق أرقام التدريج (auto = الافتراضي)
#let _fmt(num, d, sz) = {
  if num == "pi" {
    v => {
      let c = _pi-label(v, d)
      if sz == auto { c } else { text(size: sz, c) }
    }
  } else if sz != auto {
    v => text(size: sz)[#calc.round(v, digits: 3)]
  } else { auto }
}

// ── حساب المساحة عدديًا (سيمبسون) ────────────────────────────
#let integrale(f, a, b, g: none, n: 2000, absolu: true) = {
  let gg = if g == none { t => 0 } else { g }
  let val(t) = {
    let d = f(t) - gg(t)
    if absolu { calc.abs(d) } else { d }
  }
  let h = (b - a) / n
  let s = val(a) + val(b)
  for i in range(1, n) {
    s += if calc.odd(i) { 4 * val(a + i * h) } else { 2 * val(a + i * h) }
  }
  s * h / 3
}

// ── الدالة الرئيسية ──────────────────────────────────────────
#let courbe(
  f,                           // الدالة الرئيسية (أو none إن استعملت morceaux فقط)
  domain: (-4, 4),
  branches: none,              // فروع منفصلة: ((-4, 1.9), (2.1, 5))
  morceaux: (),                // دالة معرّفة بقطع: ((f:, domain:, gauche:, droite:, nom:),)
  // — المظهر والتسمية —
  nom: none, nom-x: auto, nom-ancre: auto, nom-pos: none,
  nom-t: auto, nom-dx: 0, nom-dy: 0,   // موضع الاسم: نسبة على المنحنى (0..1) + إزاحة
  couleur: blue,
  trait: "continu",            // continu | tirets | pointille | mixte | points | lie
  epaisseur: 1.6pt,
  marque: "o", npts: 25,       // نوع النقاط وعددها (trait: "points" أو "lie")
  // — عناصر إضافية —
  autres: (),                  // منحنيات أخرى
  droites: (),                 // مستقيمات
  segments: (),                // قطع مستقيمة بين نقطتين
  textes: (),                  // نصوص حرة في أي مكان
  va: (), ha: (),              // مقاربات
  tangente: none,
  points: (),
  // — الحيز —
  aire: none, aire-avec: none, aire-couleur: auto,
  aire-nom: none, aire-nom-pos: none,
  // — المعلم والسلم —
  x: (-5, 5), y: (-5, 5),
  xstep: auto, ystep: auto, xminor: none, yminor: none,
  echelle: none, size: (8, 6),
  xunite: auto, yunite: auto,  // طول الوحدة بالسنتيمتر على كل محور (مع "pi": سم لكل π)
  xlabel: none, ylabel: none, origine: none,
  // — الشبكة —
  grille: true,                // true | "principale" | "secondaire" | "toutes" | false
  grille-x: auto, grille-y: auto,
  grille-trait: auto,          // continu | tirets | pointille | mixte
  grille-couleur: auto, grille-epaisseur: auto,
  milli-fin: true,             // ورقة مليمترية: إظهار خطوط المليمتر (false = كل 5 مم و1 سم فقط)
  milli-ancre: "origine",      // ورقة مليمترية: "origine" (خط سميك عند الأصل) | "coin" (من الزاوية السفلية اليسرى)
  // — المظهر العام —
  fond: none,                  // لون خلفية الرسم
  cadre: none,                 // true أو لون: إطار حول الرسم
  titre: none,                 // عنوان فوق الرسم
  axes-couleur: auto, axes-epaisseur: auto,
  // — طول التدريجات وشكل الترقيم —
  xtick: auto, ytick: auto,    // طول التدريج الرئيسي (سم) على كل محور
  tick-minor: 0.6,             // نسبة طول التدريج الثانوي إلى الرئيسي
  tick-taille: auto,           // حجم خط أرقام التدريج
  xnum: "normal", ynum: "normal",   // "normal" | "pi"
  xpi: 2, ypi: 2,              // مقام π: خطوة التدريج = π/xpi
  fond-noms: false, samples: 150,
) = {
  assert(x.at(1) > x.at(0), message: "na-courbe: x must be (min, max) with min < max")
  assert(y.at(1) > y.at(0), message: "na-courbe: y must be (min, max) with min < max")
  assert(milli-ancre in ("origine", "coin"), message: "na-courbe: milli-ancre must be \"origine\" or \"coin\"")

  // حجم الرسم: xunite/yunite لهما الأولوية، ثم echelle، ثم size
  let base-w = if echelle == none { size.at(0) } else { (x.at(1) - x.at(0)) * echelle.at(0) }
  let base-h = if echelle == none { size.at(1) } else { (y.at(1) - y.at(0)) * echelle.at(1) }
  let ux = if xunite == auto { auto } else if xnum == "pi" { _cm(xunite) / calc.pi } else { _cm(xunite) }
  let uy = if yunite == auto { auto } else if ynum == "pi" { _cm(yunite) / calc.pi } else { _cm(yunite) }
  let sz = (
    if ux == auto { base-w } else { (x.at(1) - x.at(0)) * ux },
    if uy == auto { base-h } else { (y.at(1) - y.at(0)) * uy },
  )
  let spanx = x.at(1) - x.at(0)
  let spany = y.at(1) - y.at(0)
  let pal = (orange, purple, teal, maroon, olive)

  // خطوات التدريج
  let xs = if xstep != auto { xstep } else if xnum == "pi" { calc.pi / xpi } else { 1 }
  let ys = if ystep != auto { ystep } else if ynum == "pi" { calc.pi / ypi } else { 1 }

  // الشبكة
  let gx = _grille(if grille-x == auto { grille } else { grille-x })
  let gy = _grille(if grille-y == auto { grille } else { grille-y })
  let minor-wanted(g) = g == "minor" or g == "both"
  let xm = if xminor == none and minor-wanted(gx) { if xnum == "pi" { xs / 2 } else { xs / 5 } } else { xminor }
  let ym = if yminor == none and minor-wanted(gy) { if ynum == "pi" { ys / 2 } else { ys / 5 } } else { yminor }

  // الورقة المليمترية: تُرسم على المحورين بالطول الفعلي للرسم تمامًا
  let milli-x = gx == "milli"
  let milli-y = gy == "milli"
  let gx = if milli-x { false } else { gx }
  let gy = if milli-y { false } else { gy }

  // مرور واحد على مستوى واحد من الخطوط (0: 1مم ، 1: 5مم ، 2: 1سم)
  let milli-passe(len, org, vertical, niv, c, e) = {
    let eps = 1e-6
    let k0 = int(calc.ceil(-org * 10 - eps))
    let k1 = int(calc.floor((len - org) * 10 + eps))
    for k in range(k0, k1 + 1) {
      let lv = if calc.rem(k, 10) == 0 { 2 } else if calc.rem(k, 5) == 0 { 1 } else { 0 }
      if lv == niv {
        let p = calc.min(calc.max(org + k / 10, 0), len)
        if vertical {
          draw.line((p, 0), (p, sz.at(1)), stroke: (paint: c, thickness: e))
        } else {
          draw.line((0, p), (sz.at(0), p), stroke: (paint: c, thickness: e))
        }
      }
    }
  }

  let dessiner-milli() = {
    let base = if grille-couleur == auto { rgb("#e8663d") } else { grille-couleur }
    let e = if grille-epaisseur == auto { 0.8pt } else { grille-epaisseur }
    let org-x = if milli-ancre == "coin" { 0.0 } else { -x.at(0) * sz.at(0) / spanx }
    let org-y = if milli-ancre == "coin" { 0.0 } else { -y.at(0) * sz.at(1) / spany }
    let nivs = if milli-fin { (0, 1, 2) } else { (1, 2) }
    let cols = (base.lighten(65%), base.lighten(35%), base)
    let ths = (e * 0.3, e * 0.6, e)
    for nv in nivs {
      if milli-x { milli-passe(sz.at(0), org-x, true, nv, cols.at(nv), ths.at(nv)) }
      if milli-y { milli-passe(sz.at(1), org-y, false, nv, cols.at(nv), ths.at(nv)) }
    }
    draw.rect((0, 0), (sz.at(0), sz.at(1)), stroke: (paint: base, thickness: e))
  }

  let cadre-stroke = if cadre == none or cadre == false { none } else if cadre == true { 0.6pt + black } else { 0.6pt + cadre }

  // ── نص عند نقطة (داخل الإطار فقط) ──
  let etiq(px, py, body, c: black, ancre: "south-west") = {
    if body != none and px >= x.at(0) and px <= x.at(1) and py >= y.at(0) and py <= y.at(1) {
      plot.annotate({
        if fond-noms {
          draw.content((px, py), text(fill: c)[#body], anchor: ancre, padding: 0.08,
            frame: "rect", fill: white, stroke: none)
        } else {
          draw.content((px, py), text(fill: c)[#body], anchor: ancre, padding: 0.1)
        }
      })
    }
  }

  // إزاحة الاسم (nom-dx, nom-dy) من أي عنصر
  let off(d) = (dx: d.at("nom-dx", default: 0), dy: d.at("nom-dy", default: 0))

  // ── وضع اسم: في الموضع الحر pos إن وُجد وإلا في الموضع الافتراضي ──
  let placer(pos, dflt, body, c, a, a0: "south-west", dx: 0, dy: 0) = {
    if body != none {
      let anc = if a != auto { a } else if pos != none { "center" } else { a0 }
      let p = if pos != none { pos } else { dflt() }
      etiq(p.at(0) + dx, p.at(1) + dy, body, c: c, ancre: anc)
    }
  }

  // ── رسم دالة على عدة مجالات بنوع الخط المطلوب ──
  let trace(g, ds, c, tr, w, mq, np) = {
    for d in ds {
      if tr == "points" {
        plot.add(g, domain: d, samples: np, mark: mq, mark-size: 0.1,
          style: (stroke: none), mark-style: (fill: c, stroke: c))
      } else if tr == "lie" {
        plot.add(g, domain: d, samples: np, mark: mq, mark-size: 0.1,
          style: (stroke: (paint: c, thickness: w)), mark-style: (fill: c, stroke: c))
      } else {
        plot.add(g, domain: d, samples: samples,
          style: (stroke: (paint: c, thickness: w, dash: _dash(tr))))
      }
    }
  }

  // ── تسمية منحنى (cv: قاموس يحمل nom و nom-pos و nom-x و nom-t و nom-dx ...) ──
  let nommer(g, ds, cv, c) = {
    placer(cv.at("nom-pos", default: none), () => {
      let dl = ds.last()
      let lo = calc.max(dl.at(0), x.at(0))
      let hi = calc.min(dl.at(1), x.at(1))
      let nx = cv.at("nom-x", default: auto)
      let nt = cv.at("nom-t", default: auto)
      let xl = if nx != auto { nx } else if nt != auto { lo + (hi - lo) * nt } else { hi - (hi - lo) * 0.1 }
      (xl, g(xl))
    }, cv.at("nom", default: none), c, cv.at("nom-ancre", default: auto), ..off(cv))
  }

  // ── طرف قطعة: مغلق (ممتلئ) أو مفتوح (فارغ) ──
  let borne(px, py, t, c) = {
    plot.add(((px, py),), mark: "o", mark-size: 0.11, style: (stroke: none),
      mark-style: (fill: if t == "ferme" { c } else { white }, stroke: c))
  }

  let main = (f: f, domain: domain, branches: branches, morceaux: morceaux,
    nom: nom, nom-x: nom-x, nom-ancre: nom-ancre, nom-pos: nom-pos,
    nom-t: nom-t, nom-dx: nom-dx, nom-dy: nom-dy,
    couleur: couleur, trait: trait, epaisseur: epaisseur, marque: marque, npts: npts)
  let toutes = (main,) + autres

  // ── أنماط المحاور: طول التدريجات والشبكة ──
  let ax = (:)
  let xt = _cm(xtick)
  let yt = _cm(ytick)
  if xt != auto { ax.insert("x", (tick: (length: xt, minor-length: xt * tick-minor))) }
  if yt != auto { ax.insert("y", (tick: (length: yt, minor-length: yt * tick-minor))) }
  if grille-trait != auto or grille-couleur != auto or grille-epaisseur != auto {
    let gc = if grille-couleur == auto { luma(170) } else { grille-couleur }
    let ge = if grille-epaisseur == auto { 0.5pt } else { grille-epaisseur }
    let gd = if grille-trait == auto { none } else { _dash(grille-trait) }
    ax.insert("grid", (stroke: (paint: gc, thickness: ge, dash: gd)))
    ax.insert("minor-grid", (stroke: (paint: gc.lighten(35%), thickness: ge * 0.6, dash: gd)))
  }

  if axes-couleur != auto or axes-epaisseur != auto {
    ax.insert("stroke", (
      paint: if axes-couleur == auto { black } else { axes-couleur },
      thickness: if axes-epaisseur == auto { 1pt } else { axes-epaisseur },
    ))
  }

  // ── خيارات المحورين الاختيارية ──
  let po = (:)
  let fx = _fmt(xnum, xpi, tick-taille)
  let fy = _fmt(ynum, ypi, tick-taille)
  if fx != auto { po.insert("x-format", fx) }
  if fy != auto { po.insert("y-format", fy) }

  canvas({
    if fond != none { draw.rect((0, 0), (sz.at(0), sz.at(1)), fill: fond, stroke: none) }
    if milli-x or milli-y { dessiner-milli() }
    if cadre-stroke != none { draw.rect((0, 0), (sz.at(0), sz.at(1)), stroke: cadre-stroke) }
    if titre != none { draw.content((sz.at(0) / 2, sz.at(1)), titre, anchor: "south", padding: 0.25) }
    if ax.len() > 0 { draw.set-style(axes: ax) }
    plot.plot(
      size: sz,
      x-min: x.at(0), x-max: x.at(1),
      y-min: y.at(0), y-max: y.at(1),
      axis-style: "school-book",
      x-tick-step: xs, y-tick-step: ys,
      x-minor-tick-step: xm, y-minor-tick-step: ym,
      x-label: xlabel, y-label: ylabel,
      x-grid: gx, y-grid: gy,
      ..po,
      {
        // 0) بيانات خفية تضمن وجود المحورين في cetz-plot حتى لو لم يُرسم أي منحنى (ورقة فارغة)
        plot.add(((x.at(0), y.at(0)), (x.at(1), y.at(1))), style: (stroke: none))

        // 1) الحيز المظلل (خلف المنحنيات)
        if aire != none {
          let g = if aire-avec == none { t => 0 } else { aire-avec }
          let ac = if aire-couleur == auto { couleur } else { aire-couleur }
          plot.add-fill-between(f, g, domain: aire, samples: samples,
            style: (fill: ac.transparentize(70%), stroke: none))
          placer(aire-nom-pos, () => {
            let m = (aire.at(0) + aire.at(1)) / 2
            (m, (f(m) + g(m)) / 2)
          }, aire-nom, black, auto, a0: "center")
        }

        // 2) المنحنيات (الرئيسي + الأخرى) وأسماؤها
        for (i, cv) in toutes.enumerate() {
          let g = cv.at("f", default: none)
          let c = cv.at("couleur", default: pal.at(calc.rem(i, pal.len())))
          let tr = cv.at("trait", default: "continu")
          let w = cv.at("epaisseur", default: 1.6pt)
          let mq = cv.at("marque", default: "o")
          let np = cv.at("npts", default: 25)
          if g != none {
            let cb = cv.at("branches", default: none)
            let ds = if cb != none { cb } else { (cv.at("domain", default: x),) }
            trace(g, ds, c, tr, w, mq, np)
            nommer(g, ds, cv, c)
          }
          // دالة معرّفة بقطع
          for pc in cv.at("morceaux", default: ()) {
            let pf = pc.at("f")
            let pd = pc.at("domain")
            let pcoul = pc.at("couleur", default: c)
            trace(pf, (pd,), pcoul, pc.at("trait", default: tr), w, mq, np)
            let tg = pc.at("gauche", default: none)
            let td = pc.at("droite", default: none)
            if tg != none { borne(pd.at(0), pf(pd.at(0)), tg, pcoul) }
            if td != none { borne(pd.at(1), pf(pd.at(1)), td, pcoul) }
            nommer(pf, (pd,), pc, pcoul)
          }
        }

        // 3) المقاربات
        for a in va {
          let ad = if type(a) == dictionary { a } else { (v: a) }
          plot.add-vline(ad.at("v"), style: (stroke: (paint: red, dash: "dashed", thickness: 1pt)))
          placer(ad.at("nom-pos", default: none),
            () => (ad.at("v"), y.at(0) + spany * ad.at("nom-t", default: 0.95)),
            ad.at("nom", default: none), red, ad.at("nom-ancre", default: auto),
            a0: "north-west", ..off(ad))
        }
        for b in ha {
          let bd = if type(b) == dictionary { b } else { (v: b) }
          plot.add-hline(bd.at("v"), style: (stroke: (paint: red, dash: "dashed", thickness: 1pt)))
          placer(bd.at("nom-pos", default: none),
            () => (x.at(0) + spanx * bd.at("nom-t", default: 0.98), bd.at("v")),
            bd.at("nom", default: none), red, bd.at("nom-ancre", default: auto),
            a0: "south-east", ..off(bd))
        }

        // 4) المستقيمات
        for d in droites {
          let c = d.at("couleur", default: green.darken(20%))
          let dsh = d.at("dash", default: _dash(d.at("trait", default: "continu")))
          let st = (stroke: (paint: c, thickness: d.at("epaisseur", default: 1.2pt), dash: dsh))
          if "x" in d {
            plot.add-vline(d.at("x"), style: st)
            placer(d.at("nom-pos", default: none),
              () => (d.at("x"), y.at(0) + spany * d.at("nom-t", default: 0.95)),
              d.at("nom", default: none), c, d.at("nom-ancre", default: auto),
              a0: "north-west", ..off(d))
          } else {
            let ca = d.at("a", default: 0)
            let cb = d.at("b", default: 0)
            let dr = t => ca * t + cb
            plot.add(dr, domain: x, samples: 2, style: st)
            placer(d.at("nom-pos", default: none), () => {
              let xl = if "nom-x" in d { d.at("nom-x") } else { x.at(0) + spanx * d.at("nom-t", default: 0.9) }
              (xl, dr(xl))
            }, d.at("nom", default: none), c, d.at("nom-ancre", default: auto), ..off(d))
          }
        }

        // 5) القطع المستقيمة بين نقطتين
        for sg in segments {
          let p1 = sg.at("de")
          let p2 = sg.at("a")
          let c = sg.at("couleur", default: black)
          plot.add((p1, p2), style: (stroke: (paint: c,
            thickness: sg.at("epaisseur", default: 1.2pt),
            dash: _dash(sg.at("trait", default: "continu")))))
          placer(sg.at("nom-pos", default: none), () => {
            let t = sg.at("nom-t", default: 0.5)
            (p1.at(0) + (p2.at(0) - p1.at(0)) * t, p1.at(1) + (p2.at(1) - p1.at(1)) * t)
          }, sg.at("nom", default: none), c, sg.at("nom-ancre", default: auto),
            a0: "south", ..off(sg))
        }

        // 6) المماس
        if tangente != none {
          let td = if type(tangente) == dictionary { tangente } else { (a: tangente) }
          let ta = td.at("a")
          let h = 0.0001
          let m = (f(ta + h) - f(ta - h)) / (2 * h)
          let fa = f(ta)
          let tl = t => m * (t - ta) + fa
          let tc = td.at("couleur", default: green.darken(20%))
          plot.add(tl, domain: x, samples: 2, style: (stroke: (paint: tc, thickness: 1.2pt,
            dash: _dash(td.at("trait", default: "continu")))))
          placer(td.at("nom-pos", default: none), () => {
            let xl = if "nom-x" in td { td.at("nom-x") } else if "nom-t" in td { x.at(0) + spanx * td.at("nom-t") } else { ta + spanx * 0.12 }
            (xl, tl(xl))
          }, td.at("nom", default: none), tc, td.at("nom-ancre", default: auto), ..off(td))
        }

        // 7) نقاط: على المنحنى (v) أو حرة (p) ، مغلقة أو مفتوحة ، مع إسقاطات
        for p in points {
          let pd = if type(p) == dictionary { p } else { (v: p) }
          let pp = if "p" in pd { pd.at("p") } else { (pd.at("v"), f(pd.at("v"))) }
          let pc = pd.at("couleur", default: black)
          plot.add((pp,), mark: pd.at("marque", default: "o"), mark-size: pd.at("taille", default: 0.12),
            style: (stroke: none),
            mark-style: (fill: if pd.at("ouvert", default: false) { white } else { pc }, stroke: pc))
          if pd.at("proj", default: false) {
            let ps = (stroke: (paint: gray, dash: "dashed", thickness: 0.8pt))
            plot.add((pp, (pp.at(0), 0)), style: ps)
            plot.add((pp, (0, pp.at(1))), style: ps)
          }
          placer(pd.at("nom-pos", default: none), () => pp, pd.at("nom", default: none),
            pc, pd.at("nom-ancre", default: auto), ..off(pd))
        }

        // 8) نصوص حرة
        for tx in textes {
          let pos = tx.at("pos")
          etiq(pos.at(0), pos.at(1), tx.at("t"), c: tx.at("couleur", default: black),
            ancre: tx.at("ancre", default: "center"))
        }

        // 9) اسم نقطة الأصل
        etiq(0, 0, origine, ancre: "north-east")
      },
    )
  })
}

// ── ورقة مليمترية فارغة (اختصار): نفس وسائط courbe مع grille: "millimetre" ──
#let papier-milli(..args) = courbe(none, ..(grille: "millimetre", ..args.named()))
