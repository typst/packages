#import "../core.typ": *

// ─── Palette APHP ──────────────────────────────────────────────────────────
#let aphp-navy  = rgb("#153D8A")  // grand panneau couverture, label section
#let aphp-blue  = rgb("#0063AF")  // blocs titre, numéro slide, connecteurs
#let aphp-dark  = rgb("#2C256B")  // bloc numéro chapitre (transition)
#let aphp-gold  = rgb("#FFC000")  // double chevron >>
#let aphp-text  = rgb("#153D8A")  // texte courant (identique à navy)

// Espace de référence PPTX 16:9 (toutes les coordonnées ci-dessous sont dans cet espace).
// Les fonctions de dessin calculent sx = page.width/aphp-pptx-w et sy = page.height/aphp-pptx-h
// via context, ce qui les rend correctes pour tous les ratios (16:9, 4:3, etc.).
#let aphp-pptx-w = 33.867cm
#let aphp-pptx-h = 19.05cm

// ─── Éléments communs ──────────────────────────────────────────────────────

// Logos bas-gauche et bas-droit (communs à toutes les slides)
// Coordonnées PPTX : bas-gauche x=0.953 y=17.630 (3.463×0.863), bas-droit x=27.735 y=17.343 (5.997×1.693)
#let aphp-logos(conf) = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  let logo-left = if conf.at("aphp-logo-left", default: none) != none {
    conf.at("aphp-logo-left")
  } else {
    image("../../assets/aphp/aphp-sorbonne.png", width: 3.463cm * sx, height: 0.863cm * sx)
  }
  let logo-right = if conf.at("aphp-logo-right", default: none) != none {
    conf.at("aphp-logo-right")
  } else {
    image("../../assets/aphp/aphp-logo-full.png", width: 5.997cm * sx, height: 1.693cm * sx)
  }
  place(top+left, dx: 0.953cm * sx, dy: 17.630cm * sy, logo-left)
  place(top+left, dx: 27.735cm * sx, dy: 17.343cm * sy, logo-right)
}

// Icône cœur AP-HP (haut de la ligne verticale)
// Coordonnées PPTX : x=3.132 y=1.066 (0.995×0.995)
#let aphp-heart() = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  place(top+left, dx: 3.132cm * sx, dy: 1.066cm * sy,
    image("../../assets/aphp/aphp-heart.png", width: 0.995cm * sx, height: 0.995cm * sx))
}

// Numéro de slide (rectangle bleu au bas de la sidebar)
// Coordonnées PPTX : x=2.994 y=16.560 (1.270×0.466)
#let aphp-slide-number() = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  let n = logical-slide-counter.get().at(0)
  place(top+left, dx: 2.994cm * sx, dy: 16.560cm * sy,
    block(width: 1.270cm * sx, height: 0.466cm * sy, fill: aphp-blue, clip: true,
      align(center+horizon,
        text(size: 7pt, weight: "bold", fill: white, str(n)))))
}

// ─── Lignes verticales ─────────────────────────────────────────────────────

// Ligne simple (layouts 1 & 2 : couverture, fin)
// PPTX : x=3.630 y=2.325 longueur=13.800
#let aphp-line-single(color: aphp-blue) = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  place(top+left, dx: 3.630cm * sx, dy: 2.325cm * sy,
    line(angle: 90deg, length: 13.800cm * sy, stroke: 0.75pt + color))
}


// Ligne unique avec label de navigation dans le gap (layout 5 : contenu)
// PPTX : x=3.630, ligne de y=2.325 à y=16.125 (longueur 13.800cm)
// Gap fixe (2.5cm PPTX) centré à y≈9.4cm — pas de measure() pour éviter
// les avertissements "layout did not converge" dans le foreground de page.
#let aphp-line-with-label(conf) = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h

  let line-start-y = 2.325cm * sy
  let line-length  = 13.800cm * sy
  let line-end-y   = line-start-y + line-length
  let gap-center-y = 9.417cm * sy  // centre : (8.527+10.307)/2 PPTX
  let gap-half     = 1.25cm * sy   // demi-hauteur fixe (≈ 2.5cm PPTX, ≥ 5 lignes à 9pt)

  // Styles par niveau : part/section en gras, subsection en régulier
  let level-modes  = (:)
  let text-styles  = (:)
  for (role, lvl) in conf.mapping {
    level-modes.insert("level-" + str(lvl) + "-mode", "current")
    let w = if role == "subsection" { "regular" } else { "bold" }
    text-styles.insert("level-" + str(lvl), (
      active:    (weight: w, fill: aphp-blue),
      completed: (weight: w, fill: aphp-blue),
      inactive:  (weight: w, fill: aphp-blue),
    ))
  }

  let label-w   = 3.080cm * sx
  let sidebar-align = conf.at("aphp-sidebar-align", default: left)
  let label-raw = text(size: 9pt, font: conf.text-font,
    nav.progressive-outline(
      ..level-modes,
      layout: "vertical",
      clickable: false,
      max-length: conf.max-length,
      text-styles: text-styles,
      item-align: sidebar-align,
    ))

  let gap-top-y = gap-center-y - gap-half
  let gap-bot-y = gap-center-y + gap-half

  // Segment haut
  place(top+left, dx: 3.630cm * sx, dy: line-start-y,
    line(angle: 90deg, length: gap-top-y - line-start-y, stroke: 0.75pt + aphp-blue))
  // Segment bas
  place(top+left, dx: 3.630cm * sx, dy: gap-bot-y,
    line(angle: 90deg, length: line-end-y - gap-bot-y, stroke: 0.75pt + aphp-blue))
  // Label centré verticalement et horizontalement dans le gap
  place(top+left, dx: 2.130cm * sx, dy: gap-top-y,
    block(width: label-w, height: 2 * gap-half, align(center + horizon, label-raw)))
}

// ─── Header contenu (Layout 5) ─────────────────────────────────────────────
#let aphp-header(conf) = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  let slide-meta = resolve-current-slide-meta()
  if slide-meta == none { return none }
  let resolved-title = slide-meta.resolved-title
  let is-continuation = slide-meta.is-continuation
  let title-display = if is-continuation and resolved-title != none {
    resolved-title + text(size: 0.8em, weight: "regular", fill: aphp-blue, conf.slide-break-suffix)
  } else {
    resolved-title
  }

  // Ligne unique avec label de section horizontal dans le gap
  aphp-line-with-label(conf)

  // Cœur
  aphp-heart()

  // Titre de la slide (headline)
  // PPTX : x=5.934 y=1.411 (25.806×1.302)
  if title-display != none {
    place(top+left, dx: 5.934cm * sx, dy: 1.411cm * sy,
      block(width: 25.806cm * sx, height: 1.302cm * sy,
        align(left+horizon,
          text(size: 1.4em, weight: "regular", fill: aphp-text, title-display))))
  }

  // Numéro de slide
  aphp-slide-number()

  // Logos
  aphp-logos(conf)
}

// ─── Slide de titre (Layouts 1 et 2) ──────────────────────────────────────
#let aphp-title-slide(conf) = context {
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  let cover-style = conf.at("aphp-cover-style", default: "full")
  let classification = conf.at("aphp-classification", default: none)
  let title-line2 = conf.at("aphp-title-line2", default: none)
  let has-line2 = title-line2 != none and title-line2 != conf.title

  empty-slide(fill: conf.at("title-bg-light", default: white), count: false, {
    // Banderole de classification (layout 2 uniquement)
    // PPTX : x=0 y=0 hauteur=1.124
    if cover-style == "light" and classification != none {
      place(top+left, dx: 0pt, dy: 0pt,
        block(width: 100%, height: 1.124cm * sy, fill: aphp-blue,
          align(left+horizon, pad(x: 1em,
            text(size: 0.45em, fill: white, classification)))))
    }

    // Grand panneau marine (layout 1 "full" uniquement)
    // PPTX : x=5.934 y=1.124 (27.929×15.903)
    if cover-style == "full" {
      place(top+left, dx: 5.934cm * sx, dy: 1.124cm * sy,
        block(width: 27.929cm * sx, height: 15.903cm * sy, fill: aphp-navy))
    }

    // Ligne verticale simple
    aphp-line-single()

    // Cœur
    aphp-heart()

    // Double chevron doré
    // PPTX : x=1.419 y=2.375 (0.865×0.917)
    place(top+left, dx: 1.419cm * sx, dy: 2.375cm * sy,
      image("../../assets/aphp/aphp-chevron.png", width: 0.865cm * sx, height: 0.917cm * sx))

    // Blocs titre (ligne 1 courte + ligne 2 large)
    // Si aphp-title-line2 est fourni, ligne 1 = titre, ligne 2 = title-line2
    // Sinon, ligne 1 = vide (décoration), ligne 2 = titre complet

    // Bloc 1 auto-sized — première ligne du titre (uniquement si title-line2 fourni)
    // PPTX : x=1.428 y=4.128
    if has-line2 {
      place(top+left, dx: 1.428cm * sx, dy: 4.128cm * sy,
        box(fill: aphp-blue,
          pad(x: 0.4em, y: 0.3em,
            text(size: 1.4em, weight: "bold", fill: white,
              font: conf.text-font, conf.title))))
    }

    // Bloc 2 auto-sized — titre complet ou deuxième ligne (même taille que bloc 1)
    // PPTX full : x=1.428 y=6.412 ; light : y=6.583
    let title-line2-content = if has-line2 { title-line2 } else { conf.title }
    let title-y2-pptx = if cover-style == "light" { 6.583cm } else { 6.412cm }
    place(top+left, dx: 1.428cm * sx, dy: title-y2-pptx * sy,
      box(fill: aphp-blue,
        pad(x: 0.4em, y: 0.3em,
          text(size: 1.4em, weight: "bold", fill: white,
            font: conf.text-font, title-line2-content))))

    // Sous-titre
    // PPTX full : x=9.428 y=8.801 (20.936×2.600) ; light : y=9.629
    let subtitle-y-pptx = if cover-style == "light" { 9.629cm } else { 8.801cm }
    let subtitle-fill = if cover-style == "light" { aphp-navy } else { none }
    if conf.subtitle != none {
      place(top+left, dx: 9.428cm * sx, dy: subtitle-y-pptx * sy,
        block(width: 20.936cm * sx, height: 2.600cm * sy, fill: subtitle-fill, clip: true,
          align(left+horizon, pad(x: 0.5em,
            text(size: 1.4em, fill: white, font: conf.text-font, conf.subtitle))))
      )
    }

    // Auteur et affiliation — sous le sous-titre, alignés sur la même zone droite
    let author-text-fill = if cover-style == "light" { aphp-navy } else { white }
    if conf.author != none or conf.affiliation != none {
      let author-y-pptx = subtitle-y-pptx + 3.1cm
      place(top+left, dx: 9.428cm * sx, dy: author-y-pptx * sy,
        block(width: 20.936cm * sx,
          pad(x: 0.5em,
            stack(dir: ttb, spacing: 0.35em,
              ..if conf.author != none {
                (text(size: 1.1em, weight: "bold", fill: author-text-fill,
                  font: conf.text-font, conf.author),)
              } else { () },
              ..if conf.affiliation != none {
                (text(size: 0.9em, fill: author-text-fill,
                  font: conf.text-font, conf.affiliation),)
              } else { () }
            ))))
    }

    // Date auto-sized — largeur s'adapte au contenu pour toujours tenir sur une ligne
    // PPTX : x=2.211 y=16.560
    place(top+left, dx: 2.211cm * sx, dy: 16.560cm * sy,
      box(fill: aphp-blue,
        pad(x: 0.5em, y: 0.1em,
          text(size: 0.5em, fill: white, font: conf.text-font, conf.date))))

    // Logos
    aphp-logos(conf)
  })
}

// ─── Slide de transition de section (Layouts 3 et 4) ──────────────────────
// Appelé via conf.render-transition-func avec signature (h, is-annex).
// nav.render-transition crée déjà le slide (empty-slide) ; content-wrapper
// retourne uniquement le CONTENU (pas un nouveau slide).
#let aphp-render-transition(h, is-annex) = context {
  let conf = config-state.get()
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  nav.render-transition(h,
    top-padding: 0pt,
    use-short-title: false,
    content-wrapper: (roadmap, h, active) => {
      // Récupérer le numéro de section / chapitre
      let level-nums = counter(heading).at(h.location())
      let part-level = conf.mapping.at("part", default: none)
      let is-part = part-level != none and h.level == part-level
      // Quand un niveau "part" existe, les numéros section/sous-section commencent
      // à l'index 1 du compteur (index 0 = numéro de partie).
      let start-idx = if conf.mapping.keys().contains("part") { 1 } else { 0 }

      let chap-num = if is-part {
        numbering(conf.part-numbering-format, ..level-nums)
      } else {
        str(level-nums.at(start-idx, default: 0))
      }

      // Retourner le contenu page-absolue (empty-slide a margin=0pt)
      {
        // Mesure du numéro pour calculer dynamiquement le gap de la ligne
        // Taille absolue (7 × text-size) pour éviter que la résolution de `em`
        // dépende du contexte typographique du heading courant (niveau 2 vs 3)
        let num-font-size = 7 * conf.text-size
        let num-content = text(size: num-font-size, weight: "bold", fill: aphp-dark,
          font: conf.text-font, chap-num)
        let num-size = measure(num-content)
        let num-h = num-size.height
        let num-w = num-size.width
        let num-dy  = 3.500cm * sy
        let gap-pad = 0.250cm * sy
        // Centré horizontalement sur la ligne verticale
        let num-dx  = 3.630cm * sx - num-w / 2

        // Ligne divisée — gap calculé sur la hauteur réelle du numéro
        let seg-top-len = num-dy - gap-pad - 2.325cm * sy
        if seg-top-len > 0pt {
          place(top+left, dx: 3.630cm * sx, dy: 2.325cm * sy,
            line(angle: 90deg, length: seg-top-len, stroke: 0.75pt + aphp-blue))
        }
        let seg-bot-dy  = num-dy + num-h + gap-pad
        let seg-bot-len = 16.563cm * sy - seg-bot-dy
        if seg-bot-len > 0pt {
          place(top+left, dx: 3.630cm * sx, dy: seg-bot-dy,
            line(angle: 90deg, length: seg-bot-len, stroke: 0.75pt + aphp-blue))
        }

        // Cœur AP-HP
        aphp-heart()

        // Grand numéro — centré sur la ligne verticale
        place(top+left, dx: num-dx, dy: num-dy, num-content)

        // Chevron doré — centré verticalement sur le numéro
        place(top+left, dx: 0.800cm * sx,
          dy: num-dy + num-h / 2 - 0.459cm * sy,
          image("../../assets/aphp/aphp-chevron.png", width: 0.865cm * sx, height: 0.917cm * sx))

        // Logique des blocs titre — cohérente pour part / section / sous-section :
        //   part / section      → bloc 1 = titre du heading courant, bloc 2 absent
        //   sous-section        → bloc 1 = titre de la section parente, bloc 2 = titre sous-section
        let section-level-t = conf.mapping.at("section", default: 1)
        let is-section-t = h.level == section-level-t

        // Heading pour bloc 1 : h lui-même (part ou section) ou section parente (sous-section)
        let section-h-b1 = if is-part or is-section-t {
          h
        } else {
          let sec-hs = query(selector(heading.where(level: section-level-t)).before(h.location()))
          if sec-hs.len() > 0 { sec-hs.last() } else { none }
        }

        // Contenu bloc 1
        let bloc1-content = if section-h-b1 != none {
          let nums1 = counter(heading).at(section-h-b1.location())
          let prefix = if is-part { chap-num } else { str(nums1.at(start-idx, default: 0)) }
          if conf.show-header-numbering { [#prefix. #section-h-b1.body] } else { section-h-b1.body }
        } else { none }

        // Contenu bloc 2 (absent pour parts et sections)
        let bloc2-content = if not is-part and not is-section-t {
          if conf.show-header-numbering {
            [#{numbering(conf.numbering-format, ..level-nums.slice(start-idx))} #h.body]
          } else { h.body }
        } else { none }

        // Bloc 1 — auto-sized (comme bloc 2), titre de section/partie
        // Position : juste après le numéro (y dynamique + décalage fixe)
        let bloc1-dy = num-dy + num-h + 0.600cm * sy
        if bloc1-content != none {
          place(top+left, dx: 0.800cm * sx, dy: bloc1-dy,
            box(fill: aphp-blue,
              pad(x: 0.5em, y: 0.3em,
                text(size: 1.2em, weight: "bold", fill: white,
                  font: conf.text-font, bloc1-content))))
        }

        // Bloc 2 — auto-sized, titre de sous-section (gap réduit ~0.3cm avec bloc 1)
        let bloc2-dy = bloc1-dy + 1.700cm * sy
        if bloc2-content != none {
          place(top+left, dx: 0.800cm * sx, dy: bloc2-dy,
            box(fill: aphp-blue,
              pad(x: 0.5em, y: 0.3em,
                text(size: 1.2em, weight: "bold", fill: white,
                  font: conf.text-font, bloc2-content))))
        }

        // Numéro de slide
        aphp-slide-number()

        // Logos
        aphp-logos(conf)
      }
    }
  )
}

// ─── Slide de fin ──────────────────────────────────────────────────────────
// Reprend le layout de la diapositive de titre : fond blanc + panneau marine
// à droite (en mode "full"), ligne bleue, chevron, blocs bleus.
// - title    → bloc bleu gauche  (ex : "Merci de votre attention !")
// - subtitle → zone droite haute (ex : "Questions ?")
// - contact  → zone droite basse (ex : nom, email)
#let aphp-ending-slide(
  title: [Merci de votre attention !],
  subtitle: [Questions ?],
  contact: none,
) = context {
  let conf = config-state.get()
  let sx = page.width  / aphp-pptx-w
  let sy = page.height / aphp-pptx-h
  let cover-style = conf.at("aphp-cover-style", default: "full")

  empty-slide(fill: white, {
    // Grand panneau marine à droite (identique à la diapositive de titre)
    if cover-style == "full" {
      place(top+left, dx: 5.934cm * sx, dy: 1.124cm * sy,
        block(width: 27.929cm * sx, height: 15.903cm * sy, fill: aphp-navy))
    }

    // Ligne verticale simple
    aphp-line-single()

    // Cœur
    aphp-heart()

    // Double chevron doré
    place(top+left, dx: 1.419cm * sx, dy: 2.375cm * sy,
      image("../../assets/aphp/aphp-chevron.png", width: 0.865cm * sx, height: 0.917cm * sx))

    // Bloc titre auto-sized (position du titre seul de la diapositive de titre)
    // PPTX full : x=1.428 y=6.412 ; light : y=6.583
    let title-y-pptx = if cover-style == "light" { 6.583cm } else { 6.412cm }
    place(top+left, dx: 1.428cm * sx, dy: title-y-pptx * sy,
      box(fill: aphp-blue,
        pad(x: 0.4em, y: 0.3em,
          text(size: 1.4em, weight: "bold", fill: white,
            font: conf.text-font, title))))

    // Sous-titre — zone droite (identique à la diapositive de titre)
    // PPTX full : x=9.428 y=8.801 ; light : y=9.629
    let subtitle-y-pptx = if cover-style == "light" { 9.629cm } else { 8.801cm }
    let subtitle-fill = if cover-style == "light" { aphp-navy } else { none }
    if subtitle != none {
      place(top+left, dx: 9.428cm * sx, dy: subtitle-y-pptx * sy,
        block(width: 20.936cm * sx, height: 2.600cm * sy, fill: subtitle-fill, clip: true,
          align(left+horizon, pad(x: 0.5em,
            text(size: 1.4em, fill: white, font: conf.text-font, subtitle)))))
    }

    // Contact — zone auteur/affiliation (même position que dans la diapositive de titre)
    let contact-fill = if cover-style == "light" { aphp-navy } else { white }
    if contact != none and contact != () {
      let contact-y-pptx = subtitle-y-pptx + 3.1cm
      place(top+left, dx: 9.428cm * sx, dy: contact-y-pptx * sy,
        block(width: 20.936cm * sx,
          pad(x: 0.5em, {
            set text(size: 1.0em, fill: contact-fill, font: conf.text-font)
            if type(contact) == array { contact.join(linebreak()) } else { contact }
          })))
    }

    // Logos
    aphp-logos(conf)
  })
}

// ─── Template principal ────────────────────────────────────────────────────
#let aphp-template(
  title: none,
  author: none,
  short-title: none,
  short-author: none,
  affiliation: none,
  subtitle: none,
  date: datetime.today().display(),
  aspect-ratio: "16-9",
  text-font: ("Open Sans", "Lato", "Fira Sans"),
  text-size: 20pt,
  primary-color: none,
  alert-color: none,
  // Paramètres spécifiques APHP
  cover-style: "full",              // "full" | "light"
  classification: none,            // ex: "C1 - Interne"
  title-line2: none,               // 2e ligne de titre (optionnel, défaut = title)
  logo-left: none,                 // surcharge logo bas-gauche
  logo-right: none,                // surcharge logo bas-droit
  title-bg-light: white,           // fond diapo de titre (mode clair)
  title-bg-dark: white,            // fond diapo de titre (mode sombre — non utilisé actuellement)
  sidebar-align: center,           // alignement du fil d'ariane : left | center | right
  // Options standard
  show-header-numbering: true,
  numbering-format: "1.1",
  part-numbering-format: "I",
  part-title: [Part],
  title-smallcaps: false,
  appendix-title: [Appendix],
  appendix-main-title: [Appendices],
  appendix-numbering-format: "I",
  mapping: (section: 1, subsection: 2),
  bib-style: "apa",
  transitions: (:),
  show-outline: false,
  outline-title: [Outline],
  outline-depth: 2,
  outline-columns: 1,
  auto-title: true,
  progress-bar: "none",
  progress-bar-height: 2pt,
  equation-definitions-width: 85%,
  transition-roadmap-width: 60%,
  slide-break-suffix: [ (cont.)],
  footer-author: false,
  footer-title: false,
  max-length: none,
  use-short-title: false,
  dark-mode: false,
  handout: false,
  math-font: "Noto Sans Math",
  code-font: ("Fira Code", "DejaVu Sans Mono"),
  raw-block-style: true,
  body
) = {
  let final-primary = if primary-color != none { primary-color } else { aphp-blue }
  let final-alert   = if alert-color   != none { alert-color   } else { aphp-gold }

  // Dimensions de la page Typst selon le ratio (pour calculer les marges)
  let (page-w, page-h) = if aspect-ratio == "4-3" {
    (28.0cm, 21.0cm)
  } else {
    (29.7cm, 16.7cm)
  }
  let aphp-sx = page-w / aphp-pptx-w
  let aphp-sy = page-h / aphp-pptx-h

  let resolved-max-length = if type(max-length) == dictionary {
    let new-dict = (:)
    for (key, val) in max-length {
      if key in mapping {
        new-dict.insert("level-" + str(mapping.at(key)), val)
      } else {
        new-dict.insert(key, val)
      }
    }
    new-dict
  } else {
    max-length
  }

  let conf = (
    title:        title,
    author:       author,
    short-title:  if short-title  != none { short-title  } else { title  },
    short-author: if short-author != none { short-author } else { author },
    affiliation:  affiliation,
    subtitle:     subtitle,
    date:         date,
    aspect-ratio: aspect-ratio,
    text-font:    text-font,
    text-size:    text-size,
    text-color:   aphp-text,
    math-font:    math-font,
    code-font:    code-font,
    primary-color:    final-primary,
    marker-color:     final-primary,
    transition-fill:  white,
    alert-color:      final-alert,
    logo-transition:  none,
    logo-slide:       none,
    show-header-numbering:      show-header-numbering,
    numbering-format:           numbering-format,
    part-numbering-format:      part-numbering-format,
    part-title:                 part-title,
    title-smallcaps:            title-smallcaps,
    appendix-title:             appendix-title,
    appendix-main-title:        appendix-main-title,
    appendix-numbering-format:  appendix-numbering-format,
    mapping:       mapping,
    bib-style:     bib-style,
    transitions:   transitions,
    show-outline:  show-outline,
    outline-title: outline-title,
    outline-depth: outline-depth,
    outline-columns: outline-columns,
    auto-title:    auto-title,
    progress-bar:         progress-bar,
    progress-bar-height:  progress-bar-height,
    equation-definitions-width: equation-definitions-width,
    transition-roadmap-width:   transition-roadmap-width,
    slide-break-suffix: slide-break-suffix,
    footer-author: footer-author,
    footer-title:  footer-title,
    max-length:    resolved-max-length,
    use-short-title: use-short-title,
    dark-mode:     dark-mode,
    handout:       handout,
    // Marges APHP — proportionnelles aux dimensions de la page (coordonnées PPTX × sx/sy)
    margin-top:    3.824cm * aphp-sy,
    margin-left:   5.934cm * aphp-sx,   // largeur de la sidebar
    margin-right:  2.132cm * aphp-sx,
    margin-bottom: 1.864cm * aphp-sy,
    body-inset-x:  0pt,
    cite-box-bottom-dy: -1.5em,
    // Header custom APHP (dessine toute la sidebar en foreground)
    header-func:        aphp-header,
    footer-func:        none,
    // Slides spéciaux
    title-slide-func:   aphp-title-slide,
    ending-slide-func:  aphp-ending-slide,
    render-transition-func: aphp-render-transition,
    // Focus slide
    focus-layout:   "centered",
    focus-bg-light: final-primary,
    focus-bg-dark:  final-primary.darken(40%),
    focus-text-color: white,
    // Cohérence API avec sorbonne/iplesp
    title-bg-light: title-bg-light,
    title-bg-dark:  title-bg-dark,
    // Paramètres APHP spécifiques (transmis via conf)
    aphp-cover-style:    cover-style,
    aphp-classification: classification,
    aphp-title-line2:    title-line2,
    aphp-logo-left:      if type(logo-left)  == str { image(logo-left)  } else { logo-left  },
    aphp-logo-right:     if type(logo-right) == str { image(logo-right) } else { logo-right },
    aphp-sidebar-align:  sidebar-align,
    // Pas de transition roadmap standard (géré par render-transition-func)
    transition-text-color:   white,
    transition-active-color: white,
    transition-title-color:  white,
    transition-logo-func:    none,
    title-logo-func:         none,
  )

  core-template(conf: conf, raw-block-style: raw-block-style, body)
}
