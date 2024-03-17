#import "gen.typ": *
#import "types.typ": *

/// Create a new bytefield.
///
/// *Example:*  See @chap:use-cases
///
///
/// - bpr (int): Number of bits which are shown per row.
/// - msb (left, right): position of the msb.
/// - pre (auto, int , relative , fraction , array): This is specifies the columns for annotations on the *left* side of the bytefield
/// - post (auto, int , relative , fraction , array): This is specifies the columns for annotations on the *right* side of the bytefield
///
/// - ..fields (bf-field): arbitrary number of data fields, annotations and headers which build the bytefield. 
/// -> bytefield 
#let bytefield(
  bpr: 32, 
  msb: right,
  rows: auto,
  pre: auto,
  post: auto,
  ..fields
) = {

  let args = (
    bpr: bpr,
    msb: msb,
    rows: rows,
    side: (left_cols: pre, right_cols: post)
  )

  let meta = generate_meta(fields.pos(), args)
  let fields = finalize_fields(fields.pos(), meta)
  let cells = generate_cells(meta, fields)
  let table = generate_table(meta, cells)
  return table
}

/// Base for `bit`, `bits`, `byte`, `bytes`, `flag` field functions
///
/// #emoji.warning This is just a base function which is used by the other functions and should *not* be called directly.
///
/// - size (int): The size of the field in bits.
/// - fill (color): The background color for the field.
/// - body (content): The label which is displayed inside the field.
#let _field(size, fill: none, body) = {
  if size != auto { assert.eq(type(size), int, message: strfmt("expected size to be an integer or auto, found {}", type(size))) } 
  if fill != none { assert(type(fill) in (color, gradient), message: strfmt("expected fill to be an color or gradient, found {}.", type(fill)))}
  data-field(none, size, none, none, body, format: (fill: fill))
}

/// Add a field of the size of *one bit* to the bytefield
///
/// Basically just a wrapper for @@_field() 
///
/// - ..args (arguments): All arguments which are accepted by `_field`
///
#let bit(..args) = _field(1, ..args)

/// Add a field of a given size of bits to the bytefield
///
/// Basically just a wrapper for @@_field() 
///
/// - len (int): Size of the field in bits 
/// - ..args (arguments): All arguments which are accepted by `_field`
///
#let bits(len, ..args) = _field(len, ..args)

/// Add a field of the size of one byte to the bytefield
///
/// Basically just a wrapper for @@_field() 
///
/// - ..args (arguments): All arguments which are accepted by `_field`
///
#let byte(..args) = _field(8, ..args)

/// Add a field of the size of multiple bytes to the bytefield
///
/// Basically just a wrapper for @@_field() 
///
/// - len (int): Size of the field in bytes 
/// - ..args (arguments): All arguments which are accepted by `_field`
///
#let bytes(len, ..args) = _field(len * 8, ..args)

/// Add a flag to the bytefield.
///
/// Basically just a wrapper for @@_field() 
///
/// - text (content): The label of the flag which is rotated by `270deg`
/// - ..args (arguments): All arguments which are accepted by `_field`
///
#let flag(text,..args) = _field(1,align(center,rotate(270deg,text)),..args)

/// Create a annotation
///
/// The note is always shown in the same row as the next data field which is specified. 
///
/// - side (left, right): Where the annotation should be displayed
/// - level (int): Defines the nesting level of the note.
/// - rowspan (int): Defines if the cell is spanned over multiple rows.
/// - inset (length): Inset of the the annotation cell.
/// - bracket (bool): Defines if a bracket will be shown for this note.
/// - content (content): The content of the note.
#let note(
  side,
  rowspan:1,
  level:0, 
  inset: 5pt,
  bracket: false,
  content,
) = {
  assert(side in (left,right), message: strfmt("expected side to be left or right, found {}", side));
  assert.eq(type(bracket), bool, message: strfmt("expected bracket to be of type bool, found {}", type(bracket)));
  assert.eq(type(rowspan), int, message: strfmt("expected rowspan to be a integer, found {}.", type(rowspan)));
  assert.eq(type(level), int, message: strfmt("expected level to be a integer, found {}.", type(level)));
  assert(type(inset) in (length, dictionary), message: strfmt("expected inset to be a length or dictionary, found {}.", type(inset)));

  let _align  = none
  let _first  = none
  let _second = none

  if (side == left) {
    _align  = right
    _first  = box(height:100%,content)
    _second = box(height:100%,inset:(right:0pt),layout(size => {math.lr("{",size:size.height)}))
  } else {
    _align  = left
    _first  = box(height:100%,inset:(left:0pt),layout(size => {math.lr("}",size:size.height)}))
    _second = box(height:100%,content)
  }

  let body = if (bracket == false) { content } else {
    grid(
      columns:2,
      gutter: inset,
      _first,
      _second
    )
  }

  let format = (
    inset: if (bracket == false) { inset } else { (x:2pt, y:1pt) },
    align:_align+horizon,
  )

  return note-field(none, none, side, level:level, body, format: format, rowspan: rowspan)
}

/// Shows a note with a bracket and spans over multiple rows.
///
/// Basically just a shortcut for the `note` field with the argument `bracket:true` by default.
/// 
#let group(side, rowspan, level:0, bracket:true, content) = {
  note(side, level:level, rowspan:rowspan, bracket:bracket, content)
}

/// Shows a special note with a start_addr (top aligned) and end_addr (bottom aligned) on the left of the associated row.
///
/// #emoji.warning *experimental:* This will probably change in a future version.
///
/// - start_addr (string, content):  The start address will be top aligned
/// - end_addr (string, content): The end address will be bottom aligned
#let section(start_addr, end_addr, span: 1) = {
  note(
    left, 
    rowspan: span, 
    inset: (x:5pt, y:2pt), 
    box(height:100%, [
      #set text(0.8em, font: "Noto Mono", weight: 100)
      #align(top + end)[#start_addr]
      #align(bottom + end)[#end_addr]
    ]))
}

/// Config the header on top of the bytefield 
///
/// By default no header is shown.
/// 
/// - range (array): Specify the range of number which are displayed on the header. Format: `(start, end)`
/// - autofill (string): Specify on of the following options and let bytefield calculate the numbers for you.
///   - `"bytes"` shows each multiple of 8 and the last number of the row.
///   - `"all"` shows all numbers.
///   - `"bounds"` shows a number for every start and end bit of a field.
///   - `"offsets"` shows a number for every start bit of a field. 
/// - numbers (auto, none): if none is specified no numbers will be shown on the header. This is useful to show only labels.
/// - marker (bool, array): defines if marker lines are shown under a label.
/// - angle (angle): The rotation angle of the label.
/// - fill (color): The background of the header.
/// - stroke (color): The border stroke of the header.
/// - text-size(length): The text-size for the header labels and numbers.
/// - ..args (int, content): The numbers and labels which should be shown on the header. 
///   The number will only be shown if it is inside the range.
///   If a `content` value follows a `int` value it will be interpreted as label for this number.
///   For more information see the _manual_.
#let bitheader(
  range: (auto,auto),  
  autofill: auto,
  numbers: auto,
  marker: true,
  fill: auto,
  stroke: auto,
  text-size: auto,  
  angle: -60deg,
  ..args
) = {
  // assertions
  if (autofill != auto) { assert.eq(type(autofill), str, message: strfmt("expected autofill to be a string, found {}", type(autofill)))}

  let _numbers = ()
  let labels = (:)
  let last = 0
  let step = 1
  for arg in args.pos() {
    if type(arg) == int {
      if (arg >= 0) {
        _numbers.push(arg)
      }
      last = calc.abs(arg)
    } else if type(arg) == str {
      autofill = arg
    } else if type(arg) == content { 
      labels.insert(str(last),arg)
      last += 1
    }
    if numbers != none { numbers = _numbers }
  }

  let format = (
    angle: angle,
    text-size: text-size,
    marker: marker,
    fill: fill,
    stroke: stroke,
  )
  
  return header-field(
      start: range.at(0, default: auto),  // todo. fix this
      end: range.at(1, default: auto),    // todo. fix this
      autofill: autofill,
      numbers: numbers,
      labels: labels,
      ..format
    )
}
