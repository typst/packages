#import "@preview/cetz:0.4.2"
#import "ipa.typ": ipa

#let autoseg(
  segments,
  features: (),
  links: (),
  delinks: (),
  spacing: 1.5,
  arrow: false,
  tone: false,
  highlight: (),
  float: (),
  multilinks: (),
  baseline: 40%,
  gloss: "",
) = {
  box(inset: 1.2em, baseline: baseline, cetz.canvas({
    import cetz.draw: *

    // Coordinate positions depend on whether we're drawing tones or features
    let seg_y = if tone { 0 } else { 0.8 }
    let feat_y = if tone { 0.8 } else { 0 }
    let gloss_y = if tone { -0.8 } else { 1.6 }
    let seg_anchor_dir = if tone { "north" } else { "south" }
    let feat_anchor_dir = if tone { "south" } else { "north" }
    let gloss_anchor_dir = if tone { "north" } else { "south" }

    for (i, seg) in segments.enumerate() {
      let feat = features.at(i, default: "")
      let x = i * spacing

      // Check if this position is part of a multilink (skip normal drawing if so)
      let is_multilinked = multilinks.any(entry => {
        let tone_spec = entry.at(0)
        let tone_pos = if type(tone_spec) == array { tone_spec.at(0) } else { tone_spec }
        tone_pos == i
      })

      // Handle multiple tones/features as an array (for branching)
      let feat_array = if type(feat) == array { feat } else { (feat,) }
      let num_feats = feat_array.len()

      group(name: "n" + str(i), {
        // 3. Labels (segment)
        // Use horizon alignment to ensure consistent baseline across all segments
        content((x, seg_y), padding: 0.1, anchor: seg_anchor_dir, box(height: 1em, align(horizon, text(
          font: "Charis SIL",
          ipa(seg),
        ))))

        // Process each tone/feature (creates branching for multiple tones)
        // Skip if this position is multilinked (will be drawn by multilink code)
        for (j, f) in feat_array.enumerate() {
          if f != "" and not is_multilinked {
            // Calculate horizontal offset for multiple tones
            let x_offset = if num_feats > 1 { (j - (num_feats - 1) / 2) * 0.6 } else { 0 }
            let feat_x = x + x_offset

            // 1. Draw the vertical stem if not floating
            if i not in float {
              line((feat_x, feat_y), (x, seg_y), stroke: 0.05em, name: "stem" + str(j))
            }

            // 2. Feature/tone label with optional circle highlight
            // Check if this specific tone should be highlighted
            let should_highlight = i in highlight or (i, j) in highlight
            let box_stroke = if should_highlight { 0.05em + black } else { none }
            content((feat_x, feat_y), padding: 0.1, anchor: feat_anchor_dir, box(
              stroke: box_stroke,
              inset: 0.15em,
              radius: 100%,
              width: 1.2em,
              height: 1.2em,
              align(center + horizon, text(font: "Charis SIL", f)),
            ))

            // Create anchor for this specific tone (for sub-indexing in links)
            anchor("feat" + str(j), (feat_x, feat_y))
          }
        }

        // 3. Anchors for association lines (center position and segment)
        anchor("seg", (x, seg_y))
        anchor("feat", (x, feat_y))
      })
    }

    // 4. Draw the spreading links
    for (src, dest) in links {
      // Parse src and dest - can be int or (pos, sub) tuple for targeting specific tones
      let parse_index = idx => {
        if type(idx) == array {
          (pos: idx.at(0), sub: idx.at(1))
        } else {
          (pos: idx, sub: none)
        }
      }

      let src_parsed = parse_index(src)
      let dest_parsed = parse_index(dest)

      // Build anchor names with optional sub-index
      let get_anchor = (parsed, tier) => {
        let base = "n" + str(parsed.pos)
        if tier == "feat" and parsed.sub != none {
          base + ".feat" + str(parsed.sub)
        } else if tier == "feat" {
          base + ".feat"
        } else {
          base + ".seg"
        }
      }

      // Both modes: link from feature/tone[src] to segment[dest]
      let start_anchor = get_anchor(src_parsed, "feat")
      let end_anchor = get_anchor(dest_parsed, "seg")

      // Draw the main dashed line
      line(start_anchor, end_anchor, stroke: (dash: "dashed", thickness: 0.05em))

      if arrow {
        // Arrow points from feature/tone toward segment
        line(start_anchor, end_anchor, stroke: (thickness: 0em), mark: (end: "stealth"), fill: black)
      }
    }

    // 5. Draw multi-linked tones (shared tones positioned between segments)
    for entry in multilinks {
      let (tone_spec, seg_positions) = entry

      // Parse tone specification (can be index or (pos, sub))
      let tone_parsed = if type(tone_spec) == array {
        (pos: tone_spec.at(0), sub: tone_spec.at(1))
      } else {
        (pos: tone_spec, sub: none)
      }

      // Calculate midpoint position for the tone
      let min_seg = calc.min(..seg_positions)
      let max_seg = calc.max(..seg_positions)
      let mid_x = ((min_seg + max_seg) / 2) * spacing

      // Get the tone text
      let tone_feat = features.at(tone_parsed.pos, default: "")
      let tone_array = if type(tone_feat) == array { tone_feat } else { (tone_feat,) }
      let tone_text = if tone_parsed.sub != none {
        tone_array.at(tone_parsed.sub)
      } else {
        if type(tone_feat) == array { tone_feat.join(" ") } else { tone_feat }
      }

      // Draw the tone at midpoint
      let box_stroke = if tone_parsed.pos in highlight or (tone_parsed.pos, tone_parsed.sub) in highlight {
        0.05em + black
      } else {
        none
      }
      content((mid_x, feat_y), padding: 0.1, anchor: feat_anchor_dir, box(
        stroke: box_stroke,
        inset: 0.15em,
        radius: 100%,
        width: 1.2em,
        height: 1.2em,
        align(center + horizon, text(font: "Charis SIL", tone_text)),
      ))

      // Draw solid lines to each segment (no arrows, no dashes)
      for seg_pos in seg_positions {
        let seg_x = seg_pos * spacing
        line((mid_x, feat_y), (seg_x, seg_y), stroke: 0.05em)
      }
    }

    // 6. Draw delinks on association lines (drawn after multilinks to be on top)
    for (src, dest) in delinks {
      // Parse src and dest - can be int or (pos, sub) tuple
      let parse_index = idx => {
        if type(idx) == array {
          (pos: idx.at(0), sub: idx.at(1))
        } else {
          (pos: idx, sub: none)
        }
      }

      let src_parsed = parse_index(src)
      let dest_parsed = parse_index(dest)

      // Calculate dest position
      let dest_x = dest_parsed.pos * spacing

      // Check if source is multilinked
      let is_multilinked = multilinks.any(entry => {
        let tone_spec = entry.at(0)
        let tone_pos = if type(tone_spec) == array { tone_spec.at(0) } else { tone_spec }
        tone_pos == src_parsed.pos
      })

      let src_feat_x = if is_multilinked {
        // Find the multilink entry for this source
        let multilink_entry = multilinks.find(entry => {
          let tone_spec = entry.at(0)
          let tone_pos = if type(tone_spec) == array { tone_spec.at(0) } else { tone_spec }
          tone_pos == src_parsed.pos
        })
        let seg_positions = multilink_entry.at(1)
        let min_seg = calc.min(..seg_positions)
        let max_seg = calc.max(..seg_positions)
        ((min_seg + max_seg) / 2) * spacing
      } else {
        // Regular tone or branching tone
        let src_x = src_parsed.pos * spacing
        let src_feat = features.at(src_parsed.pos, default: "")
        let src_feat_array = if type(src_feat) == array { src_feat } else { (src_feat,) }
        let num_src_feats = src_feat_array.len()

        let src_x_offset = if num_src_feats > 1 and src_parsed.sub != none {
          (src_parsed.sub - (num_src_feats - 1) / 2) * 0.6
        } else {
          0
        }
        src_x + src_x_offset
      }

      // Calculate midpoint for delink marks
      let mid_x = (src_feat_x + dest_x) / 2
      let mid_y = (seg_y + feat_y) / 2

      // Draw the delink marks (two parallel lines perpendicular to the association line)
      // Calculate the direction vector and its perpendicular
      let dx = dest_x - src_feat_x
      let dy = seg_y - feat_y
      let length = calc.sqrt(dx * dx + dy * dy)

      // Normalized direction
      let dir_x = dx / length
      let dir_y = dy / length

      // Perpendicular direction (rotate 90 degrees)
      let perp_x = -dir_y
      let perp_y = dir_x

      let offset = 0.15
      let spacing_offset = 0.06

      // First delink line (closer to tone)
      let p1_start = (
        mid_x - offset * perp_x - spacing_offset * dir_x,
        mid_y - offset * perp_y - spacing_offset * dir_y,
      )
      let p1_end = (mid_x + offset * perp_x - spacing_offset * dir_x, mid_y + offset * perp_y - spacing_offset * dir_y)

      // Second delink line (closer to segment)
      let p2_start = (
        mid_x - offset * perp_x + spacing_offset * dir_x,
        mid_y - offset * perp_y + spacing_offset * dir_y,
      )
      let p2_end = (mid_x + offset * perp_x + spacing_offset * dir_x, mid_y + offset * perp_y + spacing_offset * dir_y)

      line(p1_start, p1_end, stroke: 0.05em)
      line(p2_start, p2_end, stroke: 0.05em)
    }

    // 7. Draw gloss (if provided)
    if gloss != "" and gloss != () {
      // Calculate center of the entire representation
      let center_x = ((segments.len() - 1) / 2) * spacing
      // Use fixed-height box to ensure consistent baseline alignment across autoseg instances
      content((center_x, gloss_y), padding: 0.1, anchor: gloss_anchor_dir, box(height: 1em, align(horizon, text(size: 0.9em, gloss))))
    }
  }))
}

