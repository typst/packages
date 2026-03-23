#set page(width: auto, height: auto, margin: 10pt)

#import "@preview/cetz:0.4.2": canvas, draw

// --- HELPER WRAPPER ---
// Handles the common logic of moving to a position and rotating
#let obj-wrapper(pos, rotation, body) = {
  draw.group({
    draw.translate(pos)
    draw.rotate(rotation)
    body
  })
}

// --- BED (Organic/Soft Style) ---
#let bed(pos, rotation: 0deg, scale: 1.0, size: "queen", fill: white) = {
  // Dimensions map
  let dims = (
    single: (w: 0.9, l: 2.0),
    double: (w: 1.4, l: 2.0),
    queen:  (w: 1.6, l: 2.0),
    king:   (w: 1.8, l: 2.0)
  )
  
  let (w, l) = dims.at(size, default: dims.queen)
  
  obj-wrapper(pos, rotation, {
    draw.scale(scale)
    
    // 1. THE MAIN FRAME (Outer Box)
    // Drawn with a slight radius so it's not "sharp"

        draw.rect((-w/1.9, -l/1.9), (w/1.9, l/1.6), stroke: 1pt, fill: fill, radius: 0.02)

    
    draw.rect((-w/2, -l/2), (w/2, l/1.63), stroke: 1pt, fill: fill, radius: 0.02)



    // 2. THE SHEET FOLD (The Wavy Band)
    // This separates the pillows from the rest of the bed
    let fold-y = l/4 + 0.1
    let fold-h = 0.35
    
    // We draw the "Fold" as a filled shape to cover the mattress lines
    draw.merge-path(close: true, fill: fill, stroke: 0.8pt, {
        // Top Wavy Line
        draw.bezier(
            (-w/2, fold-y), (w/2, fold-y), 
            (-w/4, fold-y + 0.05), (w/4, fold-y - 0.02)
        )
        // Right Side
        draw.line((w/2, fold-y), (w/2, fold-y - fold-h))
        // Bottom Wavy Line (Parallel-ish to top)
        draw.bezier(
            (w/2, fold-y - fold-h), (-w/2, fold-y - fold-h), 
            (w/4, fold-y - fold-h - 0.03), (-w/4, fold-y - fold-h + 0.03)
        )
        // Left Side
        draw.line((-w/2, fold-y - fold-h), (-w/2, fold-y))
    })

    // 3. THE PILLOWS (Soft & Organic)
    // Instead of rectangles, we use curves to make them look like soft fabric
    let p-h = 0.45 // Pillow Height
    let p-y = fold-y + 0.05 + p-h/2 + 0.05 // Position
    
    // Helper to draw a "Soft" Pillow
    let soft-pillow(x, y, pw) = {
       draw.group({
         draw.translate((x, y))
         // We draw 4 bezier curves to make a "squarish circle"
         // This removes the "sharp rectangle" look completely
         let h = p-h
         let w = pw
         draw.merge-path(close: true, fill: fill, stroke: 0.5pt, {
            // Top Edge (Curved down slightly)
            draw.bezier((-w/2, h/2), (w/2, h/2), (-w/4, h/2 - 0.02), (w/4, h/2 - 0.02))
            // Right Edge (Curved out)
            draw.bezier((w/2, h/2), (w/2, -h/2), (w/2 + 0.02, h/4), (w/2 + 0.02, -h/4))
            // Bottom Edge (Curved up)
            draw.bezier((w/2, -h/2), (-w/2, -h/2), (w/4, -h/2 + 0.02), (-w/4, -h/2 + 0.02))
            // Left Edge (Curved out)
            draw.bezier((-w/2, -h/2), (-w/2, h/2), (-w/2 - 0.02, -h/4), (-w/2 - 0.02, h/4))
         })
         
         // Optional: Tiny wrinkle line inside
         draw.bezier((-w/4, -h/4), (0, -h/4 + 0.05), (-w/8, -h/4 - 0.02), (-0.05, -h/4), stroke: 0.2pt)
       })
    }

    if w <= 1.0 {
       // Single Pillow
       soft-pillow(0, p-y, 0.7)
    } else {
       // Dual Pillows
       let p-gap = 0.05
       let p-w = (w / 2) - 0.15 - p-gap
       
       // Left Pillow
       soft-pillow(-p-w/2 - p-gap, p-y, p-w)
       // Right Pillow
       soft-pillow(p-w/2 + p-gap, p-y, p-w)
    }
    
    // 4. INNER FRAME DETAIL (Optional)
    // A thin line inside the bed frame (top half only) to show depth
    // We stop it at the sheet fold so it doesn't cross over
    let gap = 0.08
    draw.line((-w/2 + gap, l/2 - gap), (-w/2 + gap, fold-y + 0.05), stroke: 0.3pt) // Left inner
    draw.line((w/2 - gap, l/2 - gap), (w/2 - gap, fold-y + 0.05), stroke: 0.3pt)   // Right inner
    draw.line((-w/2 + gap, l/2 - gap), (w/2 - gap, l/2 - gap), stroke: 0.3pt)      // Top inner
  })
}

// --- 2. TOILET ---
// anchors centered on the bounding box for easier rotation
#let toilet(pos, rotation: 0deg, scale: 1.0) = {
  obj-wrapper(pos, rotation, {
    draw.scale(scale)
    // Tank
    draw.rect((-0.25, 0.2), (0.25, 0.45), fill: white)
    // Bowl
    draw.rect((-0.2, -0.25), (0.2, 0.2), fill: white, radius: 0.2) // Main body
    draw.circle((0, -0.05), radius: 0.15, stroke: 0.5pt) // Inner bowl
  })
}

// --- 3. WASHBASIN (Scaled) ---
// type: "oval" (default) or "rect"
#let washbasin(pos, rotation: 0deg, scale: 1.0, type: "oval") = {
  // Standard base dimensions (approx 60cm x 50cm)
  let w = 0.6
  let d = 0.5

  obj-wrapper(pos, rotation, {
    draw.scale(scale)

    // 1. Counter / Outer Rim
    // Drawn with white fill to cover floor lines
    draw.rect((-w/2, -d/2), (w/2, d/2), fill: white, radius: 0.05, stroke: 1pt)
    
    // 2. Basin Interior
    if type == "rect" {
       // Rectangular Sink
       draw.rect(
         (-w/2 + 0.05, -d/2 + 0.05), 
         (w/2 - 0.05, d/2 - 0.05), 
         radius: 0.05, stroke: 0.5pt
       )
    } else {
       // Oval Sink
       // We use a tuple for radius to create an ellipse
       draw.circle((0,0), radius: (w/2 - 0.05, d/2 - 0.05), stroke: 0.5pt)
    }
    
    // 3. Drain hole
    draw.circle((0, 0), radius: 0.03, fill: black)
    
    // 4. Faucet Details
    // Spout line
    draw.line((0, d/2 - 0.02), (0, d/2 - 0.15), stroke: 1.5pt)
    // Handle bar
    draw.line((-0.05, d/2 - 0.05), (0.05, d/2 - 0.05), stroke: 1.5pt)
  })
}

// --- 4. BATHTUB ---
#let bathtub(pos, rotation: 0deg, length: 1.7, width: 0.8) = {
  obj-wrapper(pos, rotation, {
    // Outer rim
    draw.rect((-length/2, -width/2), (length/2, width/2), fill: white, radius: 0.1)
    // Inner rim
    draw.rect((-length/2 + 0.1, -width/2 + 0.1), (length/2 - 0.1, width/2 - 0.1), radius: 0.2, stroke: 0.5pt)
    // Drain
    draw.circle((-length/2 + 0.25, 0), radius: 0.04)
  })
}

// --- 5. SOFA ---
// seats: number of cushions
#let sofa(pos, rotation: 0deg, width: 2.0, depth: 0.9, seats: 3) = {
  obj-wrapper(pos, rotation, {
    // Backrest
    draw.rect((-width/2, depth/2 - 0.2), (width/2, depth/2), fill: white)
    // Armrests
    draw.rect((-width/2, -depth/2), (-width/2 + 0.2, depth/2 - 0.2), fill: white)
    draw.rect((width/2 - 0.2, -depth/2), (width/2, depth/2 - 0.2), fill: white)
    
    // Cushions
    let seat-w = (width - 0.4) / seats
    let start-x = -width/2 + 0.2
    
    for i in range(seats) {
       draw.rect(
         (start-x + i*seat-w, -depth/2), 
         (start-x + (i+1)*seat-w, depth/2 - 0.25), 
         stroke: 0.5pt
       )
    }
  })
}


// --- 7. SKETCHY CAR (Matches your image style) ---
// Added 'scale' parameter (default 1.0)
#let sketchy-car(pos, rotation: 0deg, scale: 1.0, fill: white) = {
  obj-wrapper(pos, rotation, {
    
    // --- SCALING LOGIC ---
    // This shrinks/grows everything drawn below
    draw.scale(scale) 
    // ---------------------

    let dim = (l: 4.8, w: 2.0)
    
    // 1. WHEELS (Tucked underneath)
    let wx = 1.3
    let wy = 0.9
    let w-size = (0.7, 0.25)
    
    let wheel(x, y) = {
       draw.rect((x - w-size.at(0)/2, y - w-size.at(1)/2), 
    (x + w-size.at(0)/2, y + w-size.at(1)/2), 
    fill: black, radius: 0.05)
    }
    wheel(wx, wy)   // Front Left
    wheel(wx, -wy)  // Front Right
    wheel(-wx, wy)  // Rear Left
    wheel(-wx, -wy) // Rear Right

    // 2. MAIN BODY SHELL (Organic Shape)
    draw.group({
      draw.merge-path(close: true, fill: fill, stroke: 1pt, {
        draw.bezier((-2.3, 0.8), (-2.3, -0.8), (-2.5, 0.4), (-2.5, -0.4))
        draw.bezier((-2.3, -0.8), (2.2, -0.8), (-1.0, -1.05), (1.0, -1.05))
        draw.bezier((2.2, -0.8), (2.2, 0.8), (2.4, -0.4), (2.4, 0.4))
        draw.bezier((2.2, 0.8), (-2.3, 0.8), (1.0, 1.05), (-1.0, 1.05))
      })

      // 3. THE CABIN / ROOF
      let roof-start = -1.4
      let roof-end = 0.5
      let roof-w = 0.75
      
      draw.rect((roof-start, -roof-w), (roof-end, roof-w), radius: 0.2, stroke: 1pt,)

      // 4. WINDSHIELD
      draw.line((roof-end, roof-w - 0.05), (1.1, 0.65), stroke: 0.5pt)
      draw.line((roof-end, -roof-w + 0.05), (1.1, -0.65), stroke: 0.5pt)
      draw.bezier((1.1, 0.65), (1.1, -0.65), (1.35, 0.3), (1.35, -0.3), stroke: 0.5pt)
      
      // 5. REAR WINDOW
      draw.line((roof-start, roof-w - 0.05), (-1.8, 0.6), stroke: 0.5pt)
      draw.line((roof-start, -roof-w + 0.05), (-1.8, -0.6), stroke: 0.5pt)
      draw.bezier((-1.8, 0.6), (-1.8, -0.6), (-2.0, 0.3), (-2.0, -0.3), stroke: 0.5pt)

      // 6. HOOD DETAILS
      draw.bezier((1.1, 0.65), (2.2, 0.4), (1.5, 0.6), (1.8, 0.45), stroke: 0.5pt)
      draw.bezier((1.1, -0.65), (2.2, -0.4), (1.5, -0.6), (1.8, -0.45), stroke: 0.5pt)
      draw.rect((2.35, -0.3), (2.4, 0.3), fill: white, radius: 0.05)

      // 7. SIDE MIRRORS (Your Updated Code)
      let mx = 0.7
      let my = 0.9
      draw.group({
         draw.translate((mx, my))
         draw.rotate(140deg)
         draw.rect((0,0), (0.3, 0.15), radius: 0.05, fill: fill, stroke: 1pt)
      })
      draw.group({
         draw.translate((mx, -my))
         draw.rotate(-140deg)
         draw.rect((0,0), (0.3, -0.15), radius: 0.05, fill: fill, stroke: 1pt)
      })

      // 8. REFLECTION LINES
      draw.line((-1.6, 0.3), (-1.8, 0.5), stroke: (thickness: 0.3pt))
      draw.line((-1.65, 0.1), (-1.85, 0.3), stroke: (thickness: 0.3pt))
      draw.line((1.15, -0.2), (1.25, 0.0), stroke: (thickness: 0.3pt))
      
      // 9. B-PILLAR
      draw.line((-0.4, roof-w), (-0.4, 0.95), stroke: 1.5pt)
      draw.line((-0.4, -roof-w), (-0.4, -0.95), stroke: 1.5pt)
      draw.content((1.7,0), [#text(size: 0.8em)[_CAR_]])
    })
  })
}


// --- 9. PRO DINING TABLE (Scaled with Label) ---
#let dining-table(
  pos, 
  rotation: 0deg, 
  scale: 1.0, 
  size: (2.0, 1.0), 
  chairs: 6,
  label: none // New parameter for text
) = {
  obj-wrapper(pos, rotation, {
    draw.scale(scale) 

    let (w, d) = size
    let cw = 0.45  
    let cd = 0.50  
    let rim = 0.06 
    let tuck = 0.20 
    let visible-depth = cd - tuck

    // Helper: Draw ONE Chair
    let draw-chair(x, y, r) = {
      draw.group({
        draw.translate((x, y))
        draw.rotate(r)
        draw.rect((-cw/2 + 0.02, -cd/2), (cw/2 - 0.02, 0), fill: white, stroke: 0.5pt)
        draw.merge-path(close: true, fill: white, stroke: 0.8pt, {
          draw.line((-cw/2, 0), (-cw/2, visible-depth)) 
          draw.bezier((-cw/2, visible-depth), (cw/2, visible-depth), (-cw/4, visible-depth + 0.1), (cw/4, visible-depth + 0.1))
          draw.line((cw/2, visible-depth), (cw/2, 0))    
          draw.line((cw/2, 0), (-cw/2, 0))               
        })
        draw.bezier(
          (-cw/2 + rim, visible-depth - 0.02), 
          (cw/2 - rim, visible-depth - 0.02), 
          (-cw/4, visible-depth + 0.06), 
          (cw/4, visible-depth + 0.06), 
          stroke: 0.5pt
        )
        draw.line((-cw/2 + rim, 0), (-cw/2 + rim, visible-depth - 0.02), stroke: 0.5pt)
        draw.line((cw/2 - rim, 0), (cw/2 - rim, visible-depth - 0.02), stroke: 0.5pt)
        draw.line((-cw/2 + rim, 0), (cw/2 - rim, 0), stroke: 0.5pt)
      })
    }

    // Positions & Draw Chairs
    let side-count = if chairs >= 6 { calc.floor((chairs - 2) / 2) } else { calc.floor(chairs / 2) }
    
    if side-count > 0 {
      let spacing = w / (side-count + 1)
      let start-x = -w/2
      for i in range(side-count) {
        let cx = start-x + (spacing * (i+1))
        draw-chair(cx, d/2.5, 0deg)
        draw-chair(cx, -d/2.5, 180deg)
      }
    }

    if chairs >= 6 or chairs == 2 {
       draw-chair(w/2.2, 0, -90deg) 
       draw-chair(-w/2.2, 0, 90deg)
    }

    // --- DRAW TABLE ---
    draw.rect((-w/2, -d/2), (w/2, d/2), fill: white, stroke: 1pt)

    // --- DRAW LABEL (Centered) ---
    if label != none {
      draw.content((0, 0), {
        // We wrap the text in a set text rule for styling
        set text(size: 10pt, font: "Linux Libertine", style: "italic")
        label
      })
    }
  })
}

/// --- 6. GAS BURNER / COOKTOP ---
// A standard 4-burner kitchen stove.
// Origin (0,0) is in the center. The knobs are placed at the "bottom" (facing the user).
#let gas-burner(pos, rotation: 0deg, scale: 1.0) = {
  // Standard cooktop dimensions (approx 70cm x 60cm relative to your scale)
  let w = 0.7 
  let d = 0.6 
  
  obj-wrapper(pos, rotation, {
    draw.scale(scale)
    
    // 1. The Main Cooktop Frame
    draw.rect((-w/2, -d/2), (w/2, d/2), fill: white, radius: 0.03, stroke: 1pt)
    
    // 2. The Control Panel (Front strip for knobs)
    let panel-y = d/2 - 0.15
    draw.line((-w/2, panel-y), (w/2, panel-y), stroke: 0.5pt)
    
    // 3. The Knobs (4 small circles evenly spaced on the panel)
    let knob-spacing = w / 5
    for i in range(4) {
      let kx = -w/2 + knob-spacing * (i + 1)
      draw.circle((kx, d/2 - 0.050), radius: 0.03, fill: white, stroke: 0.5pt)
    }
    
    // 4. Helper function to draw a Burner + Grate
    let draw-burner(bx, by, r) = {
      // Outer ring
      draw.circle((bx, by), radius: r, stroke: 0.8pt)
      // Inner gas cap
      draw.circle((bx, by), radius: r * 0.3, fill: black)
      // The iron grates (Crosshairs extending slightly past the ring)
      draw.line((bx - r - 0.02, by), (bx + r + 0.02, by), stroke: 0.5pt)
      draw.line((bx, by - r - 0.02), (bx, by + r + 0.02), stroke: 0.5pt)
    }

    // 5. Place the 4 Burners (Different sizes for realism!)
    // Top Left (Medium)
    draw-burner(-0.18, -0.15, 0.1)
    // Top Right (Small/Simmer)
    draw-burner(0.18, -0.15, 0.08)
    // Bottom Left (Large/Wok)
    draw-burner(-0.18, 0.12, 0.12)
    // Bottom Right (Medium)
    draw-burner(0.18, 0.12, 0.1)
  })
}
