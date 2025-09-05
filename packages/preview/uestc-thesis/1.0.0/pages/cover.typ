#import "../thesis-vars.typ": *
#import "@preview/pointless-size:0.1.1": zh
#import "../utils/title-spilt.typ": split-long-title


#set page(
  paper: "a4",
  margin: (top: 30mm, bottom: 30mm, left: 30mm, right: 30mm),
  header-ascent: 15mm,  // 页眉距边界15mm
  footer-descent: 15mm,  // 页脚距边界15mm
)

#set text(font: ("SimSun", "Times New Roman"),size: zh(3),weight: "bold")

// Helper function to justify text by spreading characters evenly
#let justify-text(text) = {
  text.clusters().intersperse(h(1fr)).join()
}

// Function to create the title table using smart splitting
#let create-title-table(title) = {
  // Use context where we need to measure
  context {
    // Calculate available width for the title
    let available-width = measure(block(width: 100%)[]).width * 0.65
    
    // Get title info using the split-long-title function
    let title-info = split-long-title(title, available-width)
    
    if title-info.is-split {
      // Title needs to be split across two rows
      table(
        columns: (1.5fr, 4fr, 0.5fr),
        rows: (auto, auto, auto),
        stroke: 1pt,
        align: center,
        inset: 10pt,
        
        // Row 1 - Empty
        [], [], [],
        
        // Row 2 - First part of title
        [#text(font: "SimHei", size: 16pt, weight: "bold")[论文题目]], 
        [#text(font: "SimHei", size: 16pt, weight: "bold")[#title-info.first-row]], 
        [],
        
        // Row 3 - Second part of title (overflow)
        [], 
        [#text(font: "SimHei", size: 16pt, weight: "bold")[#title-info.second-row]], 
        []
      )
    } else {
      // Title fits in one row
      table(
        columns: (1.5fr, 4fr, 0.5fr),
        rows: (auto, auto, auto),
        stroke: 1pt,
        align: center,
        inset: 10pt,
        
        // Row 1 - Empty
        [], [], [],
        
        // Row 2 - Title
        [#text(font: "SimHei", size: 16pt, weight: "bold")[论文题目]], 
        [#text(font: "SimHei", size: 16pt, weight: "bold")[#title]], 
        [],
        
        // Row 3 - Empty
        [], [], []
      )
    }
  }
}

#align(top+center)[
  #table(
    columns: (1fr),
    rows: (auto),
    stroke: 1pt,
    align: center,
    inset: 0pt,

    
    // First section - School name, title and logo
    table(
      columns: (1fr),
      rows: (12%,20%,28%),
      stroke: 1pt,
      align: center+horizon,
      inset: 20pt,
      
      // Top section with school name
      [
        #text(font: "SimHei", size: 26pt, weight: "bold")[电 子 科 技 大 学]\
        #text(font: "Times New Roman", size: zh(-4))[UNIVERSITY OF ELECTRONIC SCIENCE AND TECHNOLOGY OF CHINA]
      ],
      
      // Middle section with thesis type
      [
        #text(font: "SimHei", size: 36pt, weight: "bold")[专业学位硕士学位论文]
        #text(font: "Times New Roman", size: 16pt, weight: "bold")[MASTER THESIS FOR PROFESSIONAL DEGREE]
      ],
      
      // Logo section
      [
        #image("../images/school-icon.png", width: 150pt)
      ]
    ),
    
    // Title section with potential line splitting
    create-title-table(thesis-title),
    
    
    // Information table
    table(
      columns: (1fr, 2fr, 3fr, 1fr), 
      rows: (auto, auto, auto, auto, auto),
      stroke: 1pt,
      align: (center + horizon, center + horizon),
      inset: 10pt,
      
      // Degree type - manually compressed to appear like 4 characters
      [], [#justify-text("专业学位类别")], [#text(size: 14pt)[#discipline]], [],
      
      // Student ID
      [], [#justify-text("学号")], [#text(size: 14pt)[#student-id]], [],
      
      // Author name - no spacing between characters
      [], [#justify-text("作者姓名")], [#text(size: 14pt)[#author-name]], [],
      
      // Advisor
      [], [#justify-text("指导教师")], [#text(size: 14pt)[#advisor-name #h(20pt) #advisor-title]], [],
      
      // School
      [], [#justify-text("学院")], [#text(size: 14pt)[#school-name]], []
    )
  )
]

