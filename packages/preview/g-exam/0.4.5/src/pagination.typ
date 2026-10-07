#import"./global.typ": *

#let __g-questions-pages(
  items,
) = {
  layout(size => {
    // `size.height` es la altura disponible para el contenido.
    let available-height = size.height

    let header-height = measure(width: size.width, page.header).height 
    let footer-height = measure(width: size.width, page.footer).height 

    // Medimos todas las preguntas con el ancho real disponible.
    let measured-items = items.map(item => (
      item: item,
      height: measure(width: size.width, item).height,
    ))

    let pages = ()
    let current-page = ()
    let current-height = 0pt

    for entry in measured-items {
      let item = entry.item
      let item-height = entry.height

      if item-height > available-height {
        if current-page.len() > 0 {
          pages.push(current-page)
          current-page = ()
          current-height = 0pt
        }

        pages.push((item,)) 
      }
      // El elemento cabe en una página, pero no en la actual.
      else if (
        current-page.len() > 0
        and current-height + item-height + header-height + footer-height> available-height
      ) {
        pages.push(current-page)

        current-page = (item,)
        current-height = item-height
      }
      // El elemento cabe en la página actual.
      else {
        current-page.push(item)
        current-height += item-height
      }
    }

    // Guardar la última página.
    if current-page.len() > 0 {
      pages.push(current-page)
    }

    // Renderizar las páginas.
    for (i, page-items) in pages.enumerate() {
      for item in page-items {
        item
      }

      if i < pages.len() - 1 {   
        colbreak()
      }
    }
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
      min-height = height-n 
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
  reserved-height: 30pt,
) = {
  layout(size => {
    let (number-column, item-max-width, items-size-height) = __g-columns-width(size, max-columns, items)

    let header-height = measure(width: size.width, page.header).height 
    let footer-height = measure(width: size.width, page.footer).height 

    if number-column > 1 {
      // Varias columnas en la misma página.
      let partition-array = __g-linear-partition(items, number-column)

      columns(
        number-column,
        {
          let n = 1

          for items-partition in partition-array {
            for item in items-partition {
              item
            }

            if n < number-column {
              n += 1
              colbreak()
            }
          }
        },
      )
    } else {
      // Una única columna.
      //
      // Calculamos previamente qué elementos caben en cada página.
      let available-height = size.height - reserved-height

      let pages = ()
      let current-page = ()
      let current-height = 0pt

      // Medimos todos los elementos una sola vez.
      let measured-items = items.map(item => (
        item: item,
        height: measure(
          width: size.width,
          item,
        ).height,
      ))

      for entry in measured-items {
        let item = entry.item
        let item-height = entry.height

        // El elemento ocupa más que una página completa.
        //
        // No hacemos un salto antes de él porque eso produciría
        // una página vacía. Typst podrá fragmentarlo.
        if item-height > available-height {
          if current-page.len() > 0 {
            pages.push(current-page)
            current-page = ()
            current-height = 0pt
          }

          pages.push((item,))
        }

        // No cabe en la página actual, pero sí en una página completa.
        else if (
          current-page.len() > 0
          and current-height + item-height + header-height + footer-height > available-height
        ) {
          pages.push(current-page)

          current-page = (item,)
          current-height = item-height
        }

        // Cabe en la página actual.
        else {
          current-page.push(item)
          current-height += item-height + 10pt
        }
      }

      // Última página.
      if current-page.len() > 0 {
        pages.push(current-page)
      }

      // Renderizamos las páginas.
      for (page-index, page-items) in pages.enumerate() {
        for item in page-items {
          item
        }

        if page-index < pages.len() - 1 {
          colbreak()
        }
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
