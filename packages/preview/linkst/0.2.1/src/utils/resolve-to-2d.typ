/// 
/// ```typst
/// resolve-to-2d(..(1, 2, 3)) -> ((1, 2, 3),)
/// resolve-to-2d(..((1, 2, 3),)) -> ((1, 2, 3),)
/// resolve-to-2d(..((1, 2, 3), (4, 5, 6))) -> ((1, 2, 3), (4, 5, 6))
/// ```
/// 
#let resolve-to-2d(arr) = {
  if(arr == auto or arr == none) { return arr }
  else if type(arr.at(0)) == array { return arr }
  else { return (arr,) }
}