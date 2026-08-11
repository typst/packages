#import "@preview/fontawesome:0.6.0": *

//standardize icon sizes (fontawesome icon sizes sometimes seems to vary a bit) and center icons vertically/horizontally
//smaller icons are added to exceptions to shift them rightwards a bit for better visual centering (may exist a better solution?)
#let iconExceptions = ("database", "location-dot")
#let icon(name, size: 12pt, color: rgb("#190042")) = {
    let tokens = name.split(" ");
    let type = "solid";
    if(tokens.at(1, default: "solid") == "regular") { type = "regular" }

    let shift = 0pt;
    if(iconExceptions.contains(tokens.at(0))) { shift = 2pt; }

    move(dx: -(size / 2) + shift, dy: -(size / 2),
                                    block(height: size, width: size,
                                        fa-icon(tokens.at(0), fill: color, solid: type == "solid", size: size)
                                    )
                                )
}

#let parse(text) = { eval(mode: "markup", text) }

#let makeContacts((introduction)) = {
    align(center, text(font: "Cabin", size: 20pt, weight: 600, introduction.name))

    let entries = introduction.contacts.values().map(contact => {
            let displayText = text(font: "Consolas", size: 10pt, contact.displayText, baseline: -3pt)

            list(marker: icon(contact.icon, size: 10pt), body-indent: -1pt, 
                if(contact.link != "") { link(contact.link, displayText) } 
                else { displayText }
                )
            }
        )

        align(center, block(width: calc.inf * 1pt, // ignore page margin
                grid(columns: (auto, auto, auto, auto), align: (left, left, left, left), column-gutter: 30pt, row-gutter: 8pt, ..entries)))

    introduction.summary
}


#let makeSection(items, titleSize: 12pt, itemSpacing: 25pt, bodyIndent: 0.5em, paddingAbove: 4pt, paddingBelow: 8pt, boxColor: luma(240)) = {
    let entries = items.map(item => {

        let gridContent = ();

        gridContent.push(text(parse(item.title), size: titleSize));
        gridContent.push(item.duration)
        if(item.subtitle != "") { gridContent.push({item.subtitle; v(4pt)}) } else {gridContent.push(v(-4pt))}  //adjust spacing depending on if 2nd line is non-empty
        if(item.location != "") { gridContent.push({item.location; v(4pt)}) } else {gridContent.push(v(-4pt))}

        let gridRow = 2;    //if y is hardcoded as 2 and 3 in grid.cell then an empty description will cause points to have too much space above it
        if(item.description != "") {
          gridContent.push(grid.cell(x: 0, y: gridRow, colspan: 2, parse(item.description)))
          gridRow = gridRow + 1;    
        }
        
        if(item.points != "") {
            let points = item.points.map(point => parse(point));
            gridContent.push(grid.cell(x: 0, y: gridRow, colspan: 2, list(marker: "•", ..points)))
        }
        
        //each item is a list (with one point) which allows easy alignment of icon with boxed content and unique marker per item
        list(marker: (icon(item.icon)), body-indent: bodyIndent,
            box(fill: boxColor, outset: 5pt, radius: 5pt, 
                grid(columns: (1fr, 1fr), row-gutter: 8pt, align: (left, right), ..gridContent)))
    })

    //entries = entries.map(entry => block(breakable: false, entry)); // prevent entries from breaking across pages

    v(paddingAbove)
    stack(dir: ttb, spacing: itemSpacing, ..entries)
    v(paddingBelow)
}

#let makeSectionCompact(items, bodyIndent: 0.5em, rowGutter: 12pt, columnGutter: 30pt, paddingAbove: 4pt, paddingBelow: 4pt) = {
    let entries = items.map(item => {
        (parse(item.title), list(marker: icon(item.icon), body-indent: bodyIndent, parse(item.description)) )
    }).flatten()

    if(items.all(item => item.title == "")) { columnGutter = icon("").body.width / 2 } //no title column if all titles are empty
    
    v(paddingAbove)
    grid(columns: (auto, 1fr), row-gutter: rowGutter, column-gutter: columnGutter, align: (right, left), ..entries)
    v(paddingBelow)
}


#let freeCV(content) = {
  show heading.where(level: 1) : it => box([
    #place(line(stroke: gradient.linear(rgb("#807eff"), white) + 3pt, length: 100%), dy: 14pt)  //must place line before cuz can't change z-axis? (not as semantic)
    #text(font: "cabin", size: 16pt, weight: 600, it.body) #v(4pt)]
  )

  show heading.where(level: 2) : it => {text(underline(it), font: "cabin", size: 12pt); v(4pt)}

  set text(font: "Calibri", size: 11pt)
  set page(margin: 2cm)
   show link: set text(fill: blue)
  // show link: underline
  
  content
}