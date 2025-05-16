#import "template.typ": create_document

#let thesis(
  // Document basics
  title: none,
  authors: (),
  matriculation_numbers: (),
  date: none,
  documentType: none,
  
  // University information
  faculty: none,
  module: none,
  course_of_studies: none,
  
  // Supervision details
  supervisor1: none,
  supervisor2: none,
  supervisor3: none,
  
  // Company information
  company: none,
  company_supervisor: none,
  
  // Content metadata
  abstract: none,
  keywords: (),
  
  // Document settings
  include_declaration: true,
  lang: "en",
  
  // Typography settings (with sensible defaults)
  font: "New Computer Modern",
  font_size: 11pt,
  line_spacing: 1.5,

  // Code highlighting
  enable_code_highlighting: true,
  
  // Layout settings
  lower_chapter_headings: false,
  
  body
) = {
  // Handle case where a single string is passed instead of array
  let authors_array = if type(authors) == str { (authors,) } else { authors }
  let matriculation_numbers_array = if type(matriculation_numbers) == str { (matriculation_numbers,) } else { matriculation_numbers }
  let keywords_array = if type(keywords) == str { (keywords,) } else { keywords }
  
  create_document(
    title: title,
    authors: authors_array,
    matriculation_numbers: matriculation_numbers_array,
    date: date,
    documentType: documentType,
    faculty: faculty,
    module: module,
    course_of_studies: course_of_studies,
    supervisor1: supervisor1,
    supervisor2: supervisor2,
    supervisor3: supervisor3,
    company: company,
    company_supervisor: company_supervisor,
    abstract: abstract,
    keywords: keywords_array,
    include_declaration: include_declaration,
    lang: lang,
    font: font,
    font_size: font_size,
    line_spacing: line_spacing,
    enable_code_highlighting: enable_code_highlighting,
    lower_chapter_headings: lower_chapter_headings,
    body
  )
}