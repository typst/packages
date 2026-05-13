/// Output Construction Module
///
/// Every public function in this module takes named parameters and returns or
/// emits Typst content. Functions are intentionally narrow: each one builds
/// exactly one letter component and knows nothing about the others.
///
/// Dependency order matters for Typst's single-pass evaluation:
///   construct-sender must be defined before construct-header, because
///   construct-header calls construct-sender internally.
///   All other functions are independent of each other.
///
/// A note on Typst layout primitives used throughout:
///
///   context { ... }
///     Opens a layout-aware scope. Required any time code reads page.margin,
///     page.width, par.spacing, or calls measure(). These values are only
///     available after Typst has resolved the document geometry.
///
///   layout(_ => { ... })
///     Resolves page.width to a concrete pt length. Without this wrapper,
///     page.width has type "relative" rather than "length", so arithmetic
///     like `page.width - left-m` would produce a type error. layout() is
///     nested inside context{} so that both page geometry and margin values
///     are available simultaneously.
///
///   place(top + left, dx: ..., dy: ..., content)
///     Positions content absolutely relative to the current insertion point
///     without consuming vertical space in the normal flow. Using negative
///     dx/dy values escapes the margin box and reaches the physical page edge.
///     A subsequent v() is always required to push the flow cursor past the
///     placed content.
///
///   measure(content)
///     Returns the natural (width, height) of content without rendering it.
///     Must be called inside context{} or layout().

// =============================================================================
// LETTERHEAD AND SENDER HEADER
// =============================================================================

/// Places the letterhead image on page 1 using absolute positioning so it can
/// bleed to (or inset from) the physical page edges, independent of the normal
/// margin box.
///
/// Three layout modes are selected by letterhead.sender-position:
///
///   left / right  — Side-by-side: image and sender are placed absolutely so
///                   the image touches the page edge while the sender occupies
///                   the remaining column. sender-valign controls where the
///                   sender sits vertically within the image height.
///
///   center        — Stacked: image placed flush and centered; sender placed
///                   absolutely below it, also centered. bottom-gap controls
///                   the spacing between the sender and the letter content.
///
///   none (default) — Full-width: image placed flush to the physical edges;
///                   sender rendered separately in the normal flow below it.
///
/// In all three modes a v() is emitted after the placed content to advance the
/// flow cursor to the correct position for the next element (date or sender).
///
/// - letterhead (none or dictionary): Letterhead configuration. Keys:
///   - file (bytes, required): Raw bytes from read("path", encoding: none).
///   - width (auto, length, ratio, or relative, optional): Image width.
///     Defaults to auto, filling the full page width minus image-inset.
///   - height (length, optional): Image height. Omit to scale proportionally.
///   - image-inset (length or dictionary, optional): Inset from the physical
///     page edge. Accepts shorthand keys: top, bottom, left, right, x, y, rest.
///     Defaults to 0pt on all sides.
///   - image-alignment (alignment, optional): left, center, or right. Only
///     used by the full-width (default) layout. Defaults to center.
///   - sender-position (alignment, optional): left, center, or right. Selects
///     the layout mode described above.
///   - sender-valign (alignment, optional): top, horizon, or bottom. Controls
///     the vertical position of the sender column in left/right layouts.
///     Defaults to horizon (vertically centred against the image).
///   - bottom-gap (length, optional): Extra space between the sender and the
///     letter content in center layout. Defaults to par.spacing.
/// - sender-content (none or content): Pre-built sender block. Passed in by
///   construct-header when sender-position is set; none otherwise.
/// -> content
#let construct-letterhead(letterhead: none, sender-content: none) = {
  if letterhead != none {
    // context{} is required to read page.margin and par.spacing, which are
    // only resolved after Typst has processed the surrounding set rules.
    context {
      let m = page.margin
      let ps = par.spacing

      // When margins are left at auto, Typst uses 2.5/21 of the shorter page
      // dimension (≈ 2.5 cm for A4, ≈ 2.57 cm for US Letter). Replicating
      // this formula here lets us compute accurate dx/dy offsets even when
      // the user never set an explicit margin.
      let default-m = 2.5 / 21 * calc.min(page.width, page.height)

      // Unpack each side individually. page.margin can be auto, a single
      // length (uniform), or a dictionary (per-side). The three-way ternary
      // covers all cases and yields a plain length for each side.
      let top-m   = if m == auto { default-m } else if type(m) == dictionary { m.top   } else { m }
      let left-m  = if m == auto { default-m } else if type(m) == dictionary { m.left  } else { m }
      let right-m = if m == auto { default-m } else if type(m) == dictionary { m.right } else { m }

      // Unpack the letterhead dictionary into named locals for readability.
      let lh-image         = letterhead.file
      let lh-width         = letterhead.at("width",          default: auto)
      let lh-height        = letterhead.at("height",         default: auto)
      let lh-margin        = letterhead.at("image-inset",    default: none)
      let lh-alignment     = letterhead.at("image-alignment", default: center)
      let lh-sender-pos    = letterhead.at("sender-position", default: none)
      let lh-sender-valign = letterhead.at("sender-valign",   default: horizon)
      let lh-gap           = letterhead.at("bottom-gap",      default: none)

      // Normalise image-inset into a four-side dictionary (lhm) regardless of
      // how it was supplied. The resolution order for each side is:
      //   explicit side key  →  axis shorthand (x / y)  →  rest  →  0pt
      // This mirrors the same shorthand logic used for page margins in Typst.
      let lhm = if lh-margin == none {
        (top: 0pt, bottom: 0pt, left: 0pt, right: 0pt)
      } else if type(lh-margin) == length {
        // Single length: apply uniformly to all four sides
        (top: lh-margin, bottom: lh-margin, left: lh-margin, right: lh-margin)
      } else {
        // Dictionary: resolve each side with the shorthand fallback chain
        let fallback = lh-margin.at("rest", default: 0pt)
        (
          top:    lh-margin.at("top",    default: lh-margin.at("y", default: fallback)),
          bottom: lh-margin.at("bottom", default: lh-margin.at("y", default: fallback)),
          left:   lh-margin.at("left",   default: lh-margin.at("x", default: fallback)),
          right:  lh-margin.at("right",  default: lh-margin.at("x", default: fallback)),
        )
      }

      // layout() resolves page.width from a relative type to a plain pt length,
      // making arithmetic with lhm values (which are already plain lengths) safe.
      layout(_ => {
        // Drawable width after removing the letterhead's own left and right insets.
        // This is the span within which the image width is interpreted.
        let available = page.width - lhm.left - lhm.right

        // bottom-gap: the space between the bottom of the center-layout header
        // block and the first flow element (date / recipient). Defaults to
        // par.spacing so the visual rhythm stays consistent with the rest of
        // the letter. Only consumed by the center branch.
        let gap = if lh-gap == none { ps } else { lh-gap }

        // Resolve the user's width spec to a concrete pt length.
        //   auto     → full available width (image spans the drawable zone)
        //   ratio    → percentage of available (e.g. 60% → 0.6 * available)
        //   relative → mixed ratio + length (e.g. 50% + 5mm)
        //   length   → use as-is
        let img-width = if lh-width == auto {
          available
        } else if type(lh-width) == ratio {
          lh-width * available
        } else if type(lh-width) == relative {
          lh-width.ratio * available + lh-width.length
        } else {
          lh-width
        }

        // =====================================================================
        // BRANCH A — SIDE-BY-SIDE (sender-position: left or right)
        //
        // The image is placed absolutely so it bleeds to the physical page edge
        // on its side, while the sender occupies the remaining content-area
        // column at the same vertical position. Both are placed with place()
        // so neither consumes flow space; a single v(advance) at the end moves
        // the cursor past both.
        //
        // All dx values are measured from the content-area left edge (the
        // default origin of place()).
        // =====================================================================
        if lh-sender-pos in (left, right) {
          // Build the image element once; reuse for both measuring and placing.
          let lh-img = if lh-height == auto {
            image(lh-image, width: img-width)
          } else {
            image(lh-image, width: img-width, height: lh-height)
          }

          // Measure the rendered image height so we know how far the column
          // extends and can compute the advance v() at the end.
          let lh-img-height = measure(lh-img).height

          // Compute the horizontal offsets and sender column width.
          // For sender-position: right — image is flush to the physical left
          //   edge (dx = -left-m + lhm.left shifts past the page margin, then
          //   back in by the letterhead's own left inset); sender fills the
          //   remaining space to the right of the image.
          // For sender-position: left — image is flush to the physical right
          //   edge; sender fills the space to the left of the image, starting
          //   at dx = 0 (the content-area left edge).
          let (image-dx, sender-dx, sender-width) = if lh-sender-pos == right {
            let idx = -left-m + lhm.left
            // sender starts after the image; clamp to 0pt in case image-inset
            // pushes the image partly behind the margin
            let sdx = calc.max(0pt, lhm.left + img-width - left-m)
            // sender fills everything between its left edge and the right margin
            let sw = page.width - left-m - right-m - sdx
            (idx, sdx, sw)
          } else {
            // image flush-right: dx from content-area left to where image starts
            let idx = page.width - left-m - lhm.right - img-width
            let sdx = 0pt
            // sender column width is exactly the gap between the content-area
            // left edge and the image's left edge
            let sw = calc.max(0pt, idx)
            (idx, sdx, sw)
          }

          // Place the image absolutely. dy = -top-m + lhm.top moves up past the
          // page margin to the physical top edge, then back down by lhm.top.
          place(top + left, dx: image-dx, dy: -top-m + lhm.top, lh-img)

          // Measure the sender block before placing it. measure() is pure (does
          // not emit content), so it is safe to call before the place() below.
          // sender-width > 0pt guards against degenerate layouts where the image
          // occupies the full page width and leaves no room for the sender.
          let sender-height = if sender-content != none and sender-width > 0pt {
            measure(block(width: sender-width, sender-content)).height
          } else { 0pt }

          // Compute the vertical offset for the sender column based on
          // sender-valign, which aligns the sender relative to the image height.
          //   top     → sender top-edge aligned with image top-edge
          //   bottom  → sender bottom-edge aligned with image bottom-edge
          //   horizon → sender vertically centred within the image height
          // calc.max(0pt, ...) prevents a negative offset when the sender is
          // taller than the image.
          let sender-dy = if lh-sender-valign == top {
            -top-m + lhm.top
          } else if lh-sender-valign == bottom {
            -top-m + lhm.top + calc.max(0pt, lh-img-height - sender-height)
          } else {
            // horizon (default): split the surplus evenly above and below
            -top-m + lhm.top + calc.max(0pt, lh-img-height - sender-height) / 2
          }

          // Place the sender absolutely at its computed position.
          // Kept as a separate statement from the arithmetic above so that
          // content emission (place) is never mixed with pure computation.
          if sender-content != none and sender-width > 0pt {
            place(top + left, dx: sender-dx, dy: sender-dy, block(width: sender-width, sender-content))
          }

          // Advance the flow cursor past the taller of the two placed blocks.
          // advance is the distance from the content-area top edge to the
          // bottom of whichever block is taller, plus lhm.bottom padding.
          // Subtracting ps cancels the par.spacing that Typst would normally
          // insert between this block and the next element in the flow.
          let advance = calc.max(lh-img-height, sender-height) + lhm.top + lhm.bottom - top-m
          v(if advance > 0pt { advance - ps } else { -ps })

        // =====================================================================
        // BRANCH B — SENDER CENTERED BELOW (sender-position: center)
        //
        // Image placed flush and horizontally centered. Sender placed absolutely
        // directly below the image, also centered across the full content width.
        // A single v() covering both pushes the letter content (date, recipient)
        // below the combined header unit.
        // =====================================================================
        } else if lh-sender-pos == center {
          let lh-img = if lh-height == auto {
            image(lh-image, width: img-width)
          } else {
            image(lh-image, width: img-width, height: lh-height)
          }

          let lh-img-height = measure(lh-img).height

          // Center the image horizontally within the drawable zone.
          // dx = -left-m + lhm.left positions at the inset left edge;
          // + (available - img-width) / 2 adds the centering offset.
          let dx = -left-m + lhm.left + (available - img-width) / 2
          place(top + left, dx: dx, dy: -top-m + lhm.top, lh-img)

          // Sender spans the full content-area width (ignoring image-inset)
          // so it is centered relative to the text column, not the image.
          let cw = page.width - left-m - right-m
          let sender-height = if sender-content != none {
            measure(block(width: cw, sender-content)).height
          } else { 0pt }

          if sender-content != none {
            // dy positions the sender block immediately below the image's
            // bottom edge (image top offset + image height + bottom inset).
            place(top + left, dx: 0pt, dy: -top-m + lhm.top + lh-img-height + lhm.bottom, block(width: cw, sender-content))
          }

          // advance covers: top inset + image height + bottom inset + sender
          // height + bottom-gap. gap.to-absolute() converts em units to pt.
          let advance = lh-img-height + lhm.top + lhm.bottom + sender-height + gap.to-absolute() - top-m
          v(if advance > 0pt { advance - ps } else { -ps })

        // =====================================================================
        // BRANCH C — FULL-WIDTH / DEFAULT (sender-position absent)
        //
        // Image placed flush with the physical page edges; sender follows in
        // the normal document flow below. image-alignment controls where a
        // partial-width image sits within the drawable zone.
        // =====================================================================
        } else {
          let lh-img = if lh-height == auto {
            image(lh-image, width: img-width)
          } else {
            image(lh-image, width: img-width, height: lh-height)
          }

          let lh-img-height = measure(lh-img).height

          // Compute dx for the three horizontal alignment options.
          // In all cases: -left-m + lhm.left moves from the content-area origin
          // to the inset left edge. The alignment term then shifts within the
          // remaining drawable span.
          let dx = if lh-alignment == center {
            -left-m + lhm.left + (available - img-width) / 2
          } else if lh-alignment == right {
            -left-m + lhm.left + available - img-width
          } else {
            -left-m + lhm.left  // left-aligned: no additional shift
          }

          place(top + left, dx: dx, dy: -top-m + lhm.top, lh-img)

          // advance = how far the letterhead extends below the content-area
          // top edge (physical image height + insets - top margin already
          // consumed by dy). When advance <= 0pt the image fits within the
          // margin and we only need to cancel par.spacing.
          let advance = lh-img-height + lhm.top + lhm.bottom - top-m
          v(if advance > 0pt { advance - ps } else { -ps })
        }
      })
    }
  }
}

// =============================================================================
// LETTER OPENING — SENDER, DATE, RECIPIENT, SALUTATION, SUBJECT
// =============================================================================

/// Constructs the sender name and address block.
///
/// The outer align() positions the whole block on the page. Inside, text
/// alignment is reset to left (or center for a centered sender) so that
/// multi-line addresses always read in the natural direction within the block,
/// regardless of where the block sits on the page.
///
/// A linebreak() rather than a paragraph break is inserted between name and
/// address so the two lines share a single block with no extra inter-paragraph
/// spacing between them.
///
/// - from-name (none, str, or content): Sender's name.
/// - from-address (none, str, or content): Sender's address.
/// - from-alignment (alignment): Horizontal alignment of the block on the page.
/// -> content
#let construct-sender(from-name: none, from-address: none, from-alignment: right) = {
  // Suppress the block entirely when neither name nor address is provided.
  if from-name != none or from-address != none {
    align(from-alignment, block[
      // Reset inner text alignment: center stays center; left and right both
      // use left internally so address lines don't right-justify within the block.
      #set align(if from-alignment == center { center } else { left })
      #if from-name != none {
        from-name
        // Only insert a line break between name and address when both are
        // present; omitting it avoids a spurious blank line.
        if from-address != none { linebreak() }
      }
      #if from-address != none { from-address }
    ])
  }
}

/// Orchestrates the page-1 header: decides whether the sender lives inside
/// the letterhead zone or flows below it, builds the sender block once, and
/// delegates rendering to construct-letterhead and construct-sender.
///
/// This function is the single call site for both letterhead placement and
/// sender rendering. It guarantees that exactly one sender block is produced
/// regardless of layout mode — never zero (missing address), never two
/// (address appearing both inside the letterhead and again below it).
///
/// Effective alignment for the embedded sender column:
///   sender-position: left   → force left alignment. The default from-alignment
///                              is right; leaving it as-is would push the sender
///                              text to the right edge of its column, which sits
///                              immediately beside the logo — visually cramped.
///   sender-position: center → force center; address sits centered below the logo.
///   sender-position: right  → use from-alignment as given. The sender column is
///                              on the right side of the page, so right-alignment
///                              (the default) produces the classic flush-right
///                              Cambridge-style sender position.
///
/// - letterhead (none or dictionary): Letterhead configuration dictionary.
/// - from-name (none, str, or content): Sender's name.
/// - from-address (none, str, or content): Sender's address.
/// - from-alignment (alignment): Alignment for the standalone (non-embedded) sender.
/// -> content
#let construct-header(
  letterhead: none,
  from-name: none,
  from-address: none,
  from-alignment: right,
) = {
  // Read sender-position once; used both to choose the branch and to derive
  // effective-alignment. Returns none when the key is absent or letterhead
  // itself is none, selecting the default full-width layout.
  let lh-sender-pos = if letterhead != none { letterhead.at("sender-position", default: none) } else { none }

  if lh-sender-pos != none {
    // Sender is embedded in the letterhead zone. Build it first (pure content,
    // not yet emitted) so it can be passed into construct-letterhead as a
    // pre-measured block.
    let effective-alignment = if lh-sender-pos == left   { left   }
                              else if lh-sender-pos == center { center }
                              else                            { from-alignment }
    let sender-c = construct-sender(
      from-name: from-name,
      from-address: from-address,
      from-alignment: effective-alignment,
    )
    // construct-letterhead places both the image and the sender block
    // absolutely; the normal-flow sender call below is intentionally omitted.
    construct-letterhead(letterhead: letterhead, sender-content: sender-c)
  } else {
    // No sender-position: image placed flush (or nothing if no letterhead),
    // then sender emitted into the normal flow below the image.
    construct-letterhead(letterhead: letterhead)
    construct-sender(from-name: from-name, from-address: from-address, from-alignment: from-alignment)
  }
}

/// Constructs the date block, optionally width-matched to the sender block.
///
/// Width matching: when date-alignment equals from-alignment and a sender is
/// present, the date block is constrained to the measured width of the sender
/// block. This aligns the left edge of the date with the left edge of the
/// sender, which is the expected appearance in right-aligned layouts where
/// both the date and the sender sit in a column on the right.
///
/// The sender block is reconstructed purely for measurement — it is not
/// rendered here. This avoids a shared mutable state dependency between
/// construct-sender and construct-date.
///
/// When sender-position is center, lib.typ passes none for from-name and
/// from-address. This disables width matching so the date aligns freely,
/// which is correct because the sender is placed inside the letterhead zone
/// and is not part of the normal flow.
///
/// - date (none, str, or content): The letter date.
/// - date-alignment (alignment): Horizontal alignment of the date.
/// - from-alignment (alignment): Alignment used by the sender block.
/// - from-name (none, str, or content): Sender name — used for width matching only.
/// - from-address (none, str, or content): Sender address — used for width matching only.
/// -> content
#let construct-date(
  date: none,
  date-alignment: right,
  from-alignment: right,
  from-name: none,
  from-address: none,
) = {
  if date != none {
    if date-alignment == from-alignment and (from-name != none or from-address != none) {
      // context{} is required to call measure() at layout time
      context {
        // Reconstruct the sender content for measurement only. The result is
        // never placed on the page — it is used solely to obtain a width so
        // the date block can be sized to match.
        let from-content = if from-name != none and from-address != none {
          block[#from-name #linebreak() #from-address]
        } else if from-name != none {
          block[#from-name]
        } else {
          block[#from-address]
        }
        let from-width = measure(from-content).width

        // Constrain the date block to the sender width. The v(0.2em) inside
        // adds a small visual gap between the top of the block and the date
        // text, separating it from the sender block above.
        align(date-alignment, block(width: from-width)[
          #set align(if date-alignment == center { center } else { left })
          #v(0.2em)
          #date
        ])
      }
    } else {
      // Alignments differ: no width matching needed. Render the date block
      // free-floating at the requested alignment.
      align(date-alignment, block[
        #set align(if date-alignment == center { center } else { left })
        #v(0.2em)
        #date
      ])
    }
  }
}

/// Constructs the recipient block with name, address, and optional attention line.
///
/// The attention line can appear either above the name/address ("above") or
/// below it ("below"). In both cases it is assembled as a plain string
/// (label + space + name) so it renders as a single uninterrupted line.
///
/// v(0.5em) at the top of the block provides a consistent visual gap between
/// the date and the recipient regardless of whether an attention line is present.
/// All content inside the block is forced left-aligned because recipient
/// addresses are always left-aligned in business correspondence, regardless of
/// the page layout chosen for the sender and date.
///
/// - to-name (none, str, or content): Recipient's name.
/// - to-address (none, str, or content): Recipient's address.
/// - attn-name (none, str, or content): Attention recipient name.
/// - attn-label (str or content): Label prepended to the attention name.
/// - attn-position (str): "above" places the line before the name; "below" after.
/// -> content
#let construct-recipient(
  to-name: none,
  to-address: none,
  attn-name: none,
  attn-label: "Attn:",
  attn-position: "above",
) = {
  // Pre-build the attention line as a string. When attn-name is absent this
  // is none, and all attn-related guards below evaluate to false cleanly.
  let attn = if attn-name != none { attn-label + " " + attn-name } else { none }

  if to-name != none or to-address != none or attn != none {
    block[
      #v(0.5em)
      #set align(left)
      // "above": print attention line, then name, then address
      #if attn-position == "above" and attn != none {
        text(attn)
        linebreak()
      }
      #if to-name != none {
        to-name
        // Only break after the name when there is more content to follow
        if to-address != none or (attn-position == "below" and attn != none) { linebreak() }
      }
      #if to-address != none {
        to-address
        // Only break after the address when the attention line follows it
        if attn-position == "below" and attn != none { linebreak() }
      }
      // "below": print attention line after the address
      #if attn-position == "below" and attn != none {
        text(attn)
      }
    ]
  }
}

/// Constructs the salutation line.
///
/// v(0.5em) before and after the salutation creates a visual breathing space
/// that separates it from the subject/recipient above and the letter body
/// below. The linebreak() after the salutation text ends the line within the
/// same paragraph context without introducing an inter-paragraph gap.
///
/// - salutation (none, str, or content): The opening greeting.
/// -> content
#let construct-salutation(salutation: none) = {
  if salutation != none {
    v(0.5em)
    text(salutation)
    linebreak()
    v(0.5em)
  }
}

/// Constructs the subject line.
///
/// The subject is rendered as-is with no additional spacing; vertical rhythm
/// is provided by the paragraph spacing set in lib.typ. Callers are responsible
/// for applying any desired styling (e.g. bold, smallcaps) via the content block.
///
/// - subject (none, str, or content): The letter subject.
/// -> content
#let construct-subject(subject: none) = {
  if subject != none {
    text(subject)
  }
}

// =============================================================================
// LETTER CLOSING — CLOSING PHRASE, SIGNATURES, CC, ENCLOSURES
// =============================================================================

/// Constructs the closing phrase.
///
/// v(0.5em) above the closing creates a small visual gap that separates it
/// from the last line of the letter body.
///
/// - closing (none, str, or content): The closing phrase (e.g. "Sincerely yours,").
/// -> content
#let construct-closing(closing: none) = {
  if closing != none {
    v(0.5em)
    text(closing)
  }
}

/// Constructs a signature grid layout for one or more signatories.
///
/// Layout algorithm:
///
///   1. MEASUREMENT — For each signatory, measure the natural width of the
///      widest text line (name or affiliation) and the width of the signature
///      image. The column width used for bin-packing is the larger of the two,
///      ensuring image-wide signatures are not underestimated.
///
///   2. BIN-PACKING — Signatures are placed greedily into rows of up to three
///      columns. A new signature is added to the current row when:
///        (a) the row has fewer than three entries, AND
///        (b) current-row-width + col-gutter + new-width ≤ available × 1.05
///      The 5% tolerance compensates for leading whitespace that measure()
///      includes in content-block widths, which slightly inflates the measured
///      value and would otherwise cause signatures to wrap one line too early.
///      When neither condition holds, the current row is flushed and a new row
///      begins. A signature that is wider than the full available width always
///      occupies its own row (condition (a) still allows it as the first entry).
///
///   3. RENDERING — Each packed row becomes an inner grid whose column widths
///      are the measured col-actual-widths for that row's members. Within each
///      cell, signature image (or blank placeholder) and text items are stacked
///      vertically. The image box height is uniform across all cells in the row
///      (max-img-height) so name baselines align regardless of image presence.
///
/// signature-alignment applies only to single-signature rows. Multi-signature
/// rows are always left-aligned.
///
/// - signatures (none or array): One or more signatory dictionaries. Returns
///   immediately when none, following the same guard pattern as other functions.
/// - signature-alignment (alignment): Alignment for single-signature rows.
/// -> content
#let construct-signatures(signatures: none, signature-alignment: left) = {
  // Guard: nothing to render when signatures is absent. Matches the pattern
  // used by all other construct-* functions.
  if signatures == none { return }

  // Fixed gutter between adjacent signature columns (in pt, not em, so it
  // does not scale with font size and remains predictable for layout maths).
  let col-gutter = 40pt

  // Normalize a bare dictionary (single signatory) to a one-element array so
  // the rest of the function can always iterate uniformly.
  if type(signatures) != array {
    signatures = (signatures,)
  }

  // context{} + layout() give access to page.margin and a concrete page.width
  // respectively, both required for computing the available content width.
  context {
    let m = page.margin
    let default-m = 2.5 / 21 * calc.min(page.width, page.height)
    let left-m  = if m == auto { default-m } else if type(m) == dictionary { m.left  } else { m }
    let right-m = if m == auto { default-m } else if type(m) == dictionary { m.right } else { m }

    layout(_ => {
      // Full width of the text column — the space available for all signature
      // columns and the gutters between them.
      let available = page.width - left-m - right-m

      // STEP 1 — Measure each signature's natural text width.
      // [#item] wraps both str and content in a content block so measure()
      // handles them uniformly. The width is the max across name and affiliation
      // so the column is always wide enough to display both without wrapping.
      let sig-widths = signatures.map(sig => {
        let items = (sig.name,)
        let affiliation = sig.at("affiliation", default: none)
        if affiliation != none { items.push(affiliation) }
        items.map(item => measure([#item]).width).fold(0pt, calc.max)
      })

      // Also measure signature image widths. The default placeholder is a
      // transparent rect with a fixed height; measure() returns its natural
      // width (0pt for a rect with no explicit width, so the image wins when
      // present).
      let img-widths = signatures.map(sig => {
        let sig-content = sig.at("signature", default: rect(height: 40pt, stroke: none))
        measure(sig-content).width
      })

      // Column width for bin-packing = max(text width, image width). This
      // prevents the algorithm from packing a row that looks feasible based
      // on text alone but would overflow once the wider signature image is
      // rendered inside the column.
      let col-actual-widths = sig-widths.zip(img-widths).map(((tw, iw)) => calc.max(tw, iw))

      // STEP 2 — Greedy bin-packing.
      let rows = ()
      let current-row = ()
      let current-width = 0pt

      for (sig, w) in signatures.zip(col-actual-widths) {
        if current-row.len() == 0 {
          // Always start a new row with the first signature unconditionally,
          // even if it is wider than available (it will occupy its own row).
          current-row.push(sig)
          current-width = w
        } else if current-row.len() < 3 and current-width + col-gutter + w <= available * 1.05 {
          // Fits within the row under the 5% tolerance: append.
          current-row.push(sig)
          current-width = current-width + col-gutter + w
        } else {
          // Does not fit: commit the current row and begin a new one.
          rows.push(current-row)
          current-row = (sig,)
          current-width = w
        }
      }
      // Commit the final row (the loop above only flushes on overflow, so
      // the last in-progress row is never pushed inside the loop).
      if current-row.len() > 0 { rows.push(current-row) }

      // STEP 3 — Render each row as a nested grid.
      // The outer grid has one column and one row per packed signature row,
      // with 1em vertical spacing between rows.
      grid(
        columns: 1,
        rows: auto,
        row-gutter: 1em,
        align: left,
        ..rows.map(row => {
          let n = row.len()

          // Look up each signatory's pre-measured column width by position.
          // This preserves the text+image max already computed above rather
          // than re-measuring inside the render loop.
          let row-col-widths = row.map(sig => {
            let idx = signatures.position(s => s.name == sig.name)
            col-actual-widths.at(idx)
          })

          // Uniform image-box height for all cells in this row. Every cell's
          // signature box is sized to max-img-height so that when images
          // differ in height (or some cells have a placeholder), the name
          // baseline is the same vertical distance from the top of the cell
          // across all columns in the row.
          let max-img-height = row.map(sig => {
            let sig-content = sig.at("signature", default: rect(height: 40pt, stroke: none))
            measure(sig-content).height
          }).fold(0pt, calc.max)

          grid(
            columns: row-col-widths,
            // top alignment prevents shorter cells (fewer affiliation lines)
            // from being vertically centred, which would create apparent
            // blank space above the name in mixed-height rows.
            // left alignment for multi-sig rows; signature-alignment for single.
            align: if n == 1 { signature-alignment + top } else { top + left },
            column-gutter: col-gutter,
            ..row.map(signatory => {
              let affiliation = signatory.at("affiliation", default: none)

              // Build text items: name first, then affiliation when present
              // and non-empty. Excluding absent affiliations avoids a blank
              // line between the name and the bottom of the cell.
              let text-items = (signatory.name,)
              if affiliation not in (none, "", []) { text-items.push(affiliation) }

              // Each cell: image box (uniform height) stacked above text items.
              // box(width: 100%) fills the measured column width, preventing
              // wide signature images from squeezing the column.
              stack(
                spacing: 1em,
                box(width: 100%, height: max-img-height, signatory.at("signature", default: rect(height: 40pt, stroke: none))),
                stack(spacing: 1em, ..text-items),
              )
            }),
          )
        })
      )
    })
  }
}

// =============================================================================
// POST-BODY ELEMENTS — CC, ENCLOSURES
// =============================================================================

/// Constructs a labelled list of carbon copy recipients.
///
/// A single recipient is normalised to a one-element array so the rendering
/// loop is always uniform. All recipients are rendered as undecorated list
/// items (marker: "") regardless of count, matching the conventional cc: style
/// in business letters where items are not bulleted or numbered.
///
/// - cc (none, str, content, or array): One or more cc recipients.
/// - cc-label (str or content): Label printed before the list.
/// -> content
#let construct-cc(cc: none, cc-label: "cc:") = {
  if cc != none {
    v(0.5em)  // Visual gap separating the cc block from the signatures above

    // Print the label ("cc:" by default) on its own line; items follow below
    cc-label

    // Normalize a bare string or content value to a one-element array
    if type(cc) != array {
      cc = (cc,)
    }

    // Render all recipients as undecorated list items. indent: 1.4em aligns
    // item text with the body text column rather than the left margin.
    set list(indent: 1.4em, marker: "")
    for cc-recipient in cc {
      list.item(text(cc-recipient))
    }
  }
}

/// Constructs the enclosure list and embeds any attached files as appended pages.
///
/// Two separate concerns are handled in sequence:
///
///   1. LISTING — The enclosure descriptions are printed as either a single
///      undecorated list item (one enclosure) or a numbered enumeration
///      (multiple enclosures), following standard business letter conventions.
///
///   2. EMBEDDING — For each enclosure that carries a file (bytes), the file
///      is rendered on its own dedicated page after the letter body. A scoped
///      set page rule applies the enclosure's page-inset so the embedded pages
///      use their own margin without affecting the letter pages. page-inset is
///      expanded from shorthand to a fully-specified per-side dictionary before
///      being passed to set page, which prevents unspecified sides from
///      inheriting the letter's own margins.
///
/// - enclosures (none or array): One or more enclosure dictionaries.
/// - enclosures-label (str or content): Label printed before the list.
/// -> content
#let construct-enclosures(enclosures: none, enclosures-label: "encl:") = {
  if enclosures != none {
    // Hoist the enum indent setting into this block's scope so it applies
    // to all enum.item() calls below without repeating the set rule per item.
    set enum(indent: 1.4em)

    v(0.5em)  // Visual gap separating enclosures from the cc section above
    enclosures-label

    // Normalize a bare dictionary to a one-element array
    if type(enclosures) != array {
      enclosures = (enclosures,)
    }

    // Render the description list. One enclosure uses an undecorated list item
    // (no number, no bullet); multiple enclosures use a numbered enumeration.
    if enclosures.len() == 1 {
      set list(indent: 1.4em, marker: "")
      list.item(text(enclosures.first().description))
    } else {
      for enclosure in enclosures {
        enum.item(text(enclosure.description))
      }
    }

    // Embed attached files. Enclosures without a file key are silently skipped.
    for enclosure in enclosures {
      let file = enclosure.at("file", default: none)
      if file != none {
        let raw-margin = enclosure.at("page-inset", default: 0mm)

        // Expand page-inset shorthand to an explicit four-side dictionary.
        // This is required because a partial dictionary (e.g. (top: 5mm))
        // passed directly to set page would leave unspecified sides at their
        // current value, which would be the letter's margins rather than 0mm.
        let margin = if type(raw-margin) == dictionary {
          let fallback = raw-margin.at("rest", default: 0mm)
          (
            top:    raw-margin.at("top",    default: raw-margin.at("y", default: fallback)),
            bottom: raw-margin.at("bottom", default: raw-margin.at("y", default: fallback)),
            left:   raw-margin.at("left",   default: raw-margin.at("x", default: fallback)),
            right:  raw-margin.at("right",  default: raw-margin.at("x", default: fallback)),
          )
        } else { raw-margin }

        let page-count = enclosure.at("pages", default: 1)

        // The scoped block limits set page to this enclosure's pages only.
        // Without the braces, the margin override would propagate to all
        // subsequent pages including other enclosures and the letter itself.
        {
          set page(margin: margin)
          // Pages in Typst image() are 1-indexed. range(1, page-count + 1)
          // produces [1, 2, ..., page-count].
          for i in range(1, page-count + 1) {
            image(file, page: i, width: 100%)
            // Insert a page break between pages but not after the last one,
            // which would produce a blank page before the next enclosure.
            if i < page-count { pagebreak() }
          }
        }
      }
    }
  }
}

// =============================================================================
// FOOTER AND PAGE NUMBERING
// =============================================================================

/// Constructs the custom footer grid with styled hyperlinks.
///
/// Footer items are laid out in a single-row grid with equal-width columns and
/// a fixed 20pt gutter. URL and email items are wrapped in link() so the PDF
/// viewer renders them as clickable hyperlinks. Plain string items are rendered
/// as unlinked text.
///
/// An empty grid() placeholder is returned when footer is none or empty. This
/// keeps the footer area the same height regardless of whether a footer is
/// present, avoiding a layout shift for the page-numbering element that sits
/// beside it.
///
/// - footer (none or array): One or more footer element dictionaries.
/// - footer-font (str): Font family for all footer text.
/// - footer-font-size (length): Font size for all footer text.
/// - link-color (color): Fill color for hyperlinked items.
/// -> content
#let construct-custom-footer(
  footer: none,
  footer-font: "DejaVu Sans Mono",
  footer-font-size: 9pt,
  link-color: blue,
) = {
  if footer not in (none, ()) {
    if type(footer) != array {
      footer = (footer,)
    }

    grid(
      columns: footer.len(),
      rows: 1,
      gutter: 20pt,
      ..footer.map(footer-item => {
        let footer-type = footer-item.at("footer-type", default: "string")
        let footer-text = footer-item.at("footer-text")

        if footer-type == "url" {
          // link() with a single string argument uses the string as both the
          // href and the visible display text, which is correct for URLs.
          text(link(footer-text), font: footer-font, size: footer-font-size, fill: link-color)
        } else if footer-type == "email" {
          // Prepend mailto: so the OS routes a click to the default mail client
          text(link("mailto:" + footer-text), font: footer-font, size: footer-font-size, fill: link-color)
        } else {
          // Plain string: render without a hyperlink
          text(footer-text, font: footer-font, size: footer-font-size)
        }
      })
    )
  } else {
    // Empty placeholder: ensures the footer row always has a consistent height
    // so the page-numbering element is never shifted by the presence or absence
    // of a custom footer.
    grid()
  }
}

/// Constructs the page number, displayed from page 2 onwards.
///
/// Page 1 is suppressed because the letter heading already makes the first page
/// unambiguous. The number is rendered using Arabic numerals (display("1")).
///
/// An empty grid() placeholder is returned when number-pages is false, keeping
/// the footer layout identical to the numbered case.
///
/// - number-pages (bool): When true, page numbers are shown from page 2 onwards.
/// -> content
#let construct-page-numbering(number-pages: false) = {
  if number-pages {
    grid(
      context(
        if here().page() > 1 {
          // display("1") renders the counter in Arabic numerals (1, 2, 3 …).
          // here().page() is the physical page number at the point of rendering.
          counter(page).display("1")
        }
      )
    )
  } else {
    // Empty placeholder so the footer slot height is consistent regardless of
    // whether page numbering is enabled.
    grid()
  }
}
