/// Format datetime or string value to readable string
#let format-date(d) = {
  if d == none { "" }
  else if type(d) == datetime { d.display("[month repr:long] [day], [year]") }
  else { str(d) }
}

/// Render institution / assignment logo inside a height-constrained box
#let render-cover-logo(logo, max-height: 2cm) = {
  if logo != none { box(max-height: max-height, logo) }
}
#let render-logo = render-cover-logo

/// Extract metadata key-value pairs cleanly as ("KEY", "Value") tuples
#let get-meta-pairs(stu-name, stu-id, instructor, date-str, university, department, semester, section, include-inst: false) = {
  let pairs = ()
  if stu-name != none {
    let id-part = if stu-id != none { " (" + str(stu-id) + ")" } else { "" }
    pairs.push(("STUDENT", str(stu-name) + id-part))
  }
  if instructor != none { pairs.push(("INSTRUCTOR", str(instructor))) }
  if date-str != none and date-str != "" { pairs.push(("DATE", str(date-str))) }
  if semester != none or section != none {
    let term = (semester, section).filter(it => it != none).join(" · ")
    pairs.push(("TERM", str(term)))
  }
  if include-inst and (university != none or department != none) {
    let inst = (university, department).filter(it => it != none).join(", ")
    pairs.push(("INSTITUTION", str(inst)))
  }
  pairs
}

/// Divider line helper
#let render-cover-divider(stroke-val) = line(length: 100%, stroke: stroke-val)
#let render-divider = render-cover-divider
