#import "../touying.typ": utils
#import "headings.typ": appendix-filter
#import "metadata.typ": is-kind
#import "visibility.typ": is-covered

// All navigators share visible, deduplicated heading context and logical slides.
// A heading revealed in a later frame of this slide must not leak into chrome.
#let navigation-model() = {
  let page = here().page()
  let slides = query(<touying-metadata>).filter(it => is-kind(it, "touying-new-slide"))
  let slide-index = calc.max(0, slides.filter(it => it.location().page() <= page).len() - 1)
  let next-page = slides.at(slide-index + 1, default: none)
  let next-page = if next-page == none { calc.inf } else { next-page.location().page() }
  let headings = ()
  let keys = ()
  for hd in query(appendix-filter(heading.where(outlined: true))) {
    if is-covered(hd) or (page < hd.location().page() and hd.location().page() < next-page) { continue }
    let record = (source: hd, level: hd.level, body: hd.body, loc: hd.location(), numbering: hd.numbering,
      numbers: counter(heading).at(hd.location()), slide: utils.slide-counter.at(hd.location()))
    let key = (record.level, record.body, record.numbers, record.slide)
    if key not in keys { keys.push(key); headings.push(record) }
  }
  let path = ()
  for hd in headings.filter(h => h.loc.page() <= page) {
    while path.len() > 0 and path.last().level >= hd.level { let _ = path.pop() }
    path.push(hd)
  }
  let roots = headings.filter(h => h.level == 1)
  let root-index = roots.filter(h => h.loc.page() <= page).len() - 1
  let root = if root-index >= 0 { roots.at(root-index) } else { none }
  let boundary = query(<touying-metadata>).filter(it => is-kind(it, "touying-appendix")).first(default: none)
  let boundary = if boundary == none { calc.inf } else { boundary.location().page() }
  // The new-slide metadata precedes the heading on the appendix's first page;
  // scope by page rather than source order so that slide belongs to appendix.
  let scoped-slides = slides.filter(it => if page < boundary { it.location().page() < boundary }
    else { it.location().page() >= boundary })
  let section-slides = if root == none { () } else {
    let next-root = roots.at(root-index + 1, default: none)
    scoped-slides.filter(it => root.loc.page() <= it.location().page()
      and (next-root == none or it.location().page() < next-root.loc.page()))
  }
  (headings: headings, roots: roots, path: path, root: root, root-index: root-index,
    slides: slides, scoped-slides: scoped-slides, slide-index: slide-index, section-slides: section-slides)
}

// A bounded neighborhood, shared by header tabs/dots and chapter segments.
#let navigation-window(items, active, count) = {
  let start = calc.max(0, calc.min(active - calc.floor(count / 2), items.len() - count))
  (start, items.slice(start, calc.min(start + count, items.len())))
}
