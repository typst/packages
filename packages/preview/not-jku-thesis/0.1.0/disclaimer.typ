#let disclaimer(
  date: "",
  place-of-submission: "Place",
  thesis-type: "",
  author: "",
  submissionDate: none,
) = {

  // --- Disclaimer ---
 
  text("SWORN DECLARATION", weight: 600, size: 1.4em)

  v(1.5em)
  [
I hereby declare under oath that the submitted #thesis-type's Thesis has been written solely by me without any third-party assistance, information other than provided sources or aids have not been used and those used have been fully documented. Sources for literal, paraphrased and cited quotes have been accurately credited.
  
The submitted document here present is identical to the electronically  submitted text document.




  #v(25mm)
  // Option 1
  #grid(
      columns: 2,
      gutter: 1fr,

      overline[#sym.wj #sym.space #sym.space #sym.space #sym.space (Place, Date) #sym.space #sym.space #sym.space #sym.space #sym.wj],
      overline[#sym.wj #sym.space #sym.space #sym.space #sym.space #sym.space (#author) #sym.space #sym.space #sym.space #sym.space #sym.space #sym.wj]
    )

  // Option 2
  // #place-of-submission, #date.display()
  // #align(center)[
  //   #overline[#sym.wj #sym.space #sym.space #sym.space #sym.space #sym.space (#author)   #sym.space #sym.space #sym.space #sym.space #sym.space #sym.wj]
  // ]
  
  // Option 3
  // #align(center)[
  //   #overline[#sym.wj #sym.space #sym.space #sym.space #sym.space #sym.space #place-of-submission, #date.display()\; (#author)   #sym.space #sym.space #sym.space #sym.space #sym.space #sym.wj]
  // ]

  #v(15%)


  ]
pagebreak()
  
}
