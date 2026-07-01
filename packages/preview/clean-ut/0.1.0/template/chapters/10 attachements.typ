#import "@preview/clean-ut:0.1.0": *

#let attachements() = [ 

// ------change figure numbering-------
#set figure(numbering: (..ns) => numbering("S1", ..ns))
#set figure(outlined: false)
#counter(figure.where(kind: image)).update(0)

#heading([Supplementary figures], depth: 2, numbering: none)

#subfig-grid-attachments(columns:2, rows:2,
 figure(rect[#lorem(60)], 
 caption: []),<asubfigure>,
 
 figure(rect[#lorem(60)], 
 caption: []),
 
 figure(rect[#lorem(60)], 
 caption: []),
 
 figure(rect[#lorem(60)], 
 caption: []),
 
 //figure(image("Path/to/image.png"),caption: []),
 
 caption: [#caption[This is a short caption][This is a extension that is only shown in the descriptions but not in the outline]],//total caption
 label: <agreatplot>
 )


#heading([Availability of Data], numbering: none, depth: 2)
// direct download link generator for google drive files:
// https://sites.google.com/site/gdocs2direct
*The original data output from the processings, summarized in an Excel-table, is provided
on the attached CD in the print version and through* #link("https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1",[this link]) *in the PDF.*
]