//// Placement functions

// Places a content in the four corners of the parent container.
// Content is quadrupled and shown with axial simmetry.
#let two-corners(body) = {
  place(top + left, body)
  place(bottom + right, rotate(180deg, reflow: true, body))
}

// Places a content in the four corners of the parent container.
// Content is quadrupled and shown with axial simmetry.
#let four-corners(body) = {
  place(top + left, body)
  place(top + right, body)
  place(bottom + left, rotate(180deg, reflow: true, body))
  place(bottom + right, rotate(180deg, reflow: true, body))
}

// Places a content in the four corners of the parent container.
// Content is quadrupled and rotated with bottom direction pointing to the center.
// Each element is rotated accordingly to the 45deg diagonal.
#let four-corners-diagonal(body) = {
  place(top + left, rotate(-45deg, reflow: true, body))
  place(top + right, rotate(45deg, reflow: true, body))
  place(bottom + left, rotate(-135deg, reflow: true, body))
  place(bottom + right, rotate(135deg, reflow: true, body))
}