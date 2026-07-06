#import "@preview/clean-ut:0.1.0": *

= Results

== Lorem ipsum <lorem>
We are here in @lorem. You could also write that as @lorem[Chapter]

Citations are grouped automatically for more than three citations @Gratani2023@Abida2021. If we add one more, the citations are connected with a hyphen: @Gratani2023@Abida2021@Abramson2024. Cool, right?

@subfigure is not the same as @asubfigure, attachment figures are numbered and referenced with a "S", however i havent found a good solution to reference attachment subfigure-grids as a whole: @agreatplot and @greatplot, so refrain from doing this if possible.


Finally, #lorem(20) @Gratani2023), and therefore we need more money.

#subfig-grid(
	columns: 2,
	rows: 2,
	figure(
		rect[#lorem(60)],
		caption: [],
	), <subfigure>,

	figure(
		rect[#lorem(60)],
		caption: [],
	),

	figure(
		rect[#lorem(60)],
		caption: [],
	),

	figure(
		rect[#lorem(60)],
		caption: [],
	),

	//figure(image("Path/to/image.png"), caption: []),

	caption: [#caption[This is a short caption][This is a extension that is only shown in the descriptions but not in the outline]], //total caption
	label: <greatplot>,
)