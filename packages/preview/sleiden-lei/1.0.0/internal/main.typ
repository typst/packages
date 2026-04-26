#import "tools.typ"
#import "colors.typ"

#let placeholder = (
	image: rect(width: 100%, height: 100%, stroke: colors.leiden-blue, [image]),
	body: [
		*Lorem ipsum dolor sit amet*

		Consectetuer adipiscing elit. Maecenas porttitor congue massa.
		Fusce posuere, magna sed pulvinar ultricies.

		- Nunc viverra imperdiet enim. 
		- Fusce est.
		- Vivamus a tellus.
			- Pellentesque habitant morbi.
			- Proin pharetra nonummy pede. 
			- Mauris et orci.
	],
)

#let slides(body, numbering: "1", lang: "en") = {
  set text(font: ("Minion Pro", "Minion 3", "Georgia"), fill: colors.leiden-blue, size: 18pt, lang: lang)
  set list(marker: ([•], [-], h(0.5em)))
  set page(numbering: numbering)
  body
}

#let title-presentation(
  title: [Title presentation],
  name: [Name speaker],
  place: [Place],
  date: [Date],
) = tools.title(title, [#name | #place #h(1fr) #date], colors.subtitle-blue)

#let index(
  title: [Index],
  body: [
    1. Chapter
    2. Chapter
    3. Chapter
      - Slide name
      - Slide name
    4. Chapter
    5. Chapter
    6. Chapter
  ],
  image: placeholder.image,
) = tools.content(
  title,
  stack(
    dir: ltr,
    block(
      width: 7.49in,
      height: 100%,
      inset: 0in,
      {
        show enum: text.with(size: 24pt)
        show list: text.with(size: 18pt)
        body
      },
    ),
    h(1fr),
    block(
      width: 4.75in,
      height: 100%,
      inset: 0in,
      align(center + horizon, image)
    )
  )
)

#let only-text(
  title: [Only text],
  body: placeholder.body,
) = tools.content(
  title,
  body
)

#let text-dominant(
  title: [Text dominant, image 25%],
  body: placeholder.body,
  image: placeholder.image,
) = tools.content(
  title,
  stack(
    dir: ltr,
    block(
      width: 8.67in,
      height: 100%,
      inset: 0in,
      body,
    ),
    h(1fr),
    block(
      width: 3.56in,
      height: 100%,
      inset: 0in,
      align(center + horizon, image)
    )
  )
)

#let text-and-image-equal(
  title: [Text and image egual, 50%-50%],
  body: placeholder.body,
  image: placeholder.image,
) = tools.content(
  title,
  stack(
    dir: ltr,
    block(
      width: 6.12in,
      height: 100%,
      inset: 0in,
      body,
    ),
    h(1fr),
    block(
      width: 6.12in,
      height: 100%,
      inset: 0in,
      align(center + horizon, image)
    )
  )
)

#let image-dominant(
  title: [Image dominant, text 25%],
  body: placeholder.body,
  image: placeholder.image,
) = tools.content(
  title,
  stack(
    dir: ltr,
    block(
      width: 3.86in,
      height: 100%,
      inset: 0in,
      body,
    ),
    h(1fr),
    block(
      width: 8.37in,
      height: 100%,
      inset: 0in,
      align(center + horizon, image)
    )
  )
)

#let only-image(
  title: [Only image],
  image: placeholder.image,
) = tools.content(
  title,
  align(center + horizon, image)
)

#let text-and-4-images(
  title: [Text and 4 images],
  body: placeholder.body,
  images: (placeholder.image,)*4,
) = tools.content(
  title,
  stack(
    dir: ltr,
    block(
      width: 6.12in,
      height: 100%,
      inset: 0in,
      body,
    ),
    h(1fr),
    block(
      width: 6.12in,
      height: 100%,
      inset: 0in,
      stack(
        dir: ttb,
        block(
          width: 100%,
          height: 2.51in,
          inset: 0in,
          stack(
            dir: ltr,
            block(
              width: 2.95in,
              height: 100%,
              inset: 0in,
              align(center + horizon, images.at(0)),
            ),
            h(1fr),
            block(
              width: 2.95in,
              height: 100%,
              inset: 0in,
              align(center + horizon, images.at(1)),
            ),
          )
        ),
        v(1fr),
        block(
          width: 100%,
          height: 2.51in,
          inset: 0in,
          stack(
            dir: ltr,
            block(
              width: 2.95in,
              height: 100%,
              inset: 0in,
              align(center + horizon, images.at(2)),
            ),
            h(1fr),
            block(
              width: 2.95in,
              height: 100%,
              inset: 0in,
              align(center + horizon, images.at(3)),
            ),
          )
        ),
      )
    )
  )
)

#let text-and-2-images(
  title: [Text and 2 images],
  body: placeholder.body,
  images: (placeholder.image,)*2,
) = tools.content(
  title,
  stack(
    dir: ltr,
    block(
      width: 6.12in,
      height: 100%,
      inset: 0in,
      body,
    ),
    h(1fr),
    block(
      width: 6.12in,
      height: 100%,
      inset: 0in,
      stack(
        dir: ltr,
        block(
          width: 2.95in,
          height: 100%,
          inset: 0in,
          align(center + horizon, images.at(0)),
        ),
        h(1fr),
        block(
          width: 2.95in,
          height: 100%,
          inset: 0in,
          align(center + horizon, images.at(1)),
        ),
      )
    )
  )
)

#let title-closure(
  title: [Title closure],
) = tools.title(title, none, colors.leiden-blue)