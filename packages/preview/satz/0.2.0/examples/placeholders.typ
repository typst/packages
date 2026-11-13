// Draft figures through the public satz API.
#import "@preview/satz:0.2.0": report, placeholder, satz-figure
#show: report.with(config: (colors: (bg-paper: white), toc: (depth: 1), lof: (depth: none)))

= Drafting the report

The layout can be reviewed before the illustrations are finished.
See @fig:overview and @fig:planned for two draft figures.

#figure(
  placeholder(),
  caption: [A draft figure using the default placeholder.],
) <fig:overview>

#satz-figure(
  placeholder(width: 80%, height: 28mm, label: [Planned result plot]),
  caption: [A longer caption describing the result plot that will replace this box.],
  short-caption: [Planned results],
) <fig:planned>
