#import "template.typ": create_document

#let thesis(
  // Document basics
  title: none,
  authors: (),
  matriculation-numbers: (),
  date: none,
  document-type: none,
  
  // University information
  faculty: none,
  module: none,
  course-of-studies: none,
  
  // Supervision details
  supervisor1: none,
  supervisor2: none,
  supervisor3: none,
  
  // Company information
  company: none,
  company-supervisor: none,
  
  // Content metadata
  abstract: none,
  keywords: (),
  
  // Document settings
  include-declaration: true,
  lang: "en",
  
  // Typography settings (with sensible defaults)
  font: "New Computer Modern",
  font-size: 11pt,
  line-spacing: 1.5,

  // Code highlighting
  enable-code-highlighting: true,
  
  // Layout settings
  lower-chapter-headings: false,
  
  body
) = {
  // Handle case where a single string is passed instead of array
  let authors-array = if type(authors) == str { (authors,) } else { authors }
  let matriculation-numbers-array = if type(matriculation-numbers) == str { (matriculation-numbers,) } else { matriculation-numbers }
  let keywords-array = if type(keywords) == str { (keywords,) } else { keywords }
  
  create_document(
    title: title,
    authors: authors-array,
    matriculation-numbers: matriculation-numbers-array,
    date: date,
    document-type: document-type,
    faculty: faculty,
    module: module,
    course-of-studies: course-of-studies,
    supervisor1: supervisor1,
    supervisor2: supervisor2,
    supervisor3: supervisor3,
    company: company,
    company-supervisor: company-supervisor,
    abstract: abstract,
    keywords: keywords-array,
    include-declaration: include-declaration,
    lang: lang,
    font: font,
    font-size: font-size,
    line-spacing: line-spacing,
    enable-code-highlighting: enable-code-highlighting,
    lower-chapter-headings: lower-chapter-headings,
    body
  )
}