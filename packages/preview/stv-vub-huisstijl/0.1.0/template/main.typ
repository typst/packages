#import "@preview/stv-vub-huisstijl:0.1.0": vub-titlepage

// Adapt the default arguments to your needs.
#vub-titlepage(
  title: "Title of the thesis",
  subtitle: "An optional subtitle",
  pretitle: "Graduation thesis submitted in partial fulfillment of the requirements for the degree of Master of Science in Mathematics",
  authors: ("Jane Doe",),
  promotors: ("John Smith",),
  faculty: "Sciences and Bio-Engineering Sciences",
  date: datetime.today().display("[month repr:long] [day], [year]"),
)