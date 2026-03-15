#import"./global.typ": *

#let __g-questions-pages(
  items,
) = {
      layout(size =>
      {
          let i = 1
          let item = items.at(0)
          while i < items.len() {
            item 
            let next-item = items.at(i)
            
            context {
              let item-position-height = here().position().y
              let next-item-height = measure(width: size.width, next-item).height
              let header-height = measure(width: size.width, page.header).height 
              let footer-height = measure(width: size.width, page.footer).height 
              
              if page.height < item-position-height + next-item-height + footer-height + header-height + 15pt{
                colbreak()
              }
            }
            item = next-item
            i = i + 1
          }
        item
      })
    }
    
/// Automatic adjustment of pages.
/// 
/// *Example:*
/// ```
/// #question()[This is a question]
/// 
/// #questions-pages([
/// #question()[This is a first question]
/// #question()[This is a second question]
/// ```
/// ])
/// 
/// - body (string, content): Body of question and question list.
#let questions-pages(
  ..body,
) = {
    let items = body.pos()
      
    if type(items) == content {
      items
    }
    else if type(items) == str {
      items
    } 
    else if items.len() == 1 {
      items.at(0)
    }
    else if type(items) == array {
      __g-questions-pages(items)
    }
    else {
      panic("Not implementation questions-pages of type: '" + type(items) + "'")
    }
  }

#let __g-columns-width(
    size,
    max-columns,
    items
  ) = {
  let item-max-width = 0pt
  let items-size-height = 0pt
  for item in items {
    let item-size = measure(height: size.height, item)
    item-max-width = calc.max(item-max-width, item-size.width)
    items-size-height += item-size.height
  }
  let number-column = calc.trunc((size.width + 40pt) / (item-max-width + 40pt))
  number-column = calc.max(1, number-column)
  number-column = calc.min(max-columns, number-column)
  number-column = calc.min(items.len(), number-column)

  return (number-column, item-max-width, items-size-height)
}

#let __g-initialize-partition(items, number-column) = {
    let number-items = items.len()
    let sum = 0
    let n = calc.trunc(number-items/number-column)
    sum +=5
    let partition = range(number-column).map(i => 
      {
        if i < number-column -1 {
           return n
         }
         else {
          return number-items - n * (number-column - 1)
         }
      }).rev()

    return partition
}

#let __g-partition_array(array, partition) = {  
    let partition-array = ()
    let j = 0
    for i in range(partition.len()) {
      let k = j + partition.at(i)
      partition-array.push(array.slice(j, k))
      j = k
    }
    return partition-array
}

#let __g-size_partition(partition-array) = {
    let partition-sizes = partition-array.map(items =>
    {
        return measure(columns(1,
          {
            for item in items {
              item
            }
          }))
    })
    return partition-sizes
}

#let __g-balance-partition(partition, partition-sizes) = {
  let max-height = partition-sizes.at(0).height
  let min-height = partition-sizes.at(0).height
  let max-height-position = 0
  let min-height-position = 0
  let n = 1
  while n < partition-sizes.len() {
    let height-n = partition-sizes.at(n).height
    if height-n > max-height {
      max-height-position = n
      max-height = height-n
    }
    if height-n < min-height {
      min-height-position = n
      min-height = min-height
    }
    n += 1
  }
  partition.at(min-height-position) += 1
  partition.at(max-height-position) -= 1
  
  return partition
}

#let __g-linear-partition(items, number-column) = {
    let partition = __g-initialize-partition(items, number-column)
    let partition-array = __g-partition_array(items, partition)
    let partition-sizes = __g-size_partition(partition-array)
    let size = partition-sizes.fold(0pt, (acc, partition) => calc.max(acc, partition.height))
    let size-new = 100000pt

    let n = 0
    while n < 5 {
      let partition-new = __g-balance-partition(partition, partition-sizes)
      let partition-array-new = __g-partition_array(items, partition-new)
      let partition-sizes-new = __g-size_partition(partition-array-new)
      let size-new = partition-sizes-new.fold(0pt, (acc, par) => calc.max(acc, par.height))

      if size < size-new {
        return partition-array
      }
      partition = partition-new
      partition-array = partition-array-new
      partition-sizes = partition-sizes-new
      size = size-new
      n += 1
    }
    return partition-array
}

#let __g-questions-columns(
  max-columns: 100,
  items,
  ) = {
    layout(size => {
      context {
        let (number-column, item-max-width, items-size-height) = __g-columns-width(size, max-columns, items)
       
        if number-column > 1 { // one page.         
            let partition-array = __g-linear-partition(items, number-column)

            columns(number-column,
            {
              let n = 1
              for items-partition in partition-array {
                for item in items-partition {
                  item
                }
                if n < number-column {
                  n +=1
                  colbreak()
                }
              }
            })
        } else { // one column.         
          let i = 1
          let item = items.at(0)
          while i < items.len() {
            let next-item = items.at(i)
            let next-item-height = measure(width: size.width, next-item).height
            
            item 
            context {
              let header-height = measure(width: size.width, page.header).height 
              let footer-height = measure(width: size.width, page.footer).height 

              let item-position-height = here().position().y
              if page.height < item-position-height + next-item-height + footer-height + header-height {
                colbreak()
              }
            }
            
            item = next-item
            i = i + 1
          }
          item
        }
      }
    })
   }

/// Automatic adjustment of question and subquestion lists.
/// 
/// *Example:*
/// ```
/// #question()[This is a question]
/// 
/// #questions-columns([
/// #subquestion()[This is a first subquestion]
/// #subquestion()[This is a second subquestion]
/// ])
/// ```
/// 
/// - max-columns: Maximum number of columns.
/// - gutter: The size of the gutter space between each column.
/// - body (string, content): Body of question and subquestion list.
#let questions-columns(
  max-columns: 10000,
  gutter: 4% + 0pt,
  ..body,
  ) = {
    let items = body.pos()   
      
    if type(items) == content {
      items
    }
    else if type(items) == str {
      items
    }
    else if items.len() == 1 {
      items.at(0)
    }
    else if type(items) == array {
      __g-questions-columns(items)
    }
    else {
      panic("Not implementation questions-pages of type: '" + type(items) + "'")
    }
  }
