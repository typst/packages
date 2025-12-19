#import "@preview/tieflied:0.1.0": annotation, author, bridge, chorus, song, songbook, verse

#let john-newton = author("John Newton", color: luma(95%))

#songbook(
  title: "Totally real and valid songs",
  songbook-author: "Tiefseetauchner",
  title-page: true,
  settings: (
    show-annotations: true,
  ),
  [
    #song(author: john-newton, title: "Amazing Grace", [
      #verse[
        Amazing grace, How sweet the sound\
        That saved a wretch like me.\
        I once was lost, but now I am found,\
        Was blind, but now I see.
      ]
    ])
    #song(author: "Tiefseetauchner", title: "Thankfully bad", [
      #verse[
        Wonderful sounds\
        Surround my brain\
        When the seratonin\
        Comes to fame
      ]
      #chorus[
        Eating chicken and fries\
        I drink icecream \
        Drinking icecream and fries\
        I like to chicken to dream
      ]
      #verse[
        In the file transfer\
        Lies the truth\
        Of what you found\
        In your youth
      ]
      #verse[
        For Jesus walked\
        Across a bridge (presumably)\
        Over the brook Chidron\
        And presumably itched
      ]
      #bridge[
        The fries dies bies tries\
        I rap text like a bad packet\
        My TCP connection dies\
        And my cat, she makes a real racket.
      ]
      #chorus[
        Eating chicken and fries\
        I drink icecream \
        Drinking icecream and fries\
        I like to chicken to dream
      ]
      #annotation("[Outro]", [
        I like cake,\
        And chicken,\
        In a cake\
        With bricks\
        Yeah
      ])
    ])
  ],
)

