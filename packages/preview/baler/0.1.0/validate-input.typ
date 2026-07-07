/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// Validate the column size value is valid for one column
// It should be either auto, a positive length, or an array of two positive lengths in ascending order
#let validate-column-size((i, width)) = {
  if type(width) != type(auto) and type(width) != length and type(width) != array {
    return "expected auto, length, or array in column "+str(i)+" size"
  }
  if type(width) == length and width <= 0pt { 
    return "expected positive length in column "+str(i)+" size" 
  }
  if type(width) == array {
    if width.len() != 2 {
      return "expected 2 values in column "+str(i)+" size array"
    }
    if type(width.at(0)) != length or type(width.at(1)) != length {
      return "expected array values of type length in column "+str(i)+" size"
    }
    if width.at(0) > width.at(1) {
      return "expected minimum value to be less or equal to the maximum value in column "+str(i)+" size"
    }
    if width.at(0) <= 0pt {
      return "expected positive length in column "+str(i)+" size array"
    }
    
  }
  return ""
}

// Assert that all inputs in the input array are valid
#let validate-input(input) = {
  if type(input) in (int, length, type(auto)) { return }
  assert(type(input) == array, message: "expected an array, auto, length, or an integer")
  if input.len() == 0 { return }
  let errors = input.enumerate().map(validate-column-size).filter(it=>{it != ""}).join("; ")
  if errors == none {errors = ""} else {errors = errors.replace(regex("e"), it => {upper(it.text)}, count: 1)}
  assert(errors == "", message: errors)
}

// Test the input validation
#let test-validate-input() = {
  let wrong-type = "hello"
  let wrong-array = ((-10pt, 10pt), (10pt, 20pt), (30pt, 20pt), -30pt, 40pt, 5, "hello", 10em, auto, (10pt, "hello"))
  let right-type = 7
  let right-array = ((10pt, 20pt), 40pt, auto)
  validate-input(right-type)
  validate-input(right-array)
  validate-input(wrong-type)
  validate-input(wrong-array)
}

//#test-validate-input()
