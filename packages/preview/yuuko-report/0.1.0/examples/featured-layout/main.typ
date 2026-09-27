#import "../../template-landscape.typ": *
#import "../_shared.typ": *

#show: conf.with(
  title: [Featured Chart Layouts],
  cover: false,
  toc: true,
)

= Featured Chart with Side Column

#chart-featured(
  demo-card([Main Result], [Featured Chart], height: 8.4cm, badge: [Key Result]),
  demo-card([Detail A], [Detail A], height: 3cm),
  demo-card([Detail B], [Detail B], height: 3cm),
)

= Hero Row

#chart-hero-row(
  demo-card([All-channel Trend], [Wide Chart], height: 4.5cm),
  (
    demo-card([Region A], [A], height: 2.8cm),
    demo-card([Region B], [B], height: 2.8cm),
    demo-card([Region C], [C], height: 2.8cm),
  ),
)

= Chart with Notes

#chart-with-notes(
  demo-card([Afterglow Decay], [Decay Curve], height: 5.5cm),
  [
    *Findings*

    - Most channels stabilize after 200 ms.
    - CH-064 decays more slowly than the group.
    - Repeat acquisition for anomalous channels.
  ],
)

