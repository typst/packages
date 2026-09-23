// Series styles are shared by the comparison panel and its legend.
#import "symbols.typ": _marker, _segment

#let _profile-pen(item) = (
  paint: item.color, thickness: item.thickness, dash: item.dash,
  cap: "round", join: "round",
)

#let _profile-marker(item, size) = _marker(
  item.marker, size, item.color, fill: item.color.lighten(item.fill-lighten), thickness: item.marker-thickness,
)

#let _sample(item, size) = box(width: 0.6cm, height: 0.4cm, {
  _segment(0.02cm, 0.2cm, 0.58cm, 0.2cm, _profile-pen(item))
  place(top + left, dx: 0.3cm - size / 2, dy: 0.2cm - size / 2,
    _profile-marker(item, size))
})

