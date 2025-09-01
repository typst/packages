#import "@preview/pointless-size:0.1.1": zh
#import "../utils/header.typ": header-content
#import "@preview/i-figured:0.2.4"

// Function to generate List of Figures
#let list-of-figures() = {  
  set page(numbering: "I")
  set page(header: header-content("图目录"))
  
  // 使用 outlined: false 防止标题出现在目录中
  align(center, heading("图目录", numbering: none, outlined: false))
  
  // Set the styling for the list of figures
  set text(size: zh(5))  // 五号字
  
  // Use outline with filter for figures only
  i-figured.outline(title: none,target-kind: "image")
}

// Function to generate List of Tables
#let list-of-tables() = {
  set page(numbering: "I")
  set page(header: header-content("表目录"))
  
  // 使用 outlined: false 防止标题出现在目录中
  align(center, heading("表目录", numbering: none, outlined: false))
  
  // Set the styling for the list of tables
  set text(size: zh(5))  // 五号字
  
  // Use outline with filter for tables only
  i-figured.outline(title: none,target-kind: table)

} 