#import "sample.typ": samples

#set page(
  width: 420pt,
  height: 128.35pt,
  margin: 0pt
)

#style(styles => {
  let content = pad(
    y: 10pt,
    samples.at(0)
  )

  let frame = measure(content, styles)

  [
    #content

    // #frame.height
  ]
})

#set page(height: 183.59pt)

#style(styles => {
  let content = pad(
    y: 10pt,
    samples.at(1)
  )

  let frame = measure(content, styles)

  [
    #content

    // #frame.height
  ]
})

#set page(height: 88.39pt)

#style(styles => {
  let content = pad(
    y: 10pt,
    samples.at(2)
  )

  let frame = measure(content, styles)

  [
    #content

    // #frame.height
  ]
})
