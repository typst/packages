Hi there 👋,
thanks for interest in this package. It's my first step for automating my office work. I use this for school-related work.

It exports the function `simple-page` with the following arguments:
- first unnamed parameter (string): name (or whatever should be on top left)
- second unnamed parameter (string): mail (or whatever should be down left in the corner, if it isn't a mail please see supressMailLink)
- middle-text (string): text on top in the middle, optional
- date (bool): date in germand format DD.MM.YYYY, optional
- numbering (bool): page numbering in german format "Seite x von y", optional
- supress-mail-link (bool): mail text isn't covered as mailto-link if true, optional

Full example:
```typst
simple-page.with("Max Mustmann", "max.mustermann@example.com", middle-text: "Example GmbH", date: true, numbering: true, supress-mail-link: false)
```

Reach me out if you have questions! ✌️ 
