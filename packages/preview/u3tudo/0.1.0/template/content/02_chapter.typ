= Theory

This is a placeholder for a second chapter. It could contain the theoretical background of your research.

== A section

Reference relevant literature using Typst's citation syntax, for example @example2024.

Mathematical equations can be included and referenced:

$ E = m c^2 $ <einstein>

As shown in @einstein, energy and mass are related by the speed of light squared.

@physical-constants shows different physical constants.

#figure(
  table(
    columns: 3,
    [*Quantity*], [*Symbol*], [*Value*],
    [Speed of light], [$c$], [$3 times 10^8$ m/s],
    [Planck constant], [$h$], [$6.626 times 10^-34$ J s],
  ),
  caption: [Example table with physical constants.],
)<physical-constants>

Here is now a long body of text:

#lorem(200)

#lorem(100)

#lorem(300)

#lorem(400)
