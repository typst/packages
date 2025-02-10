// All characters with less than 3 letters are connected to the next word.
#show text: body => {
  let vlna = regex("(\<\p{Lowercase}{1,3}\>)+ ")
  show vlna: it => text()[#{it.text.match(vlna).captures; ([],)}.join[~]]
  body
}
