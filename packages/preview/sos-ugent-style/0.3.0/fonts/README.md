# About the included UGent Panno Text fonts
The UGent Panno Text **is property of Ghent University.**
These fonts can **only be used for tasks related to UGent purposes, by UGent staff**.
Specifically, my interpretation is that **students cannot use this font** for
their dissertation, but sometimes faculties [propose or demand this nonetheless?](
https://www.ugent.be/fw/nl/voor-studenten/reglementen/algemene-richtlijnen-masterproef-2024-2025)

They are packaged here since the goal of this template is to be easy in use,
certainly also for the creation of course materials, slides and UGent documents.
The secondary goal of this template is to be reproducible (using Guix), thus
all files needed to produce the result need to be available.
(My hope is that Ghent University - while still retaining the rights over its
branding - shares this concern for reproducibility in (scientific) documents.)

These fonts can already be found online elsewhere:
- https://github.com/Dherse/masterproef/tree/main/fonts
- https://github.com/merlijn-sebrechts/masterproef-template/tree/main/fonts (outdated fonts)
- https://github.com/niknetniko/ugent2016
- ...

# Font usage in Typst
## In the document
Although Typst makes it easy to style different elements in different fonts
if wanted, it is encouraged to use the same font in the whole document.
However, in this template, special care is taken to keep the following easy*:
- Select the coverpage title font
- Select the coverpage subtitle font
- Select the coverpage text font
- Select the document headings font
- Select the document text font
When no font is specified, this template uses "Liberation Sans".
This is different from the Typst default.
At the moment, a `font` argument is used. See `../src/DESIGN_RATIONALE.md`
for how & why the template is designed this way.

*Remark that these capabilities stem purely from Typst itself, but keeping
it easy to differentiate between the coverpage & document body, while providing
a different default is at the moment not obvious.

## Using Guix
This template supports using Guix to create bit-for-bit reproducible documents.
The fonts cannot be installed using Typst alone, either you install them
manually (see Typst documentation) OR you use guix to incorporate this template
and the used fonts in 1 reproducible whole. The guix package for the proposed
fonts is indicated further down.
TODO: instructions

# Possible fonts
There are two large groups of fonts: Serif and Sans-serif.

## Groups
### Serif fonts (Dutch: geschreefde letters)
For **longer** pieces of text when they are printed **on paper**.
They have small projecting features at the letterform edges.

### Sans-serif fonts (Dutch: ongeschreefde letters, schreefloos)
For digital documents which are read **on a screen**. Also for short texts on paper.
Should also be easier to read for dyslexic people, but if you consciously target or
work with dyslexic people, consider using [OpenDyslexic](https://opendyslexic.org/).
When submitting on paper *and* digitally, use this family.

### Others
There are also monospaced fonts, ...
The distinction doesn't end at (sans-)serif.

## Proposed fonts
According to the UGent styleguide, the preference is:
1. UGent Panno Text
2. Arial
3. For Korean: Seoul NamSam (free)

These are all sans-serif.

But, these are non-free and not suited for student dissertations.
An alternative proposal is:
1. Liberation          (~ Arial)
2. Libertinus          (Typst default, Arial alternative)
3. New Computer Modern (professional LaTeX look)

These are all families with both serif & sans-serif versions.

### UGent Panno Text
See intro and the UGent styleguide.
**Nonfree, only for UGent staff for UGent purposes.**
- Guix: Included in this package
- License: Nonfree
- Category: Sans-serif

### Arial
While the font is proposed in many works around how to write your dissertation,
the font is actually not free to use (using the GNU definition).
Since most users use Windows or maybe because they study at UGent (TODO: check the particulars),
they can in practice use them without any problems.
- Guix (channel nonguix): font-microsoft-arial
- License: Nonfree (https://corefonts.sourceforge.net/eula.htm)
- Category: Sans-serif

### Liberation
> The Liberation font family aims at metric compatibility with Arial, Times New Roman, and Courier New.
- Guix: font-liberation
- License: SIL OFL 1.1
- Category: font family (both serif & sans-serif)

### Libertinus
The font "libertinus serif" is the default in Typst.
Based on the abandoned Linux Libertine project, which is designed to be
an alternative for Times/Times New Roman and Helvetica/Arial.
- Guix: font-libertinus (abandoned: font-linuxlibertine)
- License: SIL OFL 1.1
- Category: font family (both serif & sans-serif)

### New Computer Modern (LaTeX look)
This provides the [LaTeX look of documents](https://typst.app/docs/guides/guide-for-latex-users/#latex-look).
Includes a Mono and Math font.
- Guix: texlive-newcomputermodern
- License: GUST font license 1.0 (free)
- Category: font family (both serif & sans-serif)

# Sources:
- @polleflietScorenMetJe2023[pg. 286]
- https://styleguide.ugent.be/basisprincipes/typografie.html
- https://www.ugent.be/student/nl/studeren/taaladvies/schrijven/verzorg-je-lay-out
- Enkele UGent sjablonen (2024-2025)
- https://www.ugent.be/bw/nl/voor-studenten/curriculum/masterproef/masterproefrapport
