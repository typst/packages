#import "@preview/markly:0.3.0"

#let markly-context = markly.setup(
  content-width: 6in,
  content-height:4in,
)

#show: markly.page-setup.with(markly-context)


//////////////////////////////////////////// Templates

#let title(body, inset-y:12pt) = {
  markly.to-bleed(text(white, size:2.5em, body), markly-context)
}

#let author(body) = {
  block(
    inset: (bottom: 0.5em),
    text(style:"italic", {
      [by: ]
      body
    })
  )
}

#show heading: it => {
  block(
    inset: (top:0em, bottom: .3em),
    it.body
  )
}


//////////////////////////////////////////// Content

#title[Blue Cheese Salad]

#grid(
  columns: (auto, 1fr),

  row-gutter: 0pt,
  column-gutter: 24pt,

  [

    #author[Chad Skeeters]

    = Ingredients

    - #link("https://www.heb.com/product-detail/h-e-b-kindly-cultivated-fresh-organic-butter-lettuce-blend-4-oz/9296141")[Butter Lettuce]
    - #link("https://www.heb.com/product-detail/marie-s-chunky-blue-cheese-dressing-sold-cold-12-fl-oz/321384")[Blue Cheese Dressing]
    - #link("https://www.heb.com/product-detail/delallo-quartered-marinated-artichoke-hearts-12-oz/1207535")[Artichoke Hearts]
    - #link("https://www.heb.com/product-detail/mezzetta-sliced-greek-kalamata-olives-9-5-oz/1439822")[Kalamata Olives]
    - #link("https://www.heb.com/product-detail/h-e-b-pine-nuts-4-oz/4604552")[Pine Nuts]
    - #link("https://www.heb.com/product-detail/pepperidge-farm-farmhouse-mini-plain-bagels-17-oz/2001048")[Bagels]
    - #link("https://www.heb.com/product-detail/rustico-di-casa-asaro-unfiltered-extra-virgin-olive-oil-17-oz/2935089")[Olive Oil]
    - #link("https://www.heb.com/product-detail/h-e-b-coarse-kosher-sea-salt-4-4-lbs/1917502")[Kosher Salt]
    - #link("https://www.heb.com/product-detail/bolner-s-fiesta-whole-black-pepper-3-oz/169910")[Black Pepper]
  ],

  [
    = Steps

    + Chop bagels into crouton-sized pieces.  Put pieces into a mixing bowl.  Add olive oil, salt, and pepper and mix.  Olive oils #link("https://www.amazon.com/dp/B01MT673U6")[sprayers] work well for this task.
    + Optionally, chop the lettuce into bite-sized pieces.
    + Put bagel pieces into the air fryer for 4-5 minutes on 400#sym.degree;~F.
    + Add lettuce and blue cheese dressing to a mixing bowl and mix.
    + Chop artichokes and black olives according to your preference and add to the salad.
    + Sprinkle in pine nuts.
    + Mix salad.
    + Add croutons and serve while hot
  ]
)


#pagebreak(weak: true)

// Load data here so path is relative to this file
#let img-data = read("ping-pong.jpg", encoding: none)

// Use markly's img-to-bleed to stretch an image to the bleed marks

// Note: Image should be 72*content-width+bleed by 72*content-height+bleed to not be distored
//       (72*6+9, 72*4+9) = (441x297)
#markly.img-to-bleed(img-data, markly-context)

#text(font:"Source Sans Pro", 4em, white, weight:900)[
  Play On
]
