// All characters with 1 to 3 letters are joined with next word.
// Všechny slova s 1-3 znaky jsou spojeny s následujícím slovem.
#let apply-vlna(doc) = [
#let short-words = regex("(\<\p{Lowercase}{1,3}\>)+ ")
#show short-words: it => text()[#{it.text.match(short-words).captures; ([],)}.join[~]]
#doc
]