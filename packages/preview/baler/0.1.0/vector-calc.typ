/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// Convert a value into an array of that value of the same length as other array
#let to-array(value, other-array) = {
    let result = ()
    for i in range(other-array.len()){
      result.push(value)
    }
    return result
}

// Vector addition for two arrays or an array and a value
#let v-add(a, b) = {
  assert(type(a) == array or type(b) == array)
  if not type(a) == array { a = to-array(a, b) }
  if not type(b) == array { b = to-array(b, a) }
  a.zip(b).map(it => {it.at(0)+it.at(1)})
}

// Vector subtraction for two arrays or an array and a value
#let v-sub(a, b) = {
  assert(type(a) == array or type(b) == array)
  if not type(a) == array { a = to-array(a, b) }
  if not type(b) == array { b = to-array(b, a) }
  a.zip(b).map(it => {it.at(0)-it.at(1)})
}

// Vector multiplication for two arrays or an array and a value
#let v-mul(a, b) = {
  assert(type(a) == array or type(b) == array)
  if not type(a) == array { a = to-array(a, b) }
  if not type(b) == array { b = to-array(b, a) }
  a.zip(b).map(it => {it.at(0)*it.at(1)})
}

// Vector division for two arrays or an array and a value
#let v-div(a, b) = {
  assert(type(a) == array or type(b) == array)
  if not type(a) == array { a = to-array(a, b) }
  if not type(b) == array { b = to-array(b, a) }
  a.zip(b).map(it => {it.at(0)/it.at(1)})
}
