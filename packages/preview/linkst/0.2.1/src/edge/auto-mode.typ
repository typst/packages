/*

  supported modes:
    bend: 
      * center - align to the middle orthogonal of the nodes
      * 1 - align to the start node
      * 2 - align to the end node

*/

#let auto-mode(type, mode) = {
  if mode == auto {
    if type == "bend" {
      return "center"
    }
  }
  return mode
}