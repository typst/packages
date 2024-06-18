#set figure(kind: figure, supplement: [Figure])

#set page(height: auto, margin: 5mm)

#import "lib.typ": minifig, subfigures, sfigure
#show: minifig

#subfigures(
  caption: [Some nature photos with photographers in the caption],
  [#sfigure(caption: [Karen Martinez], image("images/karen-martinez-nhzavzZ-42s-unsplash.jpg"))<f1:s1>],
  sfigure(caption: [Matthieu Rochette], image("images/matthieu-rochette-HIWYbjc2G4Y-unsplash.jpg")),
  sfigure(caption: [Bob Brewer], image("images/bob-brewer-aUF0M9jdnUg-unsplash.jpg"))
)<f1>

And we can reference them like normal @f1:s1 and still reference the whole figure @f1.
