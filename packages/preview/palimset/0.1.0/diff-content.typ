#import "diff-function.typ": *
#import "@preview/touying:0.6.1": utils

#let is-text(it) = (
  it != none and (it.func() == text)
)

#let sequence-text(it, arr) = {}

#let styled-text(it, arr) = {
  if utils.is-sequence(it) {
    for val in it.children {
      arr = styled-text(val, arr)
    }
  } else if utils.is-styled(it) {
    arr = styled-text(it.child, arr)
  } else if is-text(it) {
    arr.push(it.text)
  }

  return arr
}

#let content-text(it) = {
  let output_arr = ()
  for val in it.children {
    if is-text(val) {
      output_arr.push(val.text)
    } else if utils.is-styled(val) {
      output_arr = styled-text(val.child, output_arr)
    }
  }
  return output_arr
}

#let styled-output(it, arr, format-plus, format-minus) = {
  if utils.is-sequence(it) {
    let output = ()
    for val in it.children {
      let tmp = styled-output(val, arr, format-plus, format-minus)
      output.push(tmp.at(0))
      arr = tmp.at(1)
    }
    if output.len() == 0 {
      return (none, arr)
    }
    return (output.sum(), arr)
  } else if utils.is-styled(it) {
    let output = ()
    let tmp = styled-output(it.child, arr, format-plus, format-minus)
    arr = tmp.at(1)
    return (utils.reconstruct-styled(it, tmp.at(0)), arr)
  } else if is-text(it) {
    let text_len = it.text.len()
    let start = 0
    let output = ()
    for value in range(arr.at(0).len()) {
      if arr.at(1).at(0) == 0 {
        let tmp = arr.at(0).remove(0)
        start += tmp.len()
        if start < text_len {
          let _ = arr.at(1).remove(0)
          output.push(text(tmp))
        } else {
          output.push(text(tmp.slice(0, tmp.len() + text_len - start)))
          arr.at(0).insert(0, tmp.slice(tmp.len() + text_len - start, tmp.len()))
          break
        }
      } else if arr.at(1).at(0) == 1 {
        let tmp = arr.at(0).remove(0)
        start += tmp.len()
        if start < text_len {
          let _ = arr.at(1).remove(0)
          output.push(format-plus(tmp))
        } else {
          output.push(format-plus(tmp.slice(0, tmp.len() + text_len - start)))
          arr.at(0).insert(0, tmp.slice(tmp.len() + text_len - start, tmp.len()))
          break
        }
      } else if arr.at(1).at(0) == -1 {
        let _ = arr.at(1).remove(0)
        output.push(format-minus(arr.at(0).remove(0)))
      }
    }

    return (output.sum(), arr)
  } else {
    return (it, arr)
  }
}

#let content-output(
  it,
  arr,
  format-plus,
  format-minus,
) = {
  for val in it.children {
    if is-text(val) {
      let text_len = val.text.len()
      let start = 0
      for value in range(arr.at(0).len()) {
        if arr.at(1).at(0) == 0 {
          let tmp = arr.at(0).remove(0)
          start += tmp.len()
          if start < text_len {
            let _ = arr.at(1).remove(0)
            text(tmp)
          } else {
            text(tmp.slice(0, tmp.len() + text_len - start))
            arr.at(0).insert(0, tmp.slice(tmp.len() + text_len - start, tmp.len()))
            break
          }
        } else if arr.at(1).at(0) == 1 {
          let tmp = arr.at(0).remove(0)
          start += tmp.len()
          if start < text_len {
            let _ = arr.at(1).remove(0)
            format-plus(tmp)
          } else {
            format-plus(tmp.slice(0, tmp.len() + text_len - start))
            arr.at(0).insert(0, tmp.slice(tmp.len() + text_len - start, tmp.len()))
            break
          }
        } else if arr.at(1).at(0) == -1 {
          let _ = arr.at(1).remove(0)
          format-minus(arr.at(0).remove(0))
        }
      }
    } else if utils.is-styled(val) {
      let tmp = styled-output(val.child, arr, format-plus, format-minus)
      utils.reconstruct-styled(val, tmp.at(0))
      arr = tmp.at(1)
    } else {
      val
    }
  }

  let aaa = arr
}

#let diff-content(
  a,
  b,
  format-plus: x => text(x, fill: blue, weight: "bold"),
  format-minus: x => strike(text(x, fill: red, size: 0.75em)),
  split-regex: "[^A-Za-z0-9]",
) = {
  let arr_a = content-text(a).sum()
  let arr_b = content-text(b).sum()

  let diff = diff-string-array(arr_a, arr_b, split-regex)

  content-output(b, diff, format-plus, format-minus)
}
