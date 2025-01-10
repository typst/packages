#let __settings = state("__cv_settings", (:))

#let __set(key, value) = {
  __settings.update(st => {
    st.insert(key, value)
    st
  })
}

#let __get(key) = {
  __settings.final().at(key, default: none)
}
