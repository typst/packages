#import "@preview/yinsh:1.0.0" : play, record
// #import "@local/yinsh:1.0.0" : play, record

#set page(width: auto, height: 29cm)

#let commands = ("
p f6
p b7
p d4
p e10
p g9
p g11
p c6
p a5
p a2
p d6
s c6
m c8
s d6
m b6
s d4
m a4
s b7
m c7
s c8
m d9
s c7
m d7
s a2
m a3
s d7
m d8
s a3
m b4
s a5
m d5
s a4
m b5
s e10
m e8
s b4
m c5
s d8
m e9
s f6
m e6
s d5
m d3
r d8 d4
x e8
s d9
m d8
s d3
m d7
s c5
m c4
s d7
m d6
s g9
m e7
s g11
m g8
s c4
m b3
s g8
m g7
s b5
m e8
s g7
m e5
s e8
m h8
r a4 e8
x e6
s b6
m c6
s b3
m b2
s c6
m c3
s d8
m d7
s c3
m c1
r c3 c7
x e9
s e7
m e6
s d6
m f8
s d7
m d5
s e5
m d4
s d5 
m f5
r d5 d9
x f5
s d4
m a4
s h8
m c3
s f8
m i8
s c3
m c4
s i8
m h7
s e6
m e4
r c3 g7
x e4
")

// #play(commands, black-first: true)
#record(commands)