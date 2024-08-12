#import "types.typ": *
#import "utils.typ": *
#import "asserts.typ": *
#import "states.typ": *

#let assert-level-cols(levels, cols, side) = {
  if (cols != auto) {
    cols = if (int == type(cols)) { cols } else if (array == type(cols)) { cols.len() } else { panic(strfmt("expected {} argument to be auto, int or array, found {}",if (side == "left") {"pre"} else {"post"} ,type(cols) )) }
    
    assert(cols >= levels, message: strfmt("max notes level on the {} is {}, but found only {} cols.",side, levels, cols))
  }
}

/// generate metadata which is needed later on
#let generate-meta(fields, args) = {
  // collect metadata into an dictionary
  let bh = fields.find(f =>  is-header-field(f))
  // check level indentation for annotations
  let (pre-levels, post-levels) = get-max-annotation-levels(fields.filter(f => is-note-field(f) ))
  assert-level-cols(pre-levels, args.side.left-cols, "left")
  assert-level-cols(post-levels, args.side.right-cols, "right")
  // check if msb value is valid 
  assert(args.msb in (left,right), message: strfmt("expected left or right for msb, found {}", args.msb))
  let meta = (
    // the total size in bits of all data-fields inside the bytefield. // todo: check if this is calculated correct if msb:left is selected.
    size: fields.filter(f => is-data-field(f) ).map(f => if (f.data.size == auto) { args.bpr /* fix: this is not consistent with how auto is handled in generate_fields */ } else { f.data.size } ).sum(),
    // the position of the msb (left | right), default: right 
    msb: args.msb,
    // number of cols for each grid.
    cols: (
      pre: pre-levels,
      main: args.bpr,
      post: post-levels,
    ),
    // contains the height of the rows. 
    rows: (
      header: auto, // !unused
      main: args.rows, // default: auto
    ),
    // contains information about the header 
    header: if (bh == none) { none } else {
      (
        fill: bh.data.format.at("fill", default: none),
        stroke: bh.data.format.at("stroke", default: none),
      )
    },
    // stores the cols arguments for annotations
    side: (
      left: (
        cols: if (args.side.left-cols == auto) { (auto,)*pre-levels } else { args.side.left-cols },
      ),
      right: (
        cols: if (args.side.right-cols == auto) { (auto,)*post-levels } else { args.side.right-cols },
      )
    )
  )
  return meta;
}

/// helper to calc number values from autofill string arguments
#let get-header-autofill-values(autofill, fields, meta) = {
  if (autofill == "bounds") {
    return fields.filter(f => is-data-field(f)).map(f => if f.data.range.start == f.data.range.end { (f.data.range.start,) } else {(f.data.range.start, f.data.range.end)}).flatten()
  } else if (autofill == "all") {
    return range(meta.size)
  } else if (autofill == "offsets") {
    let _fields = fields.filter(f => is-data-field(f)).map(f => f.data.range.start).flatten()
    _fields.push(meta.cols.main -1)
    _fields.push(meta.size -1)
    return _fields.dedup()
  } else if (autofill == "bytes") {
    let _fields = range(meta.size, step: 8)
    _fields.push(meta.cols.main -1)
    _fields.push(meta.size -1)
    return _fields.dedup()
  } else {
    ()
  }
}

/// Index all fields
#let index-fields(fields) = {
  fields.enumerate().map(((idx, f)) => {
    assert-bf-field(f)
    dict-insert-and-return(f, "field-index", idx)
  })
}

/// indexes all fields and add some additional field data
#let finalize-fields(fields, meta) = {

  // This part must be changed if the user low level api changes.
  let _fields = index-fields(fields)

  // Define some variables
  let bpr = meta.cols.main
  let range_idx = 0;
  let fields = ();

  // data fields - important! must be processed first.
  let data_fields = _fields.filter(f => is-data-field(f))
  if (meta.msb == left ) { data_fields = data_fields.rev() }
  for f in data_fields {
    let size = if (f.data.size == auto) { bpr - calc.rem(range_idx, bpr) } else { f.data.size }  
    let start = range_idx;
    range_idx += size;
    let end = range_idx - 1;
    fields.push(data-field(f.field-index, size, start, end, f.data.label, format: f.data.format))
  }

  // note fields
  for f in _fields.filter(f => is-note-field(f)) {
    let row = if (f.data.row == auto) {
      let anchor = get-index-of-next-data-field(f.field-index, _fields)
      let anchor_field = fields.find(f => f.field-index == anchor)
      int( if (meta.msb == left) { (meta.size - anchor_field.data.range.end)/bpr } else { anchor_field.data.range.start/bpr })
    } else {
      f.data.row
    }
    let data = dict-insert-and-return(f.data, "row", row)
    let field = dict-insert-and-return(f, "data", data)
    assert-note-field(field);
    fields.push(field)
  }


  // header fields  -- needs data fields already processed !!
  for f in _fields.filter(f => is-header-field(f)) {
    let autofill_values = get-header-autofill-values(f.data.autofill, fields, meta);
    let numbers = if f.data.numbers == none { () } else { f.data.numbers + autofill_values }
    let labels = f.data.at("labels", default: (:))
    fields.push(header-field(
      start: if f.data.range.start == auto { if meta.msb == right { 0 } else { meta.size - bpr } } else { assert.eq(type(f.data.range.start),int); f.data.range.start },
      end: if f.data.range.end == auto { if meta.msb == right { bpr } else { meta.size } } else { assert.eq(type(f.data.range.end),int); f.data.range.end }, 
      numbers: numbers,
      labels: labels,
      ..f.data.format,
    ))
    break // workaround to only allow one bitheader till multiple bitheaders are supported.
  }

  return fields 
}

/// generate data cells from data-fields
#let generate-data-cells(fields, meta) = {
  let data_fields = fields.filter(f => is-data-field(f))
  if (meta.msb == left ) { data_fields = data_fields.rev() }
  data_fields = data_fields
  let bpr = meta.cols.main;

  let _cells = ();
  let idx = 0;

  for field in data_fields {
    assert-data-field(field)
    let len = field.data.size

    let slice_idx = 0;
    let should_span = is-multirow(field, bpr)
    let current_offset = calc.rem(idx, bpr)

    while len > 0 {
      let rem_space = bpr - calc.rem(idx, bpr);
      let cell_size = calc.min(len, rem_space);
      
      // calc stroke
      let _default_stroke = (1pt + black)
      let _stroke = (
        top: _default_stroke,
        bottom: _default_stroke,
        rest: _default_stroke,
      )
      
      if ((len - cell_size) > 0 and data_fields.last().field-index != field.field-index) {
        _stroke.at("bottom") = field.data.format.fill
      }
      if (slice_idx > 0){
        _stroke.at("top") = none
      }

      let cell_index = (field.field-index, slice_idx)
      let x_pos = calc.rem(idx,bpr) 
      let y_pos = int(idx/bpr)

      let cell_format = (
        stroke: _stroke,
        ..field.data.format,
      )

      // adjust label for breaking fields.
      let middle = int(field.data.size / 2 / bpr)  // roughly calc the row where the label should be displayed
      let label = if (should_span or middle == slice_idx) { field.data.label } else if (slice_idx < 2 and len < bpr) { "..." } else {none}
      
      // prepare for next cell
      let tmp_size = if should_span {field.data.size} else {cell_size}
      idx += tmp_size;
      len -= tmp_size;
      slice_idx += 1;

      // add bf-cell to _cells
      _cells.push(
        //type, grid, x, y, colspan:1, rowspan:1, label, idx ,format: auto
        bf-cell("data-cell", 
          x: x_pos,
          y: y_pos,
          colspan: cell_size,
          rowspan: if(should_span) { int(field.data.size/bpr)} else {1}, 
          label: label, 
          cell-index: cell_index,
          format: cell_format 
        )
      )
    }
  }
  return _cells
}

/// generate note cells from note-fields
#let generate-note-cells(fields, meta) = {
  let note_fields = fields.filter(f => is-note-field(f))
  let _cells = ()
  let bpr = meta.cols.main

  for field in note_fields {
    assert-note-field(field)
    let side = field.data.side
    let level = field.data.level

    _cells.push(
      bf-cell("note-cell", 
          cell-index: (field.field-index, 0),
          grid: side,
          x: if (side == left) {
            meta.cols.pre - level - 1
          } else {
            level
          },
          y: int(field.data.row), 
          rowspan: field.data.rowspan,
          label: field.data.label, 
          format: field.data.format,
        )
    ) 
  }
  return _cells
}

/// generate header cells from header-fields
#let generate-header-cells(fields, meta) = {
  let header_fields = fields.filter(f => is-header-field(f))
  let bpr = meta.cols.main

  let _cells = ()

  for header in header_fields {
    assert-header-field(header)
    let nums = header.data.at("numbers", default: ()) + header.data.at("labels").keys().map(k => int(k)) 
    let cell = nums.filter(num => num >= header.data.range.start and num < header.data.range.end).dedup().map(num =>{

      // extract the label from the header field.
      let label = header.data.labels.at(str(num), default: "")
      // check if the number should be shown on this cell.
      let show_number = num in header.data.numbers
      // calculate the x position inside the grid depending on the msb
      let x_pos = if (meta.msb == left) { (bpr - 1) - calc.rem(num,bpr) } else { calc.rem(num, bpr) }

      // check if a marker should be used.
      let marker = header.data.format.at("marker", default: true) // false
      if (type(marker) == array) {
        assert(marker.len() == 2, message: strfmt("expected a array of length two, found array with length {}", marker.len()));
        if (show_number) {
          marker = marker.at(0, default: true)
        } else {
          marker = marker.at(1, default: true)
        }
      }
      assert(type(marker) == bool, message: strfmt("expects marker to be a bool, found {}", type(marker)));

      bf-cell("header-cell", 
          cell-index: (header.field-index, num),
          grid: top,
          x: x_pos,
          y: 0,
          label: (
            num: str(num),
            text: label,
          ),
          format: (
            // Defines if the number should be shown or ommited
            number: show_number,
            // Defines the angle of the labels 
            angle: header.data.format.at("angle", default: -60deg),
            // Defines the text-size for both numbers and labels.
            text-size: header.data.format.at("text-size",default: auto), 
            // Defines if a marker should be shown
            marker: marker,
            // Defines the alignment
            align: header.data.format.at("align", default: center + bottom), 
            // Defines the inset
            inset: header.data.format.at("inset", default: (x: 0pt, y: 4pt)),
          )
        )
    })

    _cells.push(cell)

  }

  return _cells
}

/// generates cells from fields
#let generate-cells(meta, fields) = {
  // data 
  let data_cells = generate-data-cells(fields, meta);
  // notes
  let note_cells = generate-note-cells(fields, meta);
  // header 
  let header_cells = generate-header-cells(fields, meta);

  return (header_cells, data_cells, note_cells).flatten()
}

/// map bf custom cells to tablex cells
#let map-cells(cells) = {
  cells.map(c => {
    assert-bf-cell(c)

    let body = if is-header-cell(c) {
      let label_text = c.label.text
      let label_num = c.label.num
      context {
        style(styles => {
          set text(if c.format.text-size == auto { get-default-header-font-size() } else { c.format.text-size })
          set align(center + bottom)
          let size = measure(label_text, styles).width
          stack(dir: ttb, spacing: 0pt,
            if is-not-empty(label_text) {
              box(height: size, inset: (left: 50%, rest: 0pt))[
                #set align(start)
                #rotate(c.format.at("angle"), origin: left, label_text)
              ]
            },
            if (is-not-empty(label_text) and c.format.at("marker") != false){ line(end:(0pt, 5pt)) },
            if c.format.number {box(inset: (top:3pt, rest: 0pt), label_num)},  
          )
        })
      }
    } else {
      {
        [
            #if (is-data-cell(c) and (get-default-field-font-size() != auto)) {
              [
                #set text(get-default-field-font-size());
                #c.label
              ]
            } else if (is-note-cell(c) and (get-default-note-font-size() != auto)) {
              [
                #set text(get-default-note-font-size());
                #c.label
              ]
            } else { c.label }
        ]
      }
    }

    return grid.cell(
      x: c.position.x,
      y: c.position.y,
      colspan: c.span.cols,
      rowspan: c.span.rows,
      inset: c.format.at("inset", default: 0pt),
      stroke: c.format.at("stroke", default: none),
      fill: c.format.at("fill", default: none),
      align: c.format.at("align", default: center + horizon),
      body
    )
  })
}

/// produce the final output
#let generate-table(meta, cells) = {
  let table = context {
    let rows = if (meta.rows.main == auto) { get-default-row-height() } else { meta.rows.main }
    if (type(rows) == array) { rows = rows.map(r => if (r == auto) { get-default-row-height() } else { r } )}

    // somehow grid_header still needs to exists. 
    let grid_header = if (meta.header != none) { 
      grid(
        columns: (1fr,)*meta.cols.main,
        rows: auto,
        ..map-cells(cells.filter(c => is-in-header-grid(c)))
      )
    } else { none }

    let grid_left = grid(
      columns: meta.side.left.cols,
      rows: rows,
      ..map-cells(cells.filter(c => is-in-left-grid(c)))
    )

    let grid_right = grid(
      columns: meta.side.right.cols,
      rows: rows,
      ..map-cells(cells.filter(c => is-in-right-grid(c)))
    )

    let grid_center = grid(
        columns:(1fr,)*meta.cols.main,
        rows: rows,
        ..map-cells(cells.filter(c => is-in-main-grid(c)))
      )


    return grid(
      columns: (if (meta.cols.pre > 0) { auto } else { 0pt }, 1fr, if (meta.cols.post > 0) { auto } else { 0pt }),
      inset: 0pt,
      ..if (meta.header != none) {
        ([/* top left*/], 
        align(bottom, box(
          width: 100%,
          fill: if (meta.header.fill != auto) { meta.header.fill } else { get-default-header-background() }, 
          stroke: if (meta.header.stroke != auto) { meta.header.stroke } else { get-default-header-border() },
          grid_header
        )), 
        [/*top right*/],)
      },
      align(top,grid_left), 
      align(top,grid_center),
      align(top,grid_right),
    )

  }
  return table
}
