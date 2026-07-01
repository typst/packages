#let col(
  header,
  function,
  width: auto,
  align: auto,
) = {
  (
    header: header,
    func: function,
    width: width,
    align: align,
  )
}

#let tabut-cells(
  data-raw, 
  colDefs, 
  columns: auto,
  align: auto,
  index: "_index",
  transpose: false,
  headers: true,
) = {

  let data = ();
  let i = 0;
  for record in data-raw {
    let new-record = record;
    if index != none { new-record.insert(index, i); }
    data.push(new-record);
    i = i + 1;
  }

  let entries = ();
  let colWidths = ();
  let colAlignments = ();

  if transpose {
    colWidths.push(auto);
    colAlignments.push(auto);

    for record in data {
      colWidths.push(auto);
      colAlignments.push(auto); 
    }

    for colDef in colDefs {
      if headers { entries.push(colDef.header); }
      for record in data {
        entries.push([#(colDef.func)(record)])
      }
    }
  } else {
    for colDef in colDefs {
      if colDef.keys().contains("width") {
        colWidths.push(colDef.width);
      } else {
        colWidths.push(auto);
      }
      if colDef.keys().contains("align") {
        colAlignments.push(colDef.align);
      } else {
        colAlignments.push(auto);
      }
    }

    for colDef in colDefs {
      if headers { entries.push(colDef.header); }
    }

    for record in data {
      for colDef in colDefs {
        entries.push([#(colDef.func)(record)])
      }
    }
  }

  let output-named = (:)

  if columns == auto {
    output-named.columns = colWidths;
  } else if columns == none {
    // Do nothing
  } else {
    output-named.columns = columns;
  }

  if align == auto {
    output-named.align = colAlignments;
  } else if align == none {
    // Do nothing
  } else {
    output-named.align = align;
  }

  arguments(
    ..output-named,
    ..entries
  );
}

#let tabut(
  data-raw, 
  colDefs, 
  columns: auto,
  align: auto,
  index: "_index",
  transpose: false,
  headers: true,
  ..tableArgs
  ) = {
  table(
    ..tabut-cells(
      data-raw, 
      colDefs, 
      columns: columns,
      align: align,
      index: index,
      headers: headers,
      transpose: transpose,
      ),
    ..tableArgs
  )
}

#let rows-to-records(headers, rows, default: none) = {
  rows.map(r => {
    let record = (:);
    let i = 0;
    for header in headers {
      record.insert(header, r.at(i, default: default));
      i = i + 1;
    }
    record
  })
}

#let group(data, function) = {
  let groups = ();
  for record in data {
    let value = function(record);
    let group-pos = groups.position(g => g.value == value);
    if group-pos == none {
      let new-group = (value: value, group: ());
      new-group.group.push(record);
      groups.push(new-group);
    } else {
      groups.at(group-pos).group.push(record)
    }
  }
  groups.sorted(key: r => r.value)
}

#let auto-type(input) = {

  let is-int = (input.match(regex("^-?\d+$")) != none);
  if is-int { return int(input); }

  let is-float = (input.match(regex("^-?(inf|nan|\d+|\d*(\.\d+))$")) != none);
  if is-float { return float(input) }

  input
}

#let records-from-csv(input) = {
  let data = {
    let data-raw = input;
    rows-to-records(data-raw.first(), data-raw.slice(1, -1))
  }
  data.map( r => {
    let new-record = (:);
    for (k, v) in r.pairs() {
      new-record.insert(k, auto-type(v));
    }
    new-record
  })
}