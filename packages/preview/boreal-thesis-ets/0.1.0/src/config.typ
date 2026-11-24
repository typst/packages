// ============================================================
// thETS — Constantes de mise en page (portage Typst du gabarit
// LaTeX thETS.cls de l'École de technologie supérieure).
//
// Toutes les valeurs imposées par le décanat sont regroupées ici.
// Ne pas les modifier sans validation du service de rédaction.
// ============================================================

// ---- Format et marges ------------------------------------------------------
// geometry LaTeX : top=1.5in, left=1.5in (intérieur), right=0.75in (extérieur),
// bottom=0.75in, headsep=0.75in.
#let paper = "us-letter"
#let margin-top = 1.5in
#let margin-inside = 1.5in
#let margin-outside = 0.75in
#let margin-bottom = 0.75in
#let headsep = 0.75in

// L'en-tête (folio seul) est placé à 0.75in du bord, donc à 0.75in au-dessus
// de la zone de texte qui commence à 1.5in.
#let header-ascent = headsep

// Largeur utile de la zone de texte (\textwidth LaTeX).
#let text-width = 8.5in - margin-inside - margin-outside

// ---- Corps de texte --------------------------------------------------------
// Le gabarit LaTeX compose en newtxtext (clone de Times). « Times New Roman »
// est présent sous macOS et Windows ; « Libertinus Serif » est livré avec Typst
// et sert de repli sur les autres systèmes. Remplacer par « TeX Gyre Termes »
// si la police est installée : c'est le clone de Times le plus proche.
#let font-serif = ("Times New Roman", "TeX Gyre Termes", "Libertinus Serif")
#let font-mono = ("Menlo", "DejaVu Sans Mono")
#let font-math = ("STIX Two Math", "New Computer Modern Math")

#let size-body = 12pt

// ---- Interlignes -----------------------------------------------------------
// Le gabarit LaTeX fixe \baselineskip = 14.5pt à 12pt, puis applique
// \setstretch{0.95} (interligne « simple » Word) et \setstretch{1.43}
// (interligne « 1,5 » Word).
//
// Typst mesure la hauteur de ligne de la hauteur de capitale à la ligne de
// base (top-edge: cap-height). Pour Times, cap-height = 0.662em, d'où :
//     leading = stretch * (14.5 / 12) em - 0.662 em
#let leading-single = 0.486em   // 0.95 * 1.2083 - 0.662
#let leading-onehalf = 1.066em  // 1.43 * 1.2083 - 0.662

// ---- Paragraphes -----------------------------------------------------------
#let par-spacing = 12pt   // \parskip
#let par-indent = 0pt     // \parindent

// Hauteur d'une ligne de corps (équivalent \baselineskip LaTeX à 12pt),
// utilisée pour les espacements verticaux exprimés en « lignes ».
#let baselineskip = 14.5pt

// ---- Titres ----------------------------------------------------------------
// \@seccntformat : taquet fixe de 9ex entre le numéro et le titre de section.
// 9ex ≈ 9 × 0.45em à 12pt.
#let heading-number-width = 4.05em

// Espace vertical sous le titre d'un bloc préliminaire (\ETSpreliminaryPageHeading).
#let preliminary-heading-skip = 24pt

// ---- Table des matières ----------------------------------------------------
#let toc-right-margin = 1.2cm
#let toc-hang-chapter = 6.8em
#let toc-hang-section = 3.1em
#let toc-hang-subsection = 3.7em
#let toc-hang-subsubsection = 4.3em

// ---- Figures et tableaux ---------------------------------------------------
#let figure-default-width = 0.75 * text-width
#let figure-caption-width-factor = 0.95
#let table-caption-width = 0.75 * text-width
#let caption-skip = 0.5 * baselineskip
#let source-skip = 0.3 * baselineskip

// ---- Listes d'abréviations et de symboles -----------------------------------
#let label-column-width = 3cm
