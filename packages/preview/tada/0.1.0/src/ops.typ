#import "./tabledata.typ": TableData, add-expressions, subset, update-fields, stack
#import "./helpers.typ" as H


/// Performs an aggregation across entire data columns.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2, 3), b: (4, 5, 6)))
/// #to-tablex(agg(td, a: array.sum, b-average: "b.sum() / b.len()"))
/// ```
/// - td (TableData): The table to aggregate
/// - field-info (dictionary): Optional overrides to the initial table's field info.
///   This is useful in case an aggregation function changes the field's type or needs
///   a new display function.
/// - ..field-func-map (dictionary): A mapping of field names to aggregation functions or
///   expressions. Expects a function accepting named arguments, one for each field in the
///   table. The return value will be placed in a single cell.
///   - #text(red)[*Note*!] If the assigned name for a function matches an existing field,
///      _and_ a function (not a string) is passed, the behavior changes: Instead, the 
///     function must take one _positional_ argument and only receives values for the field
///     it's assigned to. For instance, in a table with a field `price`, you can easily
///     calculate the total price by calling `agg(td, price: array.sum)`. If this behavior
///     was not enabled, this would be `agg(td, price: (price: none, ..rest) => price.sum()`.
///   - Columns will have their missing (`none`) values removed before being passed to the
///     function or expression.
#let agg(td, field-info: (:), ..field-func-map) = {
  let named = field-func-map.named()
  let values = (:)
  let cleaned-data = H.dict-from-pairs(
    td.data.keys().zip(td.data.values().map(arr => arr.filter(v => v != none)))
  )
  for (field, func) in named {
    let result = none
    if type(func) == function and field in td.data {
      // Special behavior described in docstring
      result = func(td.data.at(field))
    } else {
      result = H.eval-str-or-function(
        func, mode: "code", scope: cleaned-data, keyword: cleaned-data
      )
    }
    // Agg results are treated as one value, so even if they return multiple outputs,
    // it will be considered a nested array.
    values.insert(field, (result, ))
  }
  let valid-fields = td.field-info.keys().filter(field => field in named)
  let valid-field-info = H.keep-keys(td.field-info, keys: valid-fields)
  TableData(
    ..td, field-info: H.merge-nested-dicts(valid-field-info, field-info), data: values
  )
}

/// Sequentially applies a list of table operations to a given table.
///
/// The operations can be any function that takes a TableData
/// object as its first argument. It is recommended when applying many transformations
/// in a row, since it avoids the need for deeply nesting operations or keeping many
/// temporary variables.
///
/// Returns a TableData object that results from applying all the operations in sequence.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2, 3), b: (4, 5, 6)))
/// #to-tablex(chain(td,
///   filter.with(expression: "a > 1"),
///   sort-values.with(by: "b", descending: true)
/// ))
/// ```
/// - td (TableData): The initial table to which the operations will be applied.
/// - ..operations (array): A list of table operations. Each operation
///   is applied to the table in sequence. Operations must be compatible with TableData.
/// -> TableData
#let chain(td, ..operations) = {
  for op in operations.pos() {
    if type(op) == array {
      td = op.at(0)(td, ..op.slice(1))
    } else {
      td = op(td)
    }
  }
  td
}

/// Filters rows in a table based on a given expression, returning a new TableData object
/// containing only the rows for which the expression evaluates to true. This function filters
/// rows in the table based on a boolean expression. The expression is evaluated for each row, 
/// and only rows for which the expression evaluates to true are retained in the output table.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2, 3), b: (4, 5, 6)))
/// #to-tablex(filter(td, expression: "a > 1 and b > 5"))
/// ```
///
/// - td (TableData): The table to filter.
/// - expression (string): A boolean expression used to filter rows. The expression
///   can reference fields in the table and must result in a truthy output.
/// -> TableData
///
#let filter(td, expression: none) = {
  let mask = add-expressions(td, __filter: expression).data.__filter
  let out-data = (:)
  for key in td.data.keys() {
    out-data.insert(
      key,
      td.data.at(key).zip(mask)
        .filter(val-mask => val-mask.at(1))
        .map(val-mask => val-mask.at(0))
    )
  }
  TableData(..td, data: out-data)
}


/// Sorts the rows of a table based on the values of a specified field, returning a new 
/// TableData object with rows sorted based on the specified field.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2, 3), b: (4, 5, 6)))
/// #to-tablex(sort-values(td, by: "a", descending: true))
/// ```
/// - td (TableData): The table to be sorted.
/// - by (string): The field name to sort by.
/// - key (function): Optional. A function that transforms the values of the field before
///   sorting. Defaults to the identity function if not provided.
/// - descending (bool): Optional. Specifies whether to sort in descending order. Defaults
///   to false for ascending order.
/// -> TableData
#let sort-values(td, by: none, key: (values) => values, descending: false) = {
  if by == none {
    panic("`sort()` requires a field name to sort by")
  }
  let values-and-indexes = td.data.at(by).map(key).enumerate()
  let indexes = values-and-indexes
    .sorted(key: (idx-vals) => idx-vals.at(1))
    .map(idx-vals => idx-vals.at(0))
  if descending {
    indexes = indexes.rev()
  }
  let sorted-data = (:)
  for (key, column) in td.data {
    column = indexes.map(idx => column.at(idx))
    sorted-data.insert(key, column)
  }
  TableData(..td, data: sorted-data)
}

/// Creates a list of (value, group-table) pairs, one for each unique value in the
/// given field. This list is optionally condensed into one table using specified
/// aggregation functions.
///
/// ```example
/// #let td = TableData(data: (
///   a: (1, 1, 1, 2, 3, 3),
///   b: (4, 5, 6, 7, 8, 9),
///   c: (10, 11, 12, 13, 14, 15)
/// ))
/// #let first-group = group-by(td, by: "a").at(0)
/// Group identity: #repr(first-group.at(0))
/// #to-tablex(first-group.at(1))
/// Aggregated:
/// #to-tablex(group-by(td, by: "a", aggs: (count: "a.len()")))
/// 
/// ```
///
/// - td (TableData): The table to group
/// - by (string): The field whose values are used for grouping.
/// - aggs (dictionary): (field -> function) aggregations. They are applied to each group
///   and the results are concatenated into a single table. See @@agg() for behavior and
///   accepted values.
/// - field-info (dictionary): Optional overrides to the initial table's field info.
/// -> array, TableData
#let group-by(td, by: none, aggs: (:), field-info: (:)) = {
  let groups = td.data.at(by).dedup()
  let group-agg = groups.map(group-value => {
    let filtered = filter(td, expression: by + " == " + repr(group-value))
    if aggs.len() == 0 {
      return filtered
    }
    let agg-td = agg(filtered, ..aggs, field-info: field-info)
    let cur-group-info = td.field-info.at(by) + (values: (group-value, ))
    let updated-field = (:)
    updated-field.insert(by, cur-group-info)
    // Take a subset to ensure group comes first
    return chain(
      agg-td,
      update-fields.with(..updated-field),
      subset.with(fields: (by, ..aggs.keys())),
    )
  })
  if aggs.len() > 0 {
    let dummy-data = H.default-dict((by,) + aggs.keys(), value: ())
    let initial = TableData(data: dummy-data)
    return group-agg.fold(initial, stack)
  } else {
    return groups.zip(group-agg)
  }
}
