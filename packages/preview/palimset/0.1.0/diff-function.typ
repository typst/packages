#let lcs-getv-status(v_minus, v_plus) = {
  if (v_minus.p == none) and (v_plus.p == none) {
    return 0
  }
  if v_minus.p == none {
    return 1
  }
  if v_plus.p == none {
    return 2
  }

  if (v_minus.x < v_plus.x) {
    return 1
  } else {
    return 2
  }
}


#let lcs-character(a, b) = {
  let a_num = a.len()
  let b_num = b.len()
  let all_num = a_num + b_num
  let v = range(all_num + 3).map(n => (x: 0, y: 0, p: none))

  let offset = b_num + 1

  for d in range(all_num) {
    let k_max = d
    let k_min = d
    if (d > a_num) { k_max = a_num - (d - a_num) }
    if (d > b_num) { k_min = b_num - (d - b_num) }

    for k in range(-k_min, k_max, step: 2) {
      let index = offset + k
      let x = 0
      let y = 0
      let parent = none
      let check = lcs-getv-status(v.at(index - 1), v.at(index + 1))

      if check == 0 {
        x = 0
        y = 0
        parent = (x: 0, y: 0, p: none)
      } else if check == 1 {
        x = v.at(index + 1).x
        y = v.at(index + 1).y + 1
        parent = v.at(index + 1)
      } else if check == 2 {
        x = v.at(index - 1).x + 1
        y = v.at(index - 1).y
        parent = v.at(index - 1)
      }

      while (x < a_num) and (y < b_num) and (a.at(x) == b.at(y)) {
        x += 1
        y += 1
      }
      v.at(index) = (x: x, y: y, p: parent)

      if (a_num <= x) and (b_num <= y) {
        return (v.at(index), d)
      }
    }
  }
}

#let lcs-output(a, b) = {
  let tree = lcs-character(a, b)
  let output = ()
  let output_int = ()

  let total_d = tree.at(1)

  let now_tree = tree.at(0)
  let x = 0
  let y = 0
  let x_bef = 0
  let y_bef = 0
  let match = 0
  let check = 0

  let a_rev = a.rev()
  let b_rev = b.rev()

  for d in range(total_d, 0, step: -1) {
    x = now_tree.x
    y = now_tree.y
    now_tree = now_tree.p
    x_bef = now_tree.x
    y_bef = now_tree.y

    if (y - y_bef == x - x_bef) {
      check = 0
    } else if (y - y_bef > x - x_bef) {
      check = 1
    } else {
      check = 2
    }

    if (y - y_bef > 0) and (x - x_bef > 0) {
      if check == 1 {
        match = x - x_bef
      } else {
        match = y - y_bef
      }
    } else {
      match = 0
    }

    if match != 0 {
      output.insert(0, a_rev.slice(0, match).rev())
      output_int.insert(0, 0)
      a_rev = a_rev.slice(match, a_rev.len())
      b_rev = b_rev.slice(match, b_rev.len())
    }

    if check == 1 {
      output.insert(0, b_rev.first())
      output_int.insert(0, 1)
      b_rev = b_rev.slice(1, b_rev.len())
    }
    if check == 2 {
      output.insert(0, a_rev.first())
      output_int.insert(0, -1)
      a_rev = a_rev.slice(1, a_rev.len())
    }
  }

  let bef = output_int.at(0)
  let str = none
  let output2 = ()
  let output_int2 = ()

  for value in range(output_int.len()) {
    if output_int.at(value) == bef {
      str += output.at(value)
    } else {
      output2.push(str)
      output_int2.push(output_int.at(value - 1))
      str = output.at(value)
      bef = output_int.at(value)
    }
  }

  output2.push(str)
  output_int2.push(output_int.last())

  for value in range(output2.len()) {
    let tmp = output2.at(value)
    if type(tmp) == array {
      output2.at(value) = tmp.sum()
    }
  }

  return (output2, output_int2)
}

#let split_words(str, reg) = {
  let reg1 = regex(reg)

  let str_arr = str.clusters()
  let output_arr = ()
  let str = ""

  for char in str_arr {
    if reg1 in char {
      str += char
      output_arr.push(str)
      str = ""
    } else {
      str += char
    }
  }

  if str != "" {
    output_arr.push(str)
  }

  return output_arr
}

#let diff-string-array(
  a,
  b,
  reg,
) = {
  let a_words = split_words(a, reg)
  let b_words = split_words(b, reg)
  let output = lcs-output(a_words, b_words)
  return output
}

#let diff-string(
  a,
  b,
  format-plus: x => text(x, fill: blue, weight: "bold"),
  format-minus: x => strike(text(x, fill: red, size: 0.75em)),
  split-regex: "[^A-Za-z0-9]",
) = {
  let data = diff-string-array(a, b, split-regex)

  for value in range(data.at(0).len()) {
    let contents = data.at(0).at(value)
    let number = data.at(1).at(value)
    if number == 0 {
      text(contents)
    } else if number == 1 {
      format-plus(contents)
    } else {
      format-minus(contents)
    }
  }
}
