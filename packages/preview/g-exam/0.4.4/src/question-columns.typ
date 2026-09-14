#import"./global.typ": *

#let __find_items(items) = {
  let groups = ()
  let group = ()
  let content-result
  let first-item = true

  for item in items.children {   
    if type(item) == content {
      for item2 in item.fields() {
        for item3 in item2 {
          if type(item3) == array {
            for item4 in item3 {
              for item5 in item4.fields() {
                if item5.at(1) == "g-question-number" {
                  // if  first-item {
                  //   first-item = false
                  // } 
                  // else {
                     groups.push(group)
                     group = ()
                  // }
                }
              }
            }
          }
        }
      } 
    
      group.push(item)}
  }

  groups.push(group)
  return  groups
}

#let __make_item(group-item) = {
  for item in group-item{
    [#item]
  }
}

#let __make_body(groups) = {
  let number-group = 0
  for group in groups {
    for item in group {
      [#item.at(0).at(0)]
    }
    number-group = number-group + 1
    if number-group < groups.len() {
      colbreak()
    }
  }
}

#let __make_groups(size-items, number-columns) = {
  let number-item = size-items.len()
  let item-by-group = calc.ceil(number-item / number-columns)

  let groups = ()

  let total-size = measure(__make_item(size-items))
  let block-height = total-size.height / number-columns

  let i = 1
  let j = 1

  while i < number-item {
    let group = ()
    let group-size-height = 0pt
    while group-size-height <= block-height and j <= number-item {
      group = size-items.slice(i, j)
      let group-make = __make_item(group)
      group-size-height = measure(group-make).height
      j = j + 1 
    }
    i = j - 1
    groups.push(group)
  }

  return groups
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
/// 
/// - max-columns: Maximum number of columns.
/// - gutter: The size of the gutter space between each column.
/// - body (string, content): Body of question and subquestion list.
#let questions-columns(
  max-columns: 10000,
  gutter: 4% + 0pt,
  body,
  ) = {
  context {
    let show-solution = __g-show-solution.final()

    let content-size = measure(body)
    layout(layout-size => {
      let number-question = body.children.filter(item => {
        return true
      })
      let number-column = calc.min(max-columns, calc.max(1, calc.trunc(layout-size.width / content-size.width)))
      // [layout-size.width: #layout-size.width \ ]
      // [content-size.width: #content-size.width \ ]
      // [#calc.trunc(layout-size.width / content-size.width) \ ]
      // [#(layout-size.width / content-size.width) \ ]
      // [number-column: #number-column \ ]      

      // [ ----------------------------------------------- \ ]
      //   let first-item = true
      //   for item in body.children { 
      //     [item: #item : #type(item) \ ] 
      //     if type(item) == content {
      //       for item2 in item.fields() {
      //         [item2: #item2 : #type(item2) \ ]  
      //         for item3 in item2 {
      //           if type(item3) == array {
      //             for item4 in item3 {
      //               for item5 in item4.fields() {
      //                 if item5.at(1) == "g-question-number" {
                        
      //                   // if  first-item {
      //                   //   first-item = false
      //                   // } 
      //                   // else {
      //                     [Cambio de grupo  --------------------- \ ]
      //                     // groups.push(group)
      //                     // group = ()
      //                   // }
      //                 }
      //               }
      //             }
      //           }
      //         }
      //       } 
          
      //       // group.push(item)
      //       [Carga Item \ ]
      //     }
      //   }
      //   [ ----------------------------------------------- \ ]
      
      if number-column == 1 {
        body
      }
      else {
        let items = __find_items(body)
        number-column = calc.min(number-column, items.len())

        let size-items = items.map(item => {
          let content = __make_item(item)
          (item, measure(content))
        })

      let number-item = size-items.len()
      let total-size = measure(__make_item(size-items))
    
      // {
      //   let block-height = total-size.height / number-column

      //   let i = 1
      //   let j = 1

      //   [number-item: #number-item \ ]
      //   while i < number-item {
      //     let group = ()
      //     let group-size-height = 0pt
      //     while group-size-height <= block-height and j <= number-item {
      //       // groups.push([a])
      //       group = size-items.slice(i, j)
      //       let group-make = __make_item(group)
      //       group-size-height = measure(group-make).height
      //       [i: #i, j: #j \ ]
      //       j = j + 1 
      //     }
      //     i = j - 1
      //     // groups.push(group)
      //     // [aa #__make_item(group)]
      //     [---- \ ]
      //     [group.len() #group.len() \ ]
      //     for aa in group {
      //       [+ #aa.at(0).at(0)]
      //     }
      //   }
      // }

        let groups = __make_groups(size-items, number-column)
        let body-groups = __make_body(groups)

        columns(number-column, gutter: gutter, body-groups) 
      }
    })
  }
}
