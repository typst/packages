#import "/src/constants/document-settings-constants.typ": DEFAULT-PARAGRAPH-SPACING-SIZE

// Başlıklardaki boşluk stili. [Heading spacing style.]
#let heading-spacing-style(content) = {
  // Başlıkların paragrafındaki satırlar arasındaki boşluk miktari 1.5 satır aralığı olacak şekilde ayarlandı. [The line spacing between the lines in the heading's paragraph is set to 1.5 line spacing.]
  show heading: set par(leading: 0.75em)

  // 1. düzey başlıklardan önce boşluk yok ve sonrasında 12pt boşluk var. [There is no space before level 1 headings and 12pt space after.]
  show heading.where(level: 1): set block(above: 0pt, below: DEFAULT-PARAGRAPH-SPACING-SIZE + 0.5em)

  // Başlıktan önceki paragraftan sonra Word'de olduğu gibi boşluk bırakılmadığı için o boşluk burada eklendi. Başlıktan sonraki ilk paragrafında satırlar arasındaki boşluğu 1,5 satır aralığı olduğu ama Word'de olduğu gibi boşluk bırakılmadığı için o boşluk burada eklendi. [The space between the paragraphs in the Word is not left blank, so this space is added. The space between the lines in the first paragraph after the heading is 1.5 line spacing, but the space is not left blank as in Word, so this space is added.]
  show heading
    .where(level: 2)
    .or(heading.where(level: 3))
    .or(heading.where(level: 4))
    .or(heading.where(level: 5))
    .or(heading.where(level: 6)): set block(above: DEFAULT-PARAGRAPH-SPACING-SIZE, below: 0.5em)

  content
}
