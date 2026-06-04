/// folio — phase-runner
/// render-phase(): the single implementation of the phase render loop.
/// All phase files (initiation, planning, execution, closure, custom) call this.
#import "state.typ": folio-state
#import "guard.typ": section-guard
#import "resolve.typ": get-title, nonempty

#let render-phase(pipeline, phase-id, default-title) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  let sections-config = st.config.at("sections", default: (:))

  let renderable = pipeline.filter(p => {
    if p.phase != phase-id { return false }
    let toggle = sections-config.at(p.section_id, default: auto)
    toggle == true or (toggle == auto and nonempty(data, p.data_path))
  })

  if renderable.len() == 0 { return }

  pagebreak()
  heading(level: 1)[#get-title(
    data,
    "phases." + phase-id + ".title",
    default-title,
  )]

  for item in renderable {
    let toggle = sections-config.at(item.section_id, default: auto)
    section-guard(toggle, item.data_path, item.render_fn)
  }
}
