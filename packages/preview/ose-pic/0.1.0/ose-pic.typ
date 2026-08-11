#let __global_foreground_registry = state("__global_foreground_registry", (:))
#let __global_background_registry = state("__global_background_registry", (:))

// --- The Factory ---
#let ___common_bgfg_handler_factory(is_background: true) = {
  return () => {
    context {
      let reg_state = if is_background { __global_background_registry } else { __global_foreground_registry }
      let p = str(counter(page).get().first())

      // Use .final() to ensure we see updates made later in the page flow
      let reg = reg_state.final()

      if reg.keys().contains(p) {
        reg.at(p).join()
      }
    }
  }
}

#let osepic_default_foreground_handler = ___common_bgfg_handler_factory(is_background: false)
#let osepic_default_background_handler = ___common_bgfg_handler_factory(is_background: true)

// --- The Registry Helpers ---
#let _add_to_reg(reg_state, content) = context {
  let p = str(counter(page).get().first())
  reg_state.update(reg => {
    let reg = if type(reg) != dictionary { (:) } else { reg }
    let items = reg.at(p, default: ())
    items.push(content)
    reg.insert(p, items)
    reg
  })
}

#let add_to_shipout_bg(content) = _add_to_reg(__global_background_registry, content)
#let add_to_shipout_fg(content) = _add_to_reg(__global_foreground_registry, content)




// --- Demo ---
#let ___demo_doc = {
  set page(
    // Call handlers directly; factory handles the context
    foreground: osepic_default_foreground_handler(),
    background: osepic_default_background_handler(),
  )
  set text(size: 12pt, font: ("TeX Gyre Heros", "Noto Sans CJK SC"))

  for itr in range(1, 34) {
    // Test Background (Red)
    add_to_shipout_bg(place(center + horizon, text(20mm, fill: red.transparentize(80%))[BG #itr]))

    // Test Foreground (Blue)
    add_to_shipout_fg(place(top + right, dx: -1cm, dy: 1cm, text(10mm, fill: blue.transparentize(50%))[FG #itr]))

    [= Section #itr ;;

      #lorem(250)]
    pagebreak(weak: true)
  }
}

#___demo_doc
