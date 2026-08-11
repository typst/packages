// typst init @preview/econ-working-paper
// typst compile main.typ

#import "@preview/econ-working-paper:0.3.1": *

#show: paper.with(
  // -- metadata -----------------------------------------------------------
  title: "Coffee Ipsum: A Caffeinated Placeholder",
  subtitle: "WORK IN PROGRESS",                 
  authors: (
    (
      name: "Bob Brewster",
      affiliation: "SDA Espresso School of Management",
      email: "bbrewster@sdaespresso.edu",
    ),
    (
      name: "Remi Roastington",
      affiliation: "Oxbridge Department of Coffenomics",
    ),
    (
      name: "Paola Pourová",
      affiliation: "Oxbridge Department of Coffenomics",
    ),
  ),
  date: "2026-01-01",              // version/date string shown on title page
  abstract: [
    Café au lait, single origin, and dark roast walk into a regression. This paper investigates the optimal brewing temperature for extracting flavor compounds from Arabica beans using a randomized controlled trial across 12 roasteries. We find that a 96°C pour-over maximizes body and acidity balance, while cold brew extraction requires 18 hours to reach comparable total dissolved solids. A structural model of caffeine diffusion rationalizes these findings. Our results have implications for baristas, supply chain managers, and anyone who has ever waited too long for a flat white.
  ],
  keywords: [coffee, brewing, extraction, caffeine, pour-over],
  jel: [Q11, L66, D12],            // optional JEL classification codes
  acknowledgments: [We thank the baristas at Intelligentsia and Green Bottle for providing beans and patience. Brewster gratefully acknowledges financial support from the National Coffee Association (Grant No. DRIP-99).],

  // -- bibliography -------------------------------------------------------
  bibliography: bibliography("refs.bib", title: "References"),
  citation-style: "chicago-author-date", // any CSL style name
  endfloat: true,
  anonymize: false,
)

// Your main content goes here
= Introduction

Strong coffee, ristretto, galão, organic, seasonal blend doppio that crema sit dripper. Once the first bean discloses its aromatics, the rest unravel in turn #cite(<grossman1980>). Arabica robusta grinder cream percolator mocha plunger pot skinny. Single shot steamed robust kopi-luwak fair trade affogato cup grounds dark.

Espresso macchiato cortado lungo breve cappuccino americano. Barista whipped single origin viennese variety beans cup extraction. Irish aged french press decaffeinated, acerbic fair trade robust skinny to go.

Brewed seasonal aroma cup plunger pot café au lait strong. Cream dark galão pumpkin spice latte dripper cappuccino carajillo extraction. Sit variety, rich kopi-luwak et foam percolator crema mocha a wings.

= Data

Our sample covers 847 cups of coffee from 12 roasteries across three continents. We measure extraction yield as the ratio of dissolved coffee compounds to total dry grounds, following #cite(<fama1970>, form: "prose"), who showed that markets are efficient --- our pour-overs are, too.

@tab-summary reports summary statistics for the main brewing variables. Pour-over and espresso methods differ on temperature and contact time but produce comparable extraction yields when properly calibrated.

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([*Variable*], [*Mean*], [*SD*], [*N*]),
    table.hline(stroke: 0.75pt),
    [Extraction yield (%)], [20.3], [2.1], [847],
    [Brew temperature (°C)], [93.5], [4.8], [847],
    [Contact time (s)], [187], [62], [847],
    [TDS (%)], [1.35], [0.22], [847],
    table.hline(stroke: 1.5pt),
  ),
  caption: [Summary statistics for coffee extraction experiments.],
  kind: table,
) <tab-summary>

Frappuccino, mug saucer viennese caramelization barista aromatic crema. Decaffeinated, brewed espresso doppio grounds dark bar kopi-luwak to go steamed.

= Results

Our main specification estimates the effect of brewing temperature on extraction yield. A one-degree increase above 90°C raises yield by 0.3 percentage points ($p < 0.01$).

$ "Yield"_i = alpha + beta dot "Temperature"_i + gamma dot "Grind Size"_i + epsilon_i $ <eq:brew>

@eq:brew presents the reduced-form specification. The coefficient $beta$ captures the marginal effect of temperature, holding grind size constant.

Skinny, body dripper crema robust single origin percolator. As single shot grinder to go, galão brewed seasonal café au lait pumpkin spice dark. Strong rich ristretto aged cream extra organic, milk sugar foam lungo.

= Conclusion

Coffee, dark, cappuccino brewed aromatic robust. We find that temperature is the single most important controllable parameter in coffee extraction, dominating grind size and contact time. These results suggest that investment in temperature-stable kettles yields higher returns than upgrading grinder burrs, at least on the margin.
