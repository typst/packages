#let metadata-state = state("metadata-state", (:))
#let meta-value = (key, default: none) => metadata-state.final().at(key, default: default)
#let val-or-meta = (value, key, default: none) => if value == none { meta-value(key, default: default) } else { value }
#let main-header-footer-state = state("main-header-state", (header: () => none, footer: () => none))
