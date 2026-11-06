#import "styles.typ" as styles
#import "styling.typ" as styling
#import "layout.typ": divide

#let make-frames(kind, style: styles.boxy, ..frames) = {
  import "parse.typ"
  import "layout.typ"

  for (id, supplement, color) in parse.parse-args(frames) {
    ((id): layout.factory(style, supplement, kind, color))
  }
}

/*
Definition of styling:

let factory(title: content, tags: (content), body: content, supplement: string or content, number, args)
*/
