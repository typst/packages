#import "/pages/appendix.typ": _render-appendix

#include "/tests/helper/set-l10n-db.typ"

#_render-appendix(appendix: (
  enabled: true,
  title: "Custom Appendix",
  content: lorem(40)
))

#_render-appendix(appendix: (
  enabled: true,
  content: lorem(40)
))

#_render-appendix(appendix: (
  enabled: false,
  title: "Custom Appendix",
  content: lorem(40)
))
