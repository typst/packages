// All characters with less than 3 letters are connected to the next word.
#let short-words = regex("(\<\p{Lowercase}{1,3}\>)+ ")
#show short-words: it => text()[#{it.text.match(short-words).captures; ([],)}.join[~]]
