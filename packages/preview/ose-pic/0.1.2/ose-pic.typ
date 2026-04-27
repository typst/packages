// Single registry for all shipout items
#let __osepic_registry = state("__osepic_registry", ())

// --- The Factory ---
// Now iterates through a single list and filters based on logic
#let ___common_bgfg_handler_factory(is_background: true) = {
  return () => {
    context {
      let current_page = counter(page).get().first()
      // Use .final() to ensure items added anywhere on the page are captured
      let items = __osepic_registry.final()
      
      for item in items {
        // Condition 1: Match background/foreground layer
        let layer_match = (item.is_background == is_background)
        
        // Condition 2: Check if we are on or after the starting page
        let is_active_page = if item.is_single_page_only {
          current_page == item.start_page
        } else {
          current_page >= item.start_page
        }
        
        if layer_match and is_active_page {
          item.entry_content
        }
      }
    }
  }
}

#let osepic_default_foreground_handler = ___common_bgfg_handler_factory(is_background: false)
#let osepic_default_background_handler = ___common_bgfg_handler_factory(is_background: true)

// --- Internal Registry Helper ---
#let _add_to_osepic(content, is_bg, is_single) = context {
  let p = counter(page).get().first()
  __osepic_registry.update(my_arr => {
    my_arr.push((
      is_background: is_bg,
      start_page: p,
      is_single_page_only: is_single,
      entry_content: content,
    ))
    my_arr
  })
}

// --- Public API ---

// Add to Current Page Only
#let AddToShipoutBG(content) = _add_to_osepic(content, true, true)
#let AddToShipoutFG(content) = _add_to_osepic(content, false, true)

// Add to Current Page and ALL Subsequent Pages (Like eso-pic's * version)
#let AddToShipoutBGAll(content) = _add_to_osepic(content, true, false)
#let AddToShipoutFGAll(content) = _add_to_osepic(content, false, false)

// --- Initialization ---
#let ose-pic-init(doc) = {
  set page(
    foreground: osepic_default_foreground_handler(),
    background: osepic_default_background_handler(),
  )
  doc
}



#let __demo_doc = [
  #show: ose-pic-init
  #AddToShipoutFGAll(place(center + bottom, box(width: 90mm, height: 30mm, fill: gray.lighten(75%))))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #AddToShipoutFG(place(center + horizon, box(width: 80mm, height: 70mm, fill: gray.lighten(55%))))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #AddToShipoutBGAll(place(top + right, box(width: 80mm, height: 70mm, fill: blue.lighten(55%))))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  
  #AddToShipoutBG(place(top + left, box(width: 80mm, height: 70mm, fill: red.lighten(55%))))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
  #par(lorem(155))
]

#__demo_doc
