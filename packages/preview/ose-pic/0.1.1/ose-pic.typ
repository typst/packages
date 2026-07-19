#let __global_foreground_registry = state("__global_foreground_registry", (:))
#let __global_background_registry = state("__global_background_registry", (:))
#let __global_foreground_registryAll = state("__global_foreground_registryAll", (:))
#let __global_background_registryAll = state("__global_background_registryAll", (:))

// --- The Factory ---
#let ___common_bgfg_handler_factory(is_background: true) = {
  return () => {
    context {
      let reg_state = if is_background { __global_background_registry } else { __global_foreground_registry }
      let reg_state_all = if is_background { __global_background_registryAll } else { __global_foreground_registryAll }
      let p = str(counter(page).get().first())

      // Use .final() to ensure we see updates made later in the page flow
      let reg = reg_state.final()
      let reg_all = reg_state_all.final()

      if reg.keys().contains(p) {
        reg.at(p).join()
      }
      if reg_all.keys().contains("0") {
        reg_all.at("0").join()
      }
    }
  }
}

#let osepic_default_foreground_handler = ___common_bgfg_handler_factory(is_background: false)
#let osepic_default_background_handler = ___common_bgfg_handler_factory(is_background: true)

// --- The Registry Helpers ---
// Add to registry, very simple logic
#let _add_to_reg(reg_state, content) = context {
  let p = str(counter(page).get().first())
  // But, if we add to the every-page registry, treat p as 0
  if (reg_state == __global_foreground_registryAll or reg_state == __global_background_registryAll) {
    p = "0"
  }
  reg_state.update(reg => {
    let reg = if type(reg) != dictionary { (:) } else { reg }
    let items = reg.at(p, default: ())
    items.push(content)
    reg.insert(p, items)
    reg
  })
}

// Current page
#let AddToShipoutBG(content) = _add_to_reg(__global_background_registry, content)
#let AddToShipoutFG(content) = _add_to_reg(__global_foreground_registry, content)

// Every page
#let AddToShipoutBGAll(content) = _add_to_reg(__global_background_registryAll, content)
#let AddToShipoutFGAll(content) = _add_to_reg(__global_foreground_registryAll, content)


#let ose-pic-init(doc) = {
  set page(
    foreground: osepic_default_foreground_handler(),
    background: osepic_default_background_handler(),
  )
  doc
}


// --- Demo ---
#let ___demo_doc = {
  show: ose-pic-init
  set page(
    margin: (top: 30mm, bottom: 30mm, left: 30mm, right: 95mm),
  )

  // Function to add side column comment
  let add_comment(content) = context {
    let y_offset = here().position().values().at(2)
    AddToShipoutFG(place(top + left, dx: 210mm - 95mm + 9mm, dy: y_offset, box(
      width: 95mm - 9mm - 20mm,
      height: auto,
      text(size: 9pt, fill: blue, content),
    )))
  }
  set text(size: 12pt, font: ("TeX Gyre Heros", "Noto Sans CJK SC"))
  set par(justify: true)
  AddToShipoutBGAll(place(center + horizon, dy: 51mm, text(22mm, fill: green.transparentize(66%))[BG ALL PAGES]))

  for itr in range(1, 34) {
    // Test Background (Red)
    AddToShipoutBG(place(center + horizon, text(20mm, fill: red.transparentize(70%))[BG #itr]))

    // Test Foreground (Blue)
    AddToShipoutFG(place(top + right, dx: -1cm, dy: 1cm, text(10mm, fill: blue.transparentize(50%))[FG #itr]))

    [= Section #itr ;;

      #par(lorem(150))
      #par(lorem(250))
      #add_comment([Hello world. This is a small piece of text.])
      #par(lorem(144))
      #par(lorem(144))
      #par(lorem(144))
    ]
    pagebreak(weak: true)
  }

}

#___demo_doc
