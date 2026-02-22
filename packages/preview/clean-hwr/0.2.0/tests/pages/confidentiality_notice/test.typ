#import "/pages/confidentiality_notice.typ": _render-confidentiality-notice-if-right-place, render-confidentiality-notice

#include "/tests/helper/set-l10n-db.typ"

#let conf-notice = (
  title: text(blue)[Custom Conf Notice],
  content: lorem(40)
)

#render-confidentiality-notice(confidentiality-notice: conf-notice)

#let _conf-notice = (..conf-notice, page-idx: 4)

#pagebreak()

#_render-confidentiality-notice-if-right-place(confidentiality-notice: _conf-notice)

#pagebreak()

#_render-confidentiality-notice-if-right-place(confidentiality-notice: _conf-notice)

#pagebreak()

#_render-confidentiality-notice-if-right-place(confidentiality-notice: _conf-notice)
