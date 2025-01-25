#import "../src/nassi.typ"

#set page(width: auto, height: auto, margin: 5mm)

#nassi.diagram(
  width: 12cm,
  theme: nassi.themes.greyscale,
  ```
  function inorder(tree t)
    if t has left child
      inorder(left child of t)
    end if
    process(root of t)
    if t has right child
      inorder(right child of t)
    end if
  endfunction
  ```,
)
