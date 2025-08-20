#import "@local/grayness:0.1.0":* 
#let data = read("Arturo_Nieto-Dorantes.webp",encoding: none)
#set page(height: 12cm, columns: 3)

Unmodified WebP-Image:
#show-image(data, width:90%)

Grayscale:
#grayscale-image(data, width:90%)
#colbreak()

Flip (vertically):
#flip-image-vertical(data,width:90%)

Transparency:
#transparent-image(data,width:95%)

#colbreak()
Blur:
#blur-image(data, sigma: 10, width:90%)

Crop:
#crop-image(data, 100, 120, start-x: 190, start-y: 95, width: 53%)
