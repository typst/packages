#import "@preview/touying-pres-uge:0.1.1": *

#show: uge-theme.with(
    aspect-ratio: "16-9",
    footer: self => self.info.institution,
    config-info(
	title: [Title],
	subtitle: [A UGE template #emoji.rocket],
	authors: (
	    (
		name: "John Doe",
		affiliations: (1,),
		email: "john.doe@univ-eiffel.fr"
	    ),
	),
	institutions: (
	    "Université Gustave Eiffel, Your laboratory",
	),
	affiliation_type: "numbers",
	date: datetime.today(),
	logo: image("logo_univ_gustave_eiffel_blanc_rvb.svg", height: 1em),
	variant: true
    ),
)

#title-slide()

= Section

== Slide Title

Please write your own content #alert[here] 
