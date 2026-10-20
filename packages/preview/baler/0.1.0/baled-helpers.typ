/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

#import "validate-input.typ" : validate-input
#import "vector-calc.typ": *

#let clamp(value, min, max) = {
  let result = ()
  for i in range(value.len()) {
    if value.at(i) > max.at(i) {
      result.push(max.at(i))
    } else if value.at(i) < min.at(i) {
      result.push(min.at(i))
    } else {
      result.push(value.at(i))
    }
  }
  return result
}

#let first-guess(w-min, w-max, total) = {
  // Get a first guess of column widths based on the total width.
  // Check that the sum of minimum widths for all columns is less than the total width
  assert(w-min.sum() <= total, message: "sum of minimum column sizes exceeds the total width; default minimum size for each column is 50pt if not overriden")
  // Set the first guess to minimum widths plus the leftover width divided proportionally to the respective difference between minimum and maximum width for every column
  // $ w = w_min + (w_max - w_min)*(w_"total" - sum(w_min_i))/sum(w_max_i - w_min_i) $ 
  let w-diff = v-sub(w-max, w-min)
  // Guard against division by 0 if all widths have been set to exact values
  if w-diff.sum() == 0pt { return w-min }
  v-add(w-min, v-mul(w-diff, ((total - w-min.sum()) / w-diff.sum())))
}

#let gradient-step(element, w-min, w-max, w, base-height, ..args) = {
  // Find an appropriate step size at which increasing all columns by the same step will lead to a decrease in table height
  // w-min, w-max and w need to be arrays of the same length
  assert(w-min.len() == w-max.len() and w.len() == w-max.len())
  // Start with `step = 1pt`
  let step = 1pt
  let new-height = base-height
  while base-height == new-height {
    // Increase all widths by `step` and clamp them between `w-min` and `w-max`
    let new-widths = clamp(v-add(w, step), w-min, w-max)
    // If the step increase resulted in no widths change after clamping, return `0`
    if w == new-widths {
      return 0pt
    }
    // Otherwise, multiply `step` by `1.2` and use the closest greater or equal integer as the new `step` value to try again if the table height has not changed. The idea is to increase step by 1 for small steps and gradually grow the increase when `step` gets larger
    let step-amplify = 1.2
    step = calc.ceil(step / 1pt * step-amplify) * 1pt
    let very-big-step = 1000pt
    if step > very-big-step {
      break
    }
    new-height = measure(element(columns: new-widths, ..args)).height
  }
  // If the table height changed, return `step`
  return step
}

/// Due to the integer nature of the problem, conventional gradient is hard to calculate. Here, a gradient-ish can only take values -1, 0 or 0, 1. The gradient is calculated at the minimum width change that will change grid height. 0 denotes columns that did not need to change in order to change table height. 1 denotes columns that widened and caused table height to grow. -1 denotes columns that widened and caused table height to shrink.
#let gradient(element, w-min, w-max, w, base-height, ..args) = {
  let step = gradient-step(element, w-min, w-max, w, base-height, ..args)
  // Calculate the height at widths all increased by step, but capped by maximum widths
  let new-widths = clamp(v-add(w, step), w-min, w-max)
  let new-height = measure(element(columns: new-widths, ..args)).height
  // Decide the gradient sign by comparing the original and the new height: `1` if new height is greater than base height, `-1` otherwise
  let gradient-sign = if new-height > base-height {
    1
  } else if new-height < base-height {
    -1
  } else {
    0
  }
  // Go through each column. Increase the column width by step for all columns except this one. If it results in a height that differs from the base height, this column's gradient value is 0. Otherwise, it is what the direction of the gradient is
  let grad = ()
  for i in range(w.len()) {
    let try-widths = v-add(w, step)
    try-widths.at(i) = w.at(i)
    try-widths = clamp(try-widths, w-min, w-max)
    let try-height = measure(element(columns: try-widths, ..args)).height
    if base-height == try-height {
      grad.push(gradient-sign)
    } else {
      grad.push(0)
    }
  }
  return grad
}

#let change-widths(grad, w, w-min, w-max, K) = {
  // `K` is the change budget. The meaning of `K` is that it is the maximum total change in each direction, i.e. all columns that are widened are in total widened by at maximum `K pt` and the columns that are narrowed are narrowed by the same amount
  // Define `g` as gradient but `0, 1` converts to `-1, 1` and `0, -1` converts to `1, -1`, where `1` is for columns that need to be narrowed and `-1` is for columns that need to be widened
  let g = grad
  if grad.sum() > 0 {
    g = v-sub(v-mul(grad, 2), 1)
  } else {
    g = v-add(v-mul(grad, 2), 1)
  }
  // Calculate how much the columns that need to be widened can be widened and the same for columns that need to be narrowed. That means that for the widened columns calculate the differences between their current width and their maximum width. Same for narrow and minimum width
  let dw = ()
  let dw-nar-sum = 0pt
  let dw-wid-sum = 0pt
  for i in range(g.len()) {
    if g.at(i) == 1 {
      dw.push((w.at(i) - w-min.at(i), g.at(i), i))
      dw-nar-sum = dw-nar-sum + w.at(i) - w-min.at(i)
    } else if g.at(i) == -1 {
      dw.push((w-max.at(i) - w.at(i), g.at(i), i))
      dw-wid-sum = dw-wid-sum + w-max.at(i) - w.at(i)
    }
  }
  // Set `K` to be the minimum between `K`, the total possible widening and the total possible narrowing
  K = calc.min(K, dw-nar-sum, dw-wid-sum)
  // Set up accumulators for widening and narrowing already done
  let acc-nar = 0pt
  let acc-wid = 0pt
  // Find all of the columns that will hit their limit while changing size by going though them in order of ascending allowance, picking the direction that has a smaller accumulator so far
  dw = dw.sorted()
  // Create an array to accumulate hits
  let nw = (0,)*g.len()
  for i in range(g.len()) {
    if acc-wid >= acc-nar and dw.filter(it => {it.at(1) == 1}).len() > 0 {
      // narrow if widening acc is greater and there is narrowing to be done
      let allowance = dw.filter(it => {it.at(1) > 0}).first()
      let left = K - acc-wid
      if allowance.at(0) < left/allowance.len() {
        // if the narrowing allowance is less than narrowing left divided by the columns left to narrow, add the hit to the result array
        nw.at(allowance.at(2)) = w.at(allowance.at(2)) - allowance.at(0)*allowance.at(1)
        g.at(allowance.at(2)) = 0
        acc-nar = acc-nar + dw.remove(dw.position(it => {it == allowance})).at(0)
      } else {
        // if the current column can be narrowed without hitting the allowance, then so can the other ones, clear them from the dw array
        dw = dw.filter(it => {not dw.filter(it => {it.at(1) > 0}).contains(it)})
      }
    } else if dw.filter(it => {it.at(1) < 0}).len() > 0 {
      // otherwise widen if there is widening to be done
      let allowance = dw.filter(it => {it.at(1) < 0}).first()
      let left = K - acc-nar
      if allowance.at(0) < left/allowance.len() {
        // if the widening allowance is less than widening left divided by the columns left to widen, add the hit to the result array
        nw.at(allowance.at(2)) = w.at(allowance.at(2)) - allowance.at(0)*allowance.at(1)
        g.at(allowance.at(2)) = 0
        acc-wid = acc-wid + dw.remove(dw.position(it => {it == allowance})).at(0)
      } else {
        // if the current column can be widened without hitting the allowance, then so can the other ones, clear them from the dw array
        dw = dw.filter(it => {not dw.filter(it => {it.at(1) < 0}).contains(it)})
      }
    } else {
      // otherwise you are done
      break
    }
  }
  // For all of the widths with g = 0 (the columns that hit their limit while changing size) use the value determined in the previous step. For all of the other columns equally divide the leftover narrowing and widening between the columns left to narrow and widen
  let result = ()
  for i in range(g.len()){
    if g.at(i) == 1 {
      result.push(w.at(i) - (K - acc-nar) / g.filter(it=>{it==1}).len())
    } else if g.at(i) == -1 {
      result.push(w.at(i) + (K - acc-wid) / g.filter(it=>{it==-1}).len())
    } else {
      result.push(nw.at(i))
    }
  }
  result
}

#let change-budget(element, grad, w, w-min, w-max, ..args) = {
  // Find an appropriate change budget `k` by doing line search between the minimum change budjet `k-min` and the maximum change budjet `k-max`. Stop when the difference between the considered budgets reaches threshold `diff`
  let k-min = 0.5pt
  let k-max = 25pt
  let diff = 0.5pt
  while k-max - k-min > diff {
    // Divide the distance between them in thirds, with `k1` closer to `k-min` and `k2` closer to `k-max`
    let k1 = (2 * k-min + k-max) / 3
    let k2 = (k-min + 2 * k-max) / 3
    // `h1` is table height at `k1` and `h2` is table height at `k2`
    let h1 = measure(element(columns: change-widths(grad, w, w-min, w-max, k1), ..args)).height
    let h2 = measure(element(columns: change-widths(grad, w, w-min, w-max, k2), ..args)).height
    if h1 == h2 {
      // If the heights are equal, return `k1`
      return k1
    } else if h1 < h2 {
      // If `h1` < `h2`, set `k-max = k2` and try again
      k-max = k2
    } else {
      // If `h1` > `h2`, set `k-min = k1` and try again
      k-min = k1
    }
  }
  // If after the difference between `k-max` and `k-min` reached less than the predetermined threshold `0.5` no step value has been returned, return `k-min` if `h-min < h-max` or `k-max` otherwise 
  let h-min = measure(element(columns: change-widths(grad, w, w-min, w-max, k-min), ..args)).height
  let h-max = measure(element(columns: change-widths(grad, w, w-min, w-max, k-max), ..args)).height
  if h-min < h-max { k-min } else { k-max }
}

#let baled-element(element, columns: (), total_width: none, ..args) =  {
  // Validate that columns are a correct type
  validate-input(columns)
  
  // Convert integer columns to array
  if type(columns) == int {
    columns = (auto, ) * columns
  }

  // Convert auto columns to array of auto
  if columns in (auto, ()) {
    columns = (auto,)
  }

  // Validate that the total width is a length and account for gutters
  assert(type(total_width) == length, message: "could not determine total width")
  total_width = total_width - args.named().at("gutter", default: 0pt) * (columns.len()-1)

  // Converge input types to pairs and separate columns into minimum and maximum width values
  let w-min = ()
  let w-max = ()
  for pair in columns {
    if pair == auto {
      w-min.push(50pt)
      w-max.push(total_width)
    } else if type(pair) == length {
      w-min.push(pair.to-absolute())
      w-max.push(pair.to-absolute())
    } else {
      w-min.push(pair.at(0).to-absolute())
      w-max.push(pair.at(1).to-absolute()) 
    }
  }
  
  // let insets = args.named().at("inset", default: 0pt) * 2
    
  // Get a first guess of column widths based on the total width
  let w = first-guess(w-min, w-max, total_width)
  // Determine the initial table height
  let base-height = measure(element(columns: w, ..args)).height
  // Iterate until there is no improvement or iteration limit is reached
  let iteration-limit = 100
  for i in range(iteration-limit) {
    // Calculate gradient of table height with respect to column widths
    let grad = gradient(element, w-min, w-max, w, base-height, ..args)
    // Calculate the optimal step
    let K = change-budget(element, grad, w, w-min, w-max, ..args)
    // Calculate the new widths with the previously determined step and measure the new table height
    let nw = change-widths(grad, w, w-min, w-max, K)
    let new-height = measure(element(columns: nw, ..args)).height
    // If the new height is worse than the height from the previous step or if the widths have not changed since the previous step, return the widths from the previous step
    if w == nw or new-height > base-height {
      break 
    } else {
      // Otherwise, set the last widths and height to the new values and try again
      w = nw
      base-height = new-height
    }
  }
  element(columns: w, ..args)
} 

#let baled-grid(columns: (), ..args) =  {
  layout(size => {
    let total_width = size.width
    baled-element(grid, columns: columns, total_width: total_width, ..args)
  })
}


#let baled-table(columns: (), ..args) =  {
  layout(size => {
    baled-element(table, columns: columns, total_width: size.width, ..args)
  })
}
