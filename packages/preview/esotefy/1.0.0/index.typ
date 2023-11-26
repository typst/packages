#let brainf(text, inp: "") = {
  let list     = array(range(0, 1000)).map(a => 0)
  let col-text = 0
  let col-list = 0;
  let col-inp  = 0
  let out      = "";

  while(col-text < text.len()) {
    let char = text.at(col-text)
    if (char == ">") { 
      col-list += 1
    } else if (char == "<") {
      col-list -= 1
    } else if (char == "+") {
      list.at(col-list) = calc.rem(list.at(col-list) + 1, 256)
    } else if (char == "-") {
      list.at(col-list) = if (list.at(col-list) - 1) == -1 {
        255
      } else {
        list.at(col-list) - 1
      }    
    } else if (char == ".") {
      out += str.from-unicode(list.at(col-list))
    } else if (char == ",") {
      list.at(col-list) = str.to-unicode(inp.at(col-inp))
      col-inp = col-inp + 1
    } else if (char == "[") {
      if (list.at(col-list) == 0) {
        col-text += 1
        let m = 1
        while (m != 0 and col-text < text.len()) {
          if (text.at(col-text) == "[") {
            m += 1
          } else if (text.at(col-text) == "]") {
            m -= 1
          }
          col-text+=1
        }
      }
    } else if (char == "]") {
      if (list.at(col-list) != 0) {
        col-text -= 1
        let m = 1
        while (m != 0 and col-text < text.len()) {
          if (text.at(col-text) == "[") {
            m -= 1
          } else if (text.at(col-text) == "]") {
            m += 1
          }
          col-text -=1
        }
      }      
    }
    col-text += 1
  }
  return out
}

