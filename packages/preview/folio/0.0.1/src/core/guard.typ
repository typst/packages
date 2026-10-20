/// section-guard — decides whether to render a section based on toggle value.
/// toggle: true  → always render (even if data is missing)
/// toggle: false → never render
/// toggle: auto  → render only if data path is non-empty
#import "state.typ": folio-state
#import "resolve.typ": nonempty

#let section-guard(toggle, path, render) = context {
  if toggle == false { return }

  let st = folio-state.get()
  let data = st.at("data", default: (:))

  if toggle == true {
    render(path)
  } else {
    // auto: render only if data is present and non-empty
    if nonempty(data, path) {
      render(path)
    }
  }
}
