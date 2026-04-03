  
#let tud-footnote(
  footnote_rewritten_fix_alignment_hanging_indent: true, 
  it
) = {  
  if footnote_rewritten_fix_alignment {
    let loc = it.note.location()
    let it_counter_arr = counter(footnote).at(loc)
    let idx_str = numbering(it.note.numbering, ..it_counter_arr)
    //[#it.fields()]

    stack(dir: ltr, 
      h(5pt),
      super(idx_str),
      {
        // optional add indent to multi-line footnote
        if footnote_rewritten_fix_alignment_hanging_indent {
          par(hanging-indent: 5pt)[#it.note.body]
        }
        else {
          it.note.body
        }
      }
    )
  }
  else {
    // if not footnote_rewritten_fix_alignment keep as is
    it
  }
}