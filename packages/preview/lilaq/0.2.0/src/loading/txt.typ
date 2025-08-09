
/// Parses a CSV (comma-separated values) string. This function enhances the 
/// functionality of the built-in Typst function [`csv`](https://typst.app/docs/reference/data-loading/csv/) with features like transforming
/// values to numerical (or other) types, ignoring comments and selecting only part of 
/// the data. 
/// 
/// Unlike the built-in `csv` function, this function returns the data as a list of 
/// columns and not as a list of rows. 
///
/// -> array | dictionary
#let load-txt(
  
  /// Raw data loaded from a text file via [`read()`](https://typst.app/docs/reference/data-loading/read/). 
  /// -> str
  data,
  
  /// The delimiter that separates columns in the file. 
  /// -> str
  delimiter: ",",
  
  /// The characters that indicate the start of a single-line comment.
  /// -> str
  comments: "#",
  
  /// The number of leading rows to be skipped, including comments. 
  /// -> int
  skip-rows: 0,
  
  /// Which columns to extract from the file. Expects an array of indices to columns to 
  /// extract. If `auto`, all columns are extracted. 
  /// -> auto | array
  usecols: auto,
  
  /// If true, the first line is interpreted as a header naming the individual columns. 
  /// The result is then returned as a dictionary with the headers. 
  /// -> bool
  header: false,
  
  /// Optional converter functions or types to use to convert the data entries. This
  /// can either be a single function or type that is applied to all columns likewise
  /// or a dictionary with column indices as keys and functions or types as values. 
  /// Through the (optional) key `rest`, a default converter can be specified to be used 
  /// for all columns that have no explicit converter assigned. 
  /// -> function | type | dictionary
  converters: float
  
) = {
  let rows = data.split("\n")
    .slice(skip-rows)
    .filter(row => not (row.starts-with(comments) or row == ""))

  rows = rows.map(row => row.split(delimiter))
  if rows.len() == 0 { return () }

  let len = rows.first().len()
  for (i, row) in rows.enumerate() {
    assert(row.len() == len, message: "All rows need to be of the same length but the row " + repr(row.join(delimiter)) + " does not have " + str(len) + " entries as the other ones. ")
  }
  
  if header {
    header = rows.at(0).map(str.trim)
    assert(header.dedup().len() == header.len(), message: "Duplicate entry in header")
    rows = rows.slice(1)
  }
  let cols = array.zip(..rows) 
  if type(converters) == dictionary {
    let default-converter = converters.at("rest", default: float)
    cols = range(cols.len()).map(j => {
      let converter = converters.at(str(j), default: default-converter)
      cols.at(j).map(str.trim).map(converter)
    })
  } else {
    assert(type(converters) in (function, type), message: "The converter needs to a function or a type")
    cols = cols.map(col => col.map(str.trim).map(converters))
  }

  if header == false {
    if usecols == auto { return cols }
    if type(usecols) == int { usecols = (usecols,) }
    assert(type(usecols) == array, message: "Parameter `usecols` expects an int or an array of ints")
    return usecols.map(j => cols.at(j))
  }
  assert(usecols == auto, message: "Parameter `usecols` can not be used with `header: true`, You can just partially destructure the dictionary. ")
  return header.zip(cols).to-dict()
}

#assert.eq(
   load-txt("1,2,3\n4,5,6"),
   ((1,4), (2,5), (3,6))
)
#assert.eq(
   load-txt("1, 2 , 3 \n 4, 5, 6"),
   ((1,4), (2,5), (3,6))
)
#assert.eq(
   load-txt("\n1,2,3\n4,5,6\n\n"),
   ((1,4), (2,5), (3,6))
)
#assert.eq(
   load-txt("\n1 2 3\n4 5 6", delimiter: " "),
   ((1,4), (2,5), (3,6))
)
#assert.eq(
   load-txt("1,2,3\n//a\n4,5,6\n//a", comments: "//"),
   ((1,4), (2,5), (3,6))
)
#assert.eq(
   load-txt("blablabla\n1,2\n3,4\n5,6", skip-rows: 1),
   ((1,3,5), (2,4,6))
)
#assert.eq(
   load-txt(" n, a, b\n1,2,3\n4,5,6", header: true),
   (n: (1,4), a: (2,5), b: (3,6))
)
#assert.eq(
   load-txt("1,2,3\n4,5,6", usecols: 1),
   ((2,5),)
)

#assert.eq(
   load-txt("1,2,3\n4,5,6", usecols: (0,2)),
   ((1,4), (3,6))
)


#assert.eq(
   load-txt("1,2\n4,5", converters: v => v),
   (("1","4"), ("2","5"))
)


#assert.eq(
   load-txt("1,2\n4,5", converters: ("0": v => v)),
   (("1","4"), (2,5))
)
#assert.eq(
   load-txt("1,2\n4,5", converters: ("1": v => v)),
   ((1,4), ("2","5"))
)
#assert.eq(
   load-txt("1,2\n4,5", converters: ("0": type, "1": v => v)),
   ((str, str), ("2","5"))
)

#assert.eq(
   load-txt("1,2\n4,5", converters: ("0": float, rest: v => v)),
   ((1, 4), ("2","5"))
)
