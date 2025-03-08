= Formatting
Avoid empty spaces between _chapter-section_, _section-sub-section_. For instance, a very brief summary of the chapter would be one way of bridging the chapter heading and the first section of that chapter.


== Page Size and Margins
Use A4 paper, with the text margins given in @table_margin_space.

#figure(
  caption: [Text margins for A4.],
  table(columns: 2, stroke: 0pt,
  
    table.hline(stroke:0.3pt),
    
    [*margin*],[*space*],
    
    table.hline(stroke:0.3pt),
    
    [top], [3.0cm],
    [bottom], [3.0cm],
    [left (inside)], [2.5cm],
    [right (outside)], [2.5cm],
    [binding offset], [1.0cm],
    
    table.hline(stroke:0.3pt),
  )
)<table_margin_space>


== Typeface and Font Sizes

*This chapter is not correct, when checking the LaTeX source, we found the the fonts that are actually used are Adobe Garamond Pro, Frutiger LT Pro, and TeX Gyre Cursor*.

The fonts to use for the reports are TeX Gyre Termes (a Times New Roman clone) for serif fonts, TeX Gyre Heros (a Helvetica clone) for sans-serif fonts, and finally TeX Gyre Cursor (a Courier clone) as mono-space font. All these fonts are included with the TeXLive 2013 installation. Table 1.2 lists the most important text elements and the associated fonts.


(sorry guys, we couldn't bother actually copying the entire table, here's an image of it)
#figure(image("figures/table_pic.png", width:100%))<table_1_2>
#v(-10pt)



=== Headers and Footers
Note that the page headers are aligned towards the outside of the page (right on the right-
hand page, left on the left-hand page) and they contain the section title on the right and the chapter title on the left respectively, in #smallcaps([SmallCaps]). The footers contain only page numbers on the exterior of the page, aligned right or left depending on the page. The lines used to delimit the headers and footers from the rest of the page are 0.4 _pt_ thick, and are as long as the text.



=== Chapters, Sections, Paragraphs
Chapter, section, subsection, etc. names are all left aligned, and numbered as in this docu-
ment.

Chapters always start on the right-hand page, with the label and title separated from the rest of the text by a 0.4pt thick line.

Paragraphs are justified (left and right), using single line spacing. Note that the first
paragraph of a chapter, section, etc. is not indented, while the following are indented.

=== Tables
Table captions should be located above the table, justified, and spaced 2.0cm from left and
right (important for very long captions). Tables should be numbered, but the numbering is
up to you, and could be, for instance:
- *Table X.Y* where X is the chapter number and Y is the table number within that chap-
ter. (This is the default in LaTeX. More on LaTeX can be found on-line, including whole books, such as [insert ref, sorry again, couldn't bother].) or
- *Table Y* where Y is the table number with the whole report (this template)

As a recommendation, use regular paragraph text in the tables, bold headings and avoid vertical lines (see @table_1_2 #sym.arrow.l since we inserted a picture instead of the actual table this is a "Figure" reference.).


=== Figures
Figure labels, numbering, and captions should be formed similarly to tables. As a recom-
mendation, use vector graphics in figures, rather than bitmaps. Text
within figures usually looks better with sans-serif fonts.



#figure(image("../assets/template/LUlogoRGB.png", width:30%), caption: [A PNG bitmap figure. The authors of the LaTeX template lobby for using vector graphics, but we think this looks perfectly good in typst.])






== Mathematical Formulae and Equations
You are free to use in-text equations and formulae, usually in _italic serif_ font. For instance:
$S = sum_i a_i$. We recommend using numbered equeations when you do need to refer to the specific equations:

$ E = integral_0^delta P(t) dif t  wide arrow.l.long.r wide E = m c^2 $

The numbering system for equations should be similar to that used for tables and figures.

== References
#show link: set text(font: "TeX Gyre Cursor", size: 11pt)

Your references should be gathered in a *References* section, located at the end of the doc-
ument (before *Appendices*). We recommend using number style references, ordered as ap-
pearing in the document or alphabetically. Have a look at the references in this template in
order to figure out the style, fonts and fields. Web references are acceptable (with restraint)
as long as you specify the date you accessed the given link [7, 2] #sym.arrow.l _not actually an reference_. You may of course use URLs directly in the document, using mono-space font, i.e. #link("http://cs.lth.se/")[http://cs.lth.se/].
Make sure you add references as close to the claim as possible [2], as shown, not at the end of a whole paragraph. Notice also that there is a space before the reference; best is to use \\cite{ref}, to allow for unbreakable spaces. References should not be used after the period marking the end of sentence. Using the reference as follows (end of paragrah, after period) is strongly discouraged, since it says nothing about which specific claim you provide
the reference for. [7]

























