#import "types.typ": *
#import "utils.typ": *
#import "asserts.typ": *
#import "states.typ": *

#import "@preview/tablex:0.0.8": tablex, cellx, gridx

/// generate metadata which is needed later on
#let generate_meta(fields, args) = {
  // collect metadata into an dictionary
  // let bh = fields.find(f =>  is-header-field(f))
  // let msb = if (bh == none) {right} else { bh.data.msb }
  let (pre_levels, post_levels) = _get_max_annotation_levels(fields.filter(f => if is-bf-field(f) { is-note-field(f) } else { f.type == "annotation" } ))
  let meta = (
    size: fields.filter(f => if is-bf-field(f) { is-data-field(f) } else { f.type == "bitbox" } ).map(f => if (f.data.size == auto) { args.bpr } else { f.data.size } ).sum(),
    msb: args.msb,
    cols: (
      pre: pre_levels,
      main: args.bpr,
      post: post_levels,
    ),
    header: (
      rows: 1,
    ),
    side: (
      left: (
        cols: if (args.side.left_cols == auto) { (auto,)*pre_levels } else { args.side.left_cols },
      ),
      right: (
        cols: if (args.side.right_cols == auto) { (auto,)*post_levels } else { args.side.right_cols },
      )
    )
  )
  return meta;
}

/// helper to calc number values from autofill string arguments
#let _get_header_autofill_values(autofill, fields, meta) = {
  if (autofill == "bounds") {
    return fields.filter(f => is-data-field(f)).map(f => if f.data.range.start == f.data.range.end { (f.data.range.start,) } else {(f.data.range.start, f.data.range.end)}).flatten()
  } else if (autofill == "all") {
    return range(meta.size)
  } else if (autofill == "offsets") {
    let _fields = fields.filter(f => is-data-field(f)).map(f => f.data.range.start).flatten() //.filter(value => value < meta.cols.main).flatten()
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
#let index_fields(fields) = {
  fields.enumerate().map(((idx, f)) => {
    assert_bf-field(f)
    dict_insert_and_return(f, "field-index", idx)
  })
}

/// indexes all fields and add some additional field data
#let finalize_fields(fields, meta) = {

  // This part must be changed if the user low level api changes.
  let _fields = index_fields(fields)

  // Define some variables
  let bpr = meta.cols.main
  let range_idx = 0;
  let fields = ();

  // data fields
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
    let anchor = _get_index_of_next_data_field(f.field-index, _fields)
    let data = dict_insert_and_return(f.data, "anchor", anchor)
    fields.push(dict_insert_and_return(f, "data", data))
  }


  // header fields  -- needs data fields already processed !!
  for f in _fields.filter(f => is-header-field(f)) {
    let autofill_values = _get_header_autofill_values(f.data.autofill, fields, meta);
    let numbers = if f.data.numbers == none { () } else { f.data.numbers + autofill_values }
    let labels = f.data.at("labels", default: (:))
    fields.push(header-field(
      start: if f.data.range.start == auto { if meta.msb == right { 0 } else { meta.size - bpr } } else { assert.eq(type(f.data.range.start),int); f.data.range.start },
      end: if f.data.range.end == auto { if meta.msb == right { bpr } else { meta.size } } else { assert.eq(type(f.data.range.end),int); f.data.range.end }, 
      msb: meta.msb,
      numbers: numbers,
      labels: labels,
      ..f.data.format,
    ))
    break // workaround to only allow one bitheader till multiple bitheaders are supported.
  }

  return fields 
}

/// generate data cells from data-fields
#let generate_data_cells(fields, meta) = {
  let data_fields = fields.filter(f => f.field-type == "data-field")
  if (meta.msb == left ) { data_fields = data_fields.rev() }
  data_fields = data_fields
  let bpr = meta.cols.main;

  let _cells = ();
  let idx = 0;

  for field in data_fields {
    assert_data-field(field)
    let len = field.data.size

    let slice_idx = 0;
    let should_span = is-multirow(field, bpr)
    let current_offset = calc.rem(idx, bpr)
    // let num_of_wraps = calc_row_wrapping(field, bpr, current_offset)

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
      let x_pos = calc.rem(idx,bpr) + meta.cols.pre
      let y_pos = int(idx/bpr) + meta.header.rows

      let cell_format = (
        fill: field.data.format.fill,
        stroke: _stroke,
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
          cell-idx: cell_index, 
          format: cell_format 
        )
      )
    }
  }
  return _cells
}

/// generate note cells from note-fields
#let generate_note_cells(fields, meta) = {
  let note_fields = fields.filter(f => f.field-type == "note-field")
  let _cells = ()
  let bpr = meta.cols.main

  for field in note_fields {
    let side = field.data.side
    let level = field.data.level

    // get the associated field
    let anchor_field = fields.find(f => f.field-index == field.data.anchor)
    let row = meta.header.rows;
   
    if anchor_field != none {
       row = int( if (meta.msb == left) { (meta.size - anchor_field.data.range.end)/bpr } else { anchor_field.data.range.start/bpr }) + meta.header.rows 
    } else {
      // if no anchor could be found, fail silently
      continue
    }

    _cells.push(
      bf-cell("note-cell", 
          cell-idx: (field.field-index, 0),
          x: if (side == left) {
            meta.cols.pre - level - 1
          } else {
            meta.cols.pre + bpr + level
          },
          y: int(row), 
          rowspan: field.data.rowspan,
          label: field.data.label, 
          format: field.data.format,
        )
    ) 
  }
  return _cells
}

/// generate header cells from header-fields
#let generate_header_cells(fields, meta) = {
  let header_fields = fields.filter(f => f.field-type == "header-field")
  let bpr = meta.cols.main

  let _cells = ()

  for header in header_fields {
    let nums = header.data.at("numbers", default: ()) + header.data.at("labels").keys().map(k => int(k)) 
    let cell = nums.filter(num => num >= header.data.range.start and num < header.data.range.end).dedup().map(num =>{

      let label = header.data.labels.at(str(num), default: "")

      let show_number = num in header.data.numbers  //header.data.numbers != none and num in header.data.numbers

      if header.data.msb == left {
        header-cell(num, label: label, show-number: show_number, pos: (bpr - 1) - calc.rem(num,bpr) , meta, ..header.data.format) // TODO
      } else {
        header-cell(num, label: label, show-number: show_number, meta, ..header.data.format) // TODO
      }
    })

    _cells.push(cell)

  }

  return _cells
}

/// generates cells from fields
#let generate_cells(meta, fields) = {
  // data 
  let data_cells = generate_data_cells(fields, meta);
  // notes
  let note_cells = generate_note_cells(fields, meta);
  // header 
  let header_cells = generate_header_cells(fields, meta);

  return (header_cells, data_cells, note_cells).flatten()
}

/// map bf custom cells to tablex cells
#let map_cells(cells) = {
  cells.map(c => {
    let cell_type = c.at("cell-type", default: none)

    let body = if (cell_type == "header-cell") {
      let label_text = c.label.text
      let label_num = c.label.num
      locate(loc => {
        style(styles => {
          set text(if c.format.text-size == auto { _get_header_font_size(loc) } else { c.format.text-size })
          set align(center + bottom)
          let size = measure(label_text, styles).width
          stack(dir: ttb, spacing: 0pt,
            if is-not-empty(label_text) {
              box(height: size, inset: (left: 50%, rest: 0pt))[
                #set align(start)
                #rotate(c.format.at("angle", default: -60deg), origin: left, label_text)
              ]
            },
            if (is-not-empty(label_text) and c.format.at("marker", default: auto) != none){ line(end:(0pt, 5pt)) },
            if c.format.number {box(inset: (top:3pt, rest: 0pt), label_num)},  
          )
          
        })
      }) 
    } else {
      box(
        height: 100%,
        width: if (cell_type == "data-cell") { 100% } else {auto},
        stroke: c.format.at("stroke", default: none),
        c.label
      )
    }

    return cellx(
      x: c.position.x,
      y: c.position.y,
      colspan: c.span.cols,
      rowspan: c.span.rows,
      inset: c.format.at("inset", default: 0pt),
      fill: c.format.at("fill", default: none),
      align: c.format.at("align", default: center + horizon),
      body
    )
  })
}

/// produce the final output
#let generate_table(meta, cells) = {
  let cells = map_cells(cells);

  // TODO: new grid with subgrids.
  let table = locate(loc => {
      gridx(
        columns:  meta.side.left.cols + range(meta.cols.main).map(i => 1fr) + meta.side.right.cols,
        rows: (auto, _get_row_height(loc)),
        align: center + horizon,
        inset: (x:0pt, y: 4pt),
        ..cells
      )
    })
  return table
}