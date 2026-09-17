#let plug = plugin("typst_vhdl_parse.wasm")

/// Parses a VHDL file
///
/// The return value is a dictionary, used as parameter in the other functions 
/// to extract information from the parsed VHDL file. The `messages` element
/// in the returned dictionary is a list of warnings or errors from the parser.
/// 
/// === Example
/// 
/// ```example
///<<<#let parsed-file = vhdl-parse.parse(
///<<<    "test.vhd", 
///<<<    read("test.vhd"))
///
///Messages from the parser:
///
///#if parsed-file.messages.len() == 0 [
///   no messages
/// ] else {
///   for message in parsed-file.messages [ 
///   - #message ]
/// }
/// 
/// ```
/// 
/// -> dictionary
#let parse(
      /// The VHDL file name -> string
    file-name, 
      /// The VHDL code, usually the result of a `read` operation on the VHDL file -> string | bytes 
    contents, 
      /// (optional) The VHDL variant -> string | int
    vhdl-variant : 2008, 
      /// (opttional) The default comment priority. Either "leading" or "trailing", see #lower[@sec-comments] -> string
    comment-priority : "trailing") = {

  // arguments check and conversion
  assert(type(file-name) == str, message: "file-name must be a string")
  if type(contents) == str {
    contents = bytes(contents)
  }
  assert(type(contents) == bytes, message: "contents must be a string or bytes")
  vhdl-variant = str(vhdl-variant)
  assert(("93", "08", "19", "1993", "2008", "2019").contains(vhdl-variant), message: "unknown VHDL variant")
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // parse the file and return the results
  let result = cbor(plug.parse(bytes(file-name), bytes(vhdl-variant), contents))
  return (
    "plugin":           plug,
    "id":               result.id,
    "messages":         result.messages,
    "orig-fname":       bytes(file-name),
    "orig-vhdl":        bytes(vhdl-variant),
    "orig-contents":    contents,
    "comment-priority": comment-priority
  )
}

/// Returns the portlist from the first entity found in the parsed file
///    
/// === Return structure
/// 
/// an array of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name      elem type        elem description
///   ("name",         "string",        "the port name"                                      ),
///   ("mode",         "string",        "the port mode (in, out, inout, buffer)"             ),
///   ("port-type",    "string",        "the VHDL type of the port"                          ),
///   ("constraint",   "string or none","the type constraint, for example: \"(15 downto 0)\""),
///   ("description",  "string or none","a comment describing the port"                      ),
///   ("default-value","string or none","the port default value"                             ),
/// 
/// 
/// ))
/// 
/// === Example
///
/// ```example 
/// #let ports = vhdl-parse.port-list(
///   parsed-file)
/// 
///>>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// Ports list:
/// 
/// #table(
///    columns: (2cm, 1.5cm, 4cm, 6cm),
///    table.header([name], [mode], [type], [description]),
///    ..for entry in ports {
///     ( [#entry.name], 
///       [#entry.mode], 
///       [#{entry.port-type}#{entry.constraint}],
///       [#entry.description])
///     }
/// )
/// ```
/// 
/// -> array
#let port-list(
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // call the plugin and return the results
  let entity-declaration = cbor(parsed-file.plugin.get_entity_declaration_struct(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents, 
    bytes(comment-priority)));

  return entity-declaration.ports 
}

/// Returns the generics list from the first entity found in the parsed file
/// 
/// === Return structure
/// 
/// an array of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name      elem type        elem description
///   ("name",         "string",        "the generic name"                                   ),
///   ("generic-type", "string",        "the VHDL type of the generic"                       ),
///   ("constraint",   "string or none","the type constraint, for example: \"(15 downto 0)\""),
///   ("description",  "string or none","a comment describing the generic"                   ),
///   ("default-value","string or none","the generic default value"                          ),
/// 
/// 
/// ))
/// 
/// === Example
///
/// ```example 
/// #let generics = vhdl-parse.generic-list(
///   parsed-file)
/// 
///>>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// Generics list:
/// 
/// #table(
///    columns: (2cm, 4cm, 6cm, 2cm),
///    table.header([name], [type], [description], [default]),
///    ..for entry in generics {
///     ( [#entry.name], 
///       [#{entry.generic-type}#{entry.constraint}],
///       [#entry.description],
///       [#entry.default-value])
///     }
/// )
/// ```
/// 
/// -> array
#let generic-list(      
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // call the plugin and return the results
  let entity-declaration = cbor(parsed-file.plugin.get_entity_declaration_struct(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents, 
    bytes(comment-priority)))

  return entity-declaration.generics
}

/// Returns information about a state machine found in the parsed file
///
/// This function looks for a case statement and assignments within the different cases:
/// 
/// ```vhdl
/// case my_state is
///   when state_1 =>
///     next_state <= state_2
/// 
///   when state_2 =>
///     next_state <= state_1
/// 
///   when others =>
///     next_state <= state_1
/// end case;
/// ```
/// 
/// Both signal and variable assignments are detected. The signal or variable that is
/// holding the current state (`my_state` in the example above) is defined with the
/// `read-variable-name` parameter in the function call, while the signal or variable
/// assigned to the next state (`next_state` in the example above) is defined with the
/// `write-variable-name` parameter. If the same signal is both read and written, the
/// name just needs to be defined in `read-variable-name` and `write-variable-name`
/// can be kept to `none` (the default). If an assignment is found in the `when others`
/// clause, the destination of the assignment will be stored as the default state.
/// 
/// @fsm will attempt to find a description for each transition. For that it will look
/// for a comment near the *condition* (an `if`, `elsif` or `else` statement) before 
/// the assignment. If it doesn't find a comment, it will attempt to use the test 
/// condition itself (inside the `if` or `elsif`) as description.
/// 
/// === Return structure
/// 
/// a dictionary with the following elements:
/// 
/// #dictionary-description((
///  // elem name       elem type elem description
///   ("default-state", "string", "the default state (i.e. found in an \"others\" case)"),
///   ("states",        "array",  "an array of states"),
/// ))
/// 
/// The `states` array contains dictionaries, with each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name     elem type         elem description
///   ("name",        "string",         "the state name"),
///   ("description", "string or none", "the comment describing the state"),
///   ("transitions", "array",          "an array of transitions"),
/// ))
/// 
/// The `transitions` arrays contain dictionaries, with each item having the following elements:
/// #dictionary-description((
///  // elem name     elem type         elem description
///   ("destination", "string",         "the state it is transitioned to"),
///   ("condition",   "string",         "the condition for the transition, if found or an empty string"),
///   ("description", "string or none", "the comment describing the condition, if found"),
///  ))
///
/// === Example
///
/// ```example 
/// #let fsm = vhdl-parse.fsm(parsed-file,"fsm_state")
/// 
/// List of states:
/// 
/// >>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// #table(
///     columns: (3cm, 7cm),
///     table.header([state], [description]),
///     ..for state in fsm.states {
///         ( [#state.name], [#state.description])
///     }
/// )
/// 
/// ```
/// -> dictionary
/// 
#let fsm(
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// The name of the signal or variable holding the current fsm state -> string
    read-variable-name, 
      /// (optional) The name of the signal or variable holding the next fsm state, if different from read-variable-name -> string | none
    write-variable-name: none, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  assert(type(read-variable-name) == str, message: "read-variable-name must be a string")
  if write-variable-name == none {
    write-variable-name = read-variable-name
  }
  assert(type(write-variable-name) == str, message: "write-variable-name must be a string")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // build config structure
  let fsmconfig = (
    "read-variable-name": read-variable-name,
    "write-variable-name": write-variable-name,
    "comment-priority-trailing": (comment-priority == "trailing")
  )

  // call plugin
  return cbor(parsed-file.plugin.get_fsm_as_struct(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents, 
    cbor.encode(fsmconfig)))
}

/// Returns a description of an FSM in the DOT format, ready to be drawn by the diagraph package.
/// 
/// For more information about FSM detecton please refer to the @fsm function.
/// 
/// === Example
/// ```example 
/// #let dot = vhdl-parse.fsm-dot(
///   parsed-file,
///   "fsm_state",
///   font-name: "DejaVu Sans, Helvetica,Arial,sans-serif",
///   state-background-color: blue.lighten(70%),
///   default-state-background-color: red.lighten(70%)
///   )
/// #import "@preview/diagraph:0.3.7"
/// #diagraph.render(dot)
/// ```
/// 
/// -> string 
#let fsm-dot(
      /// The parsed filed object, as returned by @parse -> dictionary
    parsed-file,
      /// The name of the signal or variable holding the current fsm state -> string
    read-variable-name, 
      /// (optional) The name of the signal or variable holding the next fsm state, if different from 
      /// `read-variable-name` -> string | none
    write-variable-name: none, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none,
      /// (optional) if true, make a left-to-right diagram instead of top-to-down -> bool
    left-to-right: false,
      /// (optional) the font to use (has to be accessible to Typst) -> string
    font-name : "Helvetica,Arial,sans-serif",
      /// (optional)  the shape to use for states (refer to the Graphviz documentation for a list) 
      /// -> string
    state-shape: "ellipse",
      /// (optional) the background color for states -> color                  
    state-background-color: white,  
      /// (optional) the line color for states -> color     
    state-line-color: black,             
      /// (optional) the color of text for states -> color
    state-text-color: black,   
      /// (optional) the text size for states (in points) -> float    
    state-font-size: 14,             
      /// (optional) the shape to use for the default state (refer to the Graphviz documentation for a 
      /// list) -> string
    default-state-shape: "doublecircle",   
      /// (optional) the background color for the default state. If none, use the same one as for
      /// the regular states -> color | none
    default-state-background-color: none,
      /// (optional) the line color for the default state. If none, use the same one as for the regular 
      /// states -> color | none
    default-state-line-color: none,     
      /// (optional) the color of text for the default state. If none, use the same one as for the 
      /// regular states -> color | none
    default-state-text-color: none,        
      /// (optional) the text size for the default state (in points). If none, use the same one as for
      /// the regular states -> float | none
    default-state-font-size: none,   
      /// (optional) the line color for the transitions. If none, use the same one as for the 
      /// regular states -> color | none             
    transition-line-color: none,     
      /// (optional) the color of text for the transitions. If none, use the same one as for the 
      /// regular states -> color | none             
    transition-text-color: none,     
      /// (optional) the text size for the transitions (in points). If none, use the same one as for the 
      /// regular states -> float | none             
    transition-font-size: none                  
    ) = {
  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  assert(type(read-variable-name) == str, message: "read-variable-name must be a string")
  if write-variable-name == none {
    write-variable-name = read-variable-name
  }
  assert(type(write-variable-name) == str, message: "write-variable-name must be a string")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")
  let shapes = ( "box", "polygon", "ellipse", "oval", "circle", "point", "egg", "triangle", "plaintext", "plain", "diamond", "trapezium", "parallelogram", "house", "pentagon", "hexagon", "septagon", "octagon", "doublecircle", "doubleoctagon", "tripleoctagon", "invtriangle", "invtrapezium", "invhouse", "Mdiamond", "Msquare", "Mcircle", "rect", "rectangle", "square", "star", "none", "underline", "cylinder", "note", "tab", "folder", "box3d", "component", "promoter", "cds", "terminator", "utr", "primersite", "restrictionsite", "fivepoverhang", "threepoverhang", "noverhang", "assembly", "signature", "insulator", "ribosite", "rnastab", "proteasesite", "proteinstab", "rpromoter", "rarrow", "larrow", "lpromoter")
  assert(shapes.contains(state-shape), message: "state-shape needs to be a valid shape type. See https://graphviz.org/doc/info/shapes.html")
  assert(type(state-background-color) == color, message: "state-background-color needs to be a color")
  assert(type(state-line-color) == color, message: "state-line-color needs to be a color")
  assert(type(state-text-color) == color, message: "state-text-color needs to be a color")
  if type(state-font-size) == int {
    state-font-size = float(state-font-size)
  }
  assert(type(state-font-size) == float, message: "state-font-size needs to be a number")
  assert(shapes.contains(default-state-shape), message: "default-state-shape needs to be a valid shape type. See https://graphviz.org/doc/info/shapes.html")
  if default-state-background-color == none {
    default-state-background-color = state-background-color
  }
  assert(type(default-state-background-color) == color, message: "default-state-background-color needs to be a color")
  if default-state-line-color == none {
    default-state-line-color = state-line-color
  }
  assert(type(default-state-line-color) == color, message: "default-state-line-color needs to be a color")
  if default-state-text-color == none {
    default-state-text-color = state-text-color
  }
  assert(type(default-state-text-color) == color, message: "default-state-text-color needs to be a color")
  if default-state-font-size == none {
    default-state-font-size = state-font-size
  }
  if type(default-state-font-size) == int {
    default-state-font-size = float(default-state-font-size)
  }
  assert(type(default-state-font-size) == float, message: "default-state-font-size needs to be a number")
  if transition-line-color == none {
    transition-line-color = state-line-color
  }
  assert(type(transition-line-color) == color, message: "transition-line-color needs to be a color")
  if transition-text-color == none {
    transition-text-color = state-text-color
  }
  assert(type(transition-text-color) == color, message: "transition-text-color needs to be a color")
  if transition-font-size == none {
    transition-font-size = state-font-size
  }
  if type(transition-font-size) == int {
    transition-font-size = float(transition-font-size)
  }
  assert(type(transition-font-size) == float, message: "transition-font-size needs to be a number")

  // build config structures
  let fsmconfig = (
    "read-variable-name": read-variable-name,
    "write-variable-name": write-variable-name,
    "comment-priority-trailing": (comment-priority == "trailing")
  )
  let fsmdotconfig = (
    "left-to-right":                  left-to-right,
    "font-name":                      font-name,
    "state-shape":                    state-shape,
    "state-background-color":         state-background-color.to-hex(),
    "state-line-color":               state-line-color.to-hex(),
    "state-text-color":               state-text-color.to-hex(),
    "state-font-size":                state-font-size,
    "default-state-shape":            default-state-shape,
    "default-state-background-color": default-state-background-color.to-hex(),
    "default-state-line-color":       default-state-line-color.to-hex(),
    "default-state-text-color":       default-state-text-color.to-hex(),
    "default-state-font-size":        default-state-font-size,
    "transition-line-color":          transition-line-color.to-hex(),
    "transition-text-color":          transition-text-color.to-hex(),
    "transition-font-size":           transition-font-size,
  )

  // call plugin
  return cbor(parsed-file.plugin.get_fsm_as_dot(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents, 
    cbor.encode(fsmconfig), 
    cbor.encode(fsmdotconfig)))
}

/// Returns the instances list from the first entity found in the parsed file
///
/// === Return structure
/// 
/// an array of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name       elem type         elem description
///   ("label",        "string",         "the instantiation label"),
///   ("entity",       "string",         "the entity being instantiated"),
///   ("description",  "string or none", "a comment describing the instance"),
///   ("generics-map", "array",          "an array of generics"),
///   ("ports-map",    "array",          "an array of ports")
/// ))
/// 
/// `generics-map` and `ports-map` are arrays of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name     elem type elem description
///   ("origin",     "string", "name of the generic or port on the entity side"),
///   ("expression", "string", "the expression assigned to the generic or port"),
///  ))
/// 
/// === Example
/// 
/// ```example
/// >>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// List of Instances
/// 
/// #let instances = vhdl-parse.instances-list(parsed-file)
/// 
/// #table(
///     columns: (3cm, 3cm, 7cm),
///     table.header([label], [entity], [description]),
///     ..for element in instances {
///         ( [#element.label], [#element.entity], [#element.description])
///     }
/// )
/// 
/// ```
/// 
/// -> array
/// 
#let instances-list(
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // call the plugin and return the results
  return cbor(parsed-file.plugin.get_instances_list(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents, 
    bytes(comment-priority)))
}

/// Returns the constants list from the architecture or package definition in the parsed file
///
/// === Return structure
/// 
/// an array of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name       elem type         elem description
///    ("name",        "string",         "the constant name"),
///    ("object-type", "string",         "the constant type"),
///    ("constraint",  "string or none", "the type constraint (x downto y)"),
///    ("expression",  "string or none", "the constant value"),
///    ("description", "string or none", "a comment describing the constant"),
/// ))
/// 
/// === Example
/// 
/// ```Example
/// >>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// List of Constants
/// 
/// #let constants = vhdl-parse.constants-list(parsed-file)
/// 
/// #table(
///    columns: (2cm, 4cm, 3cm, 4cm),
///    table.header([name], [type], [description], [value]),
///    ..for entry in constants {
///        ( [#entry.name], 
///          [#{entry.object_type}#{entry.constraint}], 
///          [#entry.description], 
///          [#entry.expression])
///    }
/// )
/// ```
/// 
/// -> array
#let constants-list(
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // call the plugin and return the results
  let declarations = cbor(parsed-file.plugin.get_declarations_struct(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents,
    bytes(comment-priority)))

  return declarations.constants
}

/// Returns the signals list from the architecture or package declaration in the parsed file
///
/// === Return structure
/// 
/// an array of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name       elem type         elem description
///    ("name",        "string",         "the signal name"),
///    ("object-type", "string",         "the signal type"),
///    ("expression",  "string or none", "the signal initial value"),
///    ("constraint",  "string or none", "the type constraint (x downto y)"),
///    ("description", "string or none", "a comment describing the signal"),
/// ))
/// 
/// === Example
/// ```example
/// >>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// List of Signals
/// 
/// #let signals = vhdl-parse.signals-list(parsed-file)
/// 
/// #table(
///    columns: (2cm, 3.5cm, 5cm, 3.5cm),
///    table.header([name], [type], [description], [value]),
///    ..for entry in signals {
///        ( [#entry.name], 
///          [#{entry.object_type}#{entry.constraint}], 
///          [#entry.description], 
///          [#entry.expression])
///    }
/// )
/// ```
/// 
/// -> array
#let signals-list(
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // call the plugin and return the results
  let declarations = cbor(parsed-file.plugin.get_declarations_struct(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents,
    bytes(comment-priority)))

  return declarations.signals
}

/// Returns the types list from the architecture or package declaration in the parsed file
///
/// === Return structure
/// 
/// an array of dictionaries, each item having the following elements:
/// 
/// #dictionary-description((
///  // elem name       elem type         elem description
///    ("name", "string",                "the type name"),
///    ("kind", "string",                "the type kind: \"enumeration\", \"record\", \"subtype\" or \"array\""),
///    ("description", "string or none", "a comment describing the type"),
///    ("definition", "see below",       "an object with the type definition. The structure depends on the type kind"),
/// ))
/// 
/// The definition object is different depending on the type kind:
/// - Enumeration: an array of dictionaries, each item having the following elements:
///   #dictionary-description((
///  // elem name       elem type         elem description
///   ("element-name", "string",         "the enumeration element name"),
///   ("description",  "string or none", "a comment describing the element"),
/// ))
/// - Record: an array of dictionaries, each item having the following elements:
///   #dictionary-description((
///  // elem name       elem type         elem description
///   ("element-name", "string",         "the record element name"),
///   ("element-type", "string",         "the record element type"),
///   ("description",  "string or none", "a comment describing the record element"),
/// ))
/// - Subtype: a dictionary with the following elements:
///   #dictionary-description((
///  // elem name     elem type         elem description
///   ("subtype",    "string",         "the type name"),
///   ("constraint", "string or none", "the constraint (x downto y)"),
/// ))
/// - Array: a dictionary with the following elements:
///   #dictionary-description((
///  // elem name  elem type elem description
///   ("range",   "string", "the array range(s)"),
///   ("subtype", "string", "the array element type"),
/// ))
/// 
/// === Example
/// ```example
/// >>> #set text(font: ("DejaVu Sans", "Arial", "Helvetica"))
/// List of types
/// 
/// #let types = vhdl-parse.types-list(parsed-file)
/// 
/// #table(
///     columns: (3.5cm, 3cm, 6cm),
///     table.header([name], [kind], [description]),
///     ..for entry in types {
///         ( [#entry.name], [#entry.kind], [#entry.description] )
///     }
/// )
/// ```
/// -> array
#let types-list(
      /// The parsed file object, as returned by @parse -> dictionary
    parsed-file, 
      /// (optional) override the default comment priority, either "leading" or "trailing", see #lower[@sec-comments] -> string | none
    comment-priority : none) = {

  // arguments check and conversion
  assert(type(parsed-file) == dictionary, message: "parsed-file must be the return value from the parse() function")
  if comment-priority == none {
    comment-priority = parsed-file.comment-priority
  }
  assert(("trailing", "leading").contains(comment-priority), message: "comment priority must be \"trailing\" or \"leading\"")

  // call the plugin and return the results
  let declarations = cbor(parsed-file.plugin.get_declarations_struct(
    bytes(parsed-file.id), 
    parsed-file.orig-fname, 
    parsed-file.orig-vhdl, 
    parsed-file.orig-contents,
    bytes(comment-priority)))

  return declarations.types
}
