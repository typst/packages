#import "args.typ": __codly-args, __codly-save, __codly-load

// Default language-block style
#let default-language-block(name, icon, color) = {
  let radius = (__codly-args.lang-radius.get)()
  let padding = (__codly-args.lang-inset.get)()

  let lang-stroke = (__codly-args.lang-stroke.get)()
  let lang-fill = (__codly-args.lang-fill.get)()

  let fill = if type(lang-fill) == function {
    (lang-fill)((name: name, icon: icon, color: color))
  } else {
    color
  }

  let stroke = if type(lang-stroke) == function {
    (lang-stroke)((name: name, icon: icon, color: color))
  } else {
    lang-stroke
  }

  box(
    radius: radius,
    fill: fill,
    inset: padding,
    stroke: stroke,
    outset: 0pt,
    icon + name,
  )
}

/// Lets you set a line number offset.
/// 
/// #pre-example()
/// #example(````
///  #codly-offset(offset: 25)
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-offset(offset: 0) = {
  (__codly-args.offset.update)(offset)
}

/// Lets you set a range of line numbers to highlight.
/// Similar to `codly(range: (start, end))`.
/// 
/// #pre-example()
/// #example(````
///  #codly-range(start: 2)
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-range(
  start: 1,
  end: none,
) = {
  (__codly-args.range.update)((start, end))
}

/// Disables codly.
/// 
/// #pre-example()
/// #example(````
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly-disable()
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-disable() = {
  (__codly-args.enabled.update)(false)
}

/// Enables codly.
/// 
/// #pre-example()
/// #example(````
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
///  #codly-disable()
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly-enable()
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-enable() = {
  (__codly-args.enabled.update)(true)
}

/// Disabled codly locally.
/// 
/// #pre-example()
/// #example(````
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  *Disabled:*
///  #no-codly(```
///  Hello, world!
///  ```)
/// ````, mode: "markup", scale-preview: 100%)
#let no-codly(body) = {
  (__codly-args.enabled.update)(false)
  body
  (__codly-args.enabled.update)(true)
}

/// Appends a skip to the list of skips.
/// 
/// #pre-example()
/// #example(````
///  #codly-skip(4, 32)
///  ```
///  Hello, world!
///  Goodbye, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
#let codly-skip(
  position,
  length,
) = {
  state("codly-skips", ()).update((skips) => {
    if skips == none {
      skips = ()
    }

    skips.push((position, length))
    skips
  })
}


/// Configures codly.
/// Is used in a similar way as `set` rules. You can imagine the following:
/// ```typc
/// // This is a representation of the actual code.
/// // The actual code behave like a set rule that uses `state`.
/// let codly(
///    enabled: true,
///    offset: 0,
///    range: none,
///    languages: (:),
///    display-name: true,
///    display-icon: true,
///    default-color: rgb("#283593"),
///    radius: 0.32em,
///    inset: 0.32em,
///    fill: none,
///    zebra-fill: luma(240),
///    stroke: 1pt + luma(240),
///    lang-inset: 0.32em,
///    lang-outset: (x: 0.32em, y: 0pt),
///    lang-radius: 0.32em,
///    lang-stroke: (lang) => lang.color + 0.5pt,
///    lang-fill: (lang) => lang.color.lighten(80%),
///    lang-format: codly.default-language-block,
///    number-format: (number) => [ #number ],
///    number-align: left + horizon,
///    smart-indent: false,
///    annotations: none,
///    annotation-format: numbering.with("(1)"),
///    highlights: none,
///    highlight-radius: 0.32em,
///    highlight-fill: (color) => color.lighten(80%),
///    highlight-stroke: (color) => 0.5pt + color,
///    highlight-inset: 0.32em,
///    reference-by: line,
///    reference-sep: "-",
///    reference-number-format: numbering.with("1"),
///    breakable: false,
/// ) = {}
/// ```
/// 
/// Each argument is explained below.
/// 
/// == Display style
/// Codly displays your code in three sections:
/// - The line number, if `number-format` is not `none`
/// - The language block, with a fill and a stroke, only appears on the first line
/// - The code itself with optional zebra striping
/// 
/// The block as a whole is surrounded by a stroke.
/// 
/// #align(center, block(width: 80%)[
/// #codly(number-format: none)
/// ```
/// |----------------------------------------------------------------|
/// |1 | [line, zebra]                                | [lang block] |
/// |2 | [line, non-zebra]                                           |
/// |3 | [line, zebra]                                               |
/// |4 | [line, non-zebra]                                           |
/// |----------------------------------------------------------------|
/// ```
/// ])
/// 
/// == Note about arguments:
/// Some arguments can be a function that takes no arguments and returns the value.
/// They are called within a `context` that provides the current location.
/// They can be used to have more dynamic control over the value, without the need
/// for sometimes slow state updates.
/// 
/// == In figure code blocks:
/// If the code block is in a figure, additional features are available for referencing
/// annotations and highlights.
/// #pre-example()
/// #example(````
///  #codly(annotations: ((start: 0, end: 0, content: "Function call", label: <func-call>), ))
///  #codly(highlights: ((line: 1, start: 7, end: none, fill: green, tag: "Call", label: <call>), ))
///  #figure(
///    caption: ["Hello, world!" in Python]
///  )[
///  ```py
///    print("Hello, world!")
///    print("Hello, world!")
///  ```
///  ] <fig-hello>
/// 
///  I can later reference the figure: @fig-hello. But I can also reference the
/// annotation: @func-call. And finally, I can reference the highlight: @call.
/// ````, mode: "markup", scale-preview: 72%)
/// 
/// This behaviour can be completely customized using the `reference-by`,
/// `reference-sep`, and `reference-number-format` fields listed below.
///
/// == Enabled (`enabled`)
/// Whether codly is enabled or not.
/// If it is disabled, the code block will be displayed as a normal code block,
/// without any additional codly-specific formatting.
/// 
/// This is useful if you want to disable codly for a specific block.
/// 
/// You can also disable codly locally using the @@no-codly() function, or disable it
/// and enable it again using the @@codly-disable() and @@codly-enable() functions.
/// 
/// - *Default*: `true`
/// - *Type*: `bool`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(enabled: true)
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly(enabled: false)
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Offset (`offset`)
/// The offset to apply to line numbers.
/// 
/// Note that the offset gets reset automatically after every code block.
/// 
/// - *Default*: `0`
/// - *Type*: `int`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(offset: 0)
///  *No offset:*
///  ```
///  Hello, world!
///  ```
/// 
///  #codly(offset: 5)
///  *With offset:*
///  ```
///  Hello, world!
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Range (`range`)
/// The range of line numbers to display.
/// 
/// Note that the range gets reset automatically after every code block.
/// 
/// The same behavior can be achieved using the @@codly-range() function.
/// 
/// - *Default*: `none`
/// - *Type*: `(int, int)` or `none`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(range: (2, 4))
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Skips (`skips`)
/// Insert a skip at the specified line numbers, setting its offset to the
/// length of the skip. The skip is formatted using `skip-number`
/// and `skip-line`.
/// 
/// Each skip is an array with two values: the position and length of the skip.
/// 
/// Note that the skips gets reset automatically after every code block.
/// 
/// The same behavior can be achieved using the @@codly-skip() function, which
/// appends one or more skips to the list of skips.
/// 
/// - *Default*: `()`
/// - *Type*: `array` or `none`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(skips: ((4, 32), ))
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Skip number (`skip-number`)
/// Sets the content with which the line number columns is filled when a skip is
/// encountered. If line numbers are disabled, this has no effect.
/// 
/// == Skip line (`skip-line`)
/// Sets the content with which the line columns is filled when a skip is
/// encountered.
/// 
/// == Languages (`languages`)
/// The language definitions to use for language block formatting.
/// 
/// It is defined as a dictionary where the keys are the language names  and
/// each value is another dictionary containing the following keys:
/// - `name`: the "pretty" name of the language as a content/showable value
/// - `color`: the color of the language, if omitted uses the default color
/// - `icon`: the icon of the language, if omitted no icon is shown
/// 
/// Alternatively, the value can be a string, in which case it is used as the
/// name of the language. And no icon is shown and the default color is used.
/// 
/// If an entry is missing, and language blocks are enabled, will show
/// the "un-prettified" language name, with the default color.
/// 
/// - *Default*: `(:)`
/// - *Type*: `dict`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    languages: (
///      py: (name: "Python", color: red, icon: "🐍")
///    )
///  )
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Display name (`display-name`)
/// 
/// Whether to display the name of the language in the language block.
/// This only applies if you're using the default language block formatter.
/// 
/// - *Default*: `true`
/// - *Type*: `bool`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(display-name: false)
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Display icon (`display-icon`)
/// Whether to display the icon of the language in the language block.
/// This only applies if you're using the default language block formatter.
/// 
/// - *Default*: `true`
/// - *Type*: `bool`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    display-icon: false,
///    languages: (
///      py: (name: "Python", color: red, icon: "🐍")
///    )
///  )
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Default color (`default-color`)
/// The default color to use for language blocks.
/// 
/// This only applies if you're using the default language block formatter.
/// Also note that it is also passed as a named argument to the language
/// block formatter if you've defined your own.
///  
/// - *Default*: `rgb("#283593")` (a shade of blue)
/// - *Type*: `color`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(default-color: orange)
///  ```py
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Radius (`radius`)
/// The radius of the border of the code block.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(radius: 0pt)
///  ```
///  print('Hello, world!')
///  ```
///  #codly(radius: 20pt)
///  ```
///  print('Hello, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Inset (`inset`)
/// The inset of the code block.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(inset: 10pt)
///  ```
///  print('Hello, world!')
///  ```
///  #codly(inset: 0pt)
///  ```
///  print('Hello, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Fill (`fill`)
/// The fill of the code block when not zebra-striped.
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `color`, `gradient`, or `pattern`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    fill: gradient.linear(..color.map.flare),
///  )
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Zebra color (`zebra-fill`)
/// The fill of the code block when zebra-striped, `none` to disable zebra-striping.
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    zebra-fill: gradient.linear(..color.map.flare),
///  )
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `color`, `gradient`, or `pattern`
/// - *Can be a contextual function*: yes
/// 
/// == Stroke (`stroke`)
/// The stroke of the code block.
/// 
/// - *Default*: `1pt + luma(240)`
/// - *Type*: `none` or `stroke`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(
///    stroke: 1pt + gradient.linear(..color.map.flare),
///  )
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block inset (`lang-inset`)
/// The inset of the language block.
/// 
/// This only applies if you're using the default language block formatter.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-inset: 5pt)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block outset (`lang-outset`)
/// The X and Y outset of the language block, applied as a `dx` and `dy` during
/// the `place` operation.
/// 
/// This applies in every case, whether or not you're using the default language
/// block formatter.
/// 
/// The default value is chosen to get rid of the `inset` applied to each line.
/// 
/// - *Default*: `(x: 0.32em, y: 0pt)`
/// - *Type*: `dict`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-outset: (x: -10pt, y: 5pt))
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block radius (`lang-radius`)
/// The radius of the language block.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-radius: 10pt)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block stroke (`lang-stroke`)
/// The stroke of the language block.
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `stroke`, or a function that takes in the language dict or none
/// (see argument `languages`) and returns a stroke.
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-stroke: 1pt + red)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
///  #codly(lang-stroke: (lang) => 2pt + lang.color)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block fill (`lang-fill`)
/// The fill of the language block.
/// 
/// - *Default*: `none`
/// - *Type*: `none`, `color`, `gradient`, `pattern`, or a function that takes in
/// the language dict or none (see argument `languages`) and returns a fill.
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-fill: red)
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
///  #codly(lang-fill: (lang) => lang.color.lighten(40%))
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Language block formatter (`lang-format`)
/// The formatter for the language block.
/// 
/// A value of `none` will not display the language block.
/// To use the default formatter, use `auto`.
/// 
/// - *Default*: `auto`
/// - *Type*: `function`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(lang-format: (..) => [ No! ])
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Line number formatter (`number-format`)
/// The formatter for line numbers.
/// 
/// - *Default*: `numbering.with("1")`
/// - *Type*: `function`
/// - *Can be a contextual function*: false
/// 
/// #pre-example()
/// #example(````
///  #codly(number-format: (n) => numbering("I.", n))
///  ```
///  print('Hello, world!')
///  print('Goodbye, world!')
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Line number alignment (`number-align`)
/// The alignment of the line numbers.
/// 
/// - *Default*: `left + horizon`
/// - *Type*: `top`, `horizon`, or `bottom`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(number-align: right + horizon)
///  ```py
///  # Iterative Fibonacci
///  # As opposed to the recursive
///  # version
///  def fib(n):
///    if n <= 1:
///      return n
///    last, current = 0, 1
///    for _ in range(2, n + 1):
///      last, current = current, last + current
///    return current
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Smart indentation (`smart-indent`)
/// Whether to use smart indentation, which will check for indentation on a line
/// and use a bigger left side inset instead of spaces. This allows for linebreaks
/// to continue at the same level of indentation. This is off by default
/// since it is slower.
/// 
/// - *Default*: `false`
/// - *Type*: `bool`
/// - *Can be a contextual function*: no
/// 
/// #pre-example()
/// #example(````
///  #codly(smart-indent: true)
///  ```py
///  def fib(n):
///    if n <= 1:
///      return n
///    else:
///      return (fib(n - 1) + fib(n - 2))
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Bêta: Annotations (`annotations`)
/// The annotations to display on the code block.
/// 
/// A list of annotations that are automatically numbered and displayed on the
/// right side of the code block.
/// 
/// Each entry is a dictionary with the following keys:
/// - `start`: the line number to start the annotation
/// - `end`: the line number to end the annotation, if missing or `none` the
///   annotation will only contain the start line
/// - `content`: the content of the annotation as a showable value, if missing
///   or `none` the annotation will only contain the number
/// - `label`: *if and only if* the code block is in a `figure`, sets the label
///   by which the annotation can be referenced.
/// 
/// Generally you probably want the `content` to be contained within a `rotate(90deg)`.
/// 
/// As with other code block settings, annotations are reset after each code block.
/// 
/// *Note*: Annotations cannot overlap.
/// 
/// *Known issues*:
/// - Annotations that spread over a page break will not work correctly.
/// - Annotations on the first line of a code block will not work correctly.
/// - Annotations that span lines that overflow (one line of code <-> two lines of text)
///   will not work correctly.
/// 
/// This should be considered a Bêta feature.
///  
///
/// - *Default*: `none`
/// - *Type*: `array` or `none`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(smart-indent: true, annotation-format: none)
///  #codly(annotations: ((start: 1, end: 4, content: block(width: 2em, rotate(-90deg, align(center, box(width: 100pt)[Function body])))), ))
///  ```py
///  def fib(n):
///   if n <= 1:
///    return n
///   else:
///    return (fib(n-1)+fib(n-2))
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Bêta: Annotation format (`annotation-format`)
/// The format of the annotation number.
/// 
/// Can be `none` or a function that formats the annotation number.
/// 
/// - *Default*: `numbering.with("(1)")`
/// - *Type*: `none` or `function`
/// - *Can be a contextual function*: no
/// 
/// == Highlights (`highlights`)
/// You can apply highlights to the code block using the `highlights` argument.
/// It consists of a list of dictionaries, each with the following keys:
/// - `line`: the line number to start highlighting
/// - `start`: the character position to start highlighting, zero if omitted or `none`
/// - `end`: the character position to end highlighting, the end of the line if omitted or `none`
/// - `fill`: the fill of the highlight, defaults to the default color
/// - `tag`: an optional tag to be displayed alongside the highlight.
/// - `label`: *if and only if* the code block is in a `figure`, and it has a `tag`,
///   sets the label by which the highlight can be referenced.
/// 
/// As with other code block settings, annotations are reset after each code block.
/// 
/// *Note*: This feature performs what I loosely call "globbing", this means that instead of highlighting
/// individual characters, it highlights the whole word or sequence of characters that the start and end
/// positions are part of. This is done to avoid having to deal with the complexity of highlighting
/// individual characters, and needing to re-style them manually. While also making the API a tad less error
/// prone at the cost of sometimes goofy looking highlights if they overlap.
/// 
/// *Limitation*: If there is a `tag` and the line overflows, it can look kind of goofy. This is a trade-off,
/// as it would need to either use a grid which will prevent overflowing all together, or use a more complex
/// multi-box based system (which is what is used) that can sometimes look goofy (see example below).
/// 
/// - *Default*: `none`
/// - *Type*: `array` or `none`
/// - *Can be a contextual function*: yes
/// 
/// #pre-example()
/// #example(````
///  #codly(highlights: (
///   (line: 3, start: 4, end: none, fill: red),
///   (line: 4, start: 14, end: 22, fill: green, tag: "(a)"),
///   (line: 4, start: 29, end: 38, fill: blue, tag: "(b)"),
///  ))
///  ```py
///  def fib(n):
///    if n <= 1:
///      return n
///    else:
///      return (fib(n - 1) + fib(n - 2))
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// #pre-example()
/// #example(````
///  #codly(highlights: (
///   (line: 0, start: 7, end: 13, fill: green, tag: "Call"),
///   (line: 0, fill: blue, tag: "Statement"),
///   (line: 1, start: 7, end: 13, fill: green, tag: "Call"),
///   (line: 1, fill: blue, tag: "Statement"),
///  ))
///  ```py
///  print(fib(25))
///  print(fib(25))
///  ```
/// ````, mode: "markup", scale-preview: 100%)
/// 
/// == Highlight radius (`highlight-radius`)
/// The radius of the border of the highlights.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// == Highlight fill (`highlight-fill`)
/// The fill transformer of the highlights, is a function that
/// takes in the highlight color and returns a fill.
///
/// - *Default*: `(color) => color.lighten(80%)`
/// - *Type*: `function`
/// - *Can be a contextual function*: no
/// 
/// == Highlight stroke (`highlight-stroke`)
/// The stroke transformer of the highlights, is a function that
/// takes in the highlight color and returns a stroke.
/// 
/// - *Default*: `(color) => 0.5pt + color`
/// - *Type*: `function`
/// - *Can be a contextual function*: no
/// 
/// == Highlight inset (`highlight-inset`)
/// The inset of the highlights.
/// 
/// - *Default*: `0.32em`
/// - *Type*: `length`
/// - *Can be a contextual function*: yes
/// 
/// == Reference mode (`reference-by`)
/// The mode by which references are displayed.
/// Two modes are available:
/// - `line`: references are displayed as line numbers
/// - `item`: references are displayed as items, i.e by the `tag` for highlights
///   and `content` for annotations
/// 
/// - *Default*: `"line"`
/// - *Type*: `str`
/// - *Can be a contextual function*: yes
/// 
/// == Reference separator (`reference-sep`)
/// The separator to use between the figure reference and the reference itself.
/// 
/// - *Default*: `"-"`
/// - *Type*: `str`
/// - *Can be a contextual function*: yes
/// 
/// == Reference number format (`reference-number-format`)
/// The format of the reference number line number, only used if `reference-by`
/// is set to `"line"`.
/// 
/// - *Default*: `numbering.with("1")`
/// - *Type*: `function`
/// - *Can be a contextual function*: no
/// 
/// == Breakable (`breakable`)
/// Whether the code block is breakable.
/// 
/// - *Default*: `false`
/// - *Type*: `bool`
/// - *Can be a contextual function*: no
#let codly(
  ..args,
) = {
  let pos = args.named()

  if args.pos().len() > 0 {
    panic("codly: no positional arguments are allowed")
  }

  for (key, arg) in __codly-args {
    if key in pos {
      // Remove the argument from the list.
      let i = pos.remove(key)

      // Update the state.
      (arg.update)(i)
    }
  }

  // Special code that checks that languages are valid.
  context {
    let languages = (__codly-args.languages.get)()
    for (key, lang) in languages {
      if type(lang) != dictionary and type(lang) != str {
        panic("codly: language " + key + " is not a dictionary")
      }

      if type(lang) == dictionary and "name" not in lang {
        panic("codly: language " + key + " is missing a name")
      }
    }
  }

  if pos.len() > 0 {
    panic("codly: unknown arguments: " + pos.keys().join(", "))
  }
}

// Resets the codly state to its default values.
// This is useful if you want to reset the state of codly to its default values.
// 
// Note that this is mostly intended for testing purposes.
#let codly-reset() = {
  for (_, arg) in __codly-args {
    (arg.reset)()
  }
}

/// Initializes the codly show rule.
///
/// ```typ
/// #show: codly-init
/// ```
#let codly-init(
  body,
) = {
  show figure.where(kind: raw): it => {
    if "label" in it.fields() {
      state("codly-label").update((_) => it.label)
      it
      state("codly-label").update((_) => none)
    } else {
      it
    }
  }

  let get-parts(heading) = {
    let num = heading.body.children.at(0)
    let lbl = heading.body.children.at(1)
    (num.body, label(lbl.body.text))
  }

  // Levels chosen randomly.
  let level-highlight = 39340
  let level-annot = 30246
  show ref: it => context if it.element != none and it.element.func() == heading and it.element.level == level-highlight {
    let sep = (__codly-args.reference-sep.get)()
    let (tag, label) = get-parts(it.element)
    link(it.target, (
      ref(label), sep, tag
    ).join())
  } else if it.element != none and it.element.func() == heading and it.element.level == level-annot {
    let sep = (__codly-args.reference-sep.get)()
    let (num, label) = get-parts(it.element)
    link(it.target, (
      ref(label), sep, num
    ).join())
  } else {
    it
  }

  show raw.where(block: true): it => context {
    let indent_regex = regex("\\s*")
    let args = __codly-args
    let range = (args.range.get)()
    let in_range(line) = {
      if range == none {
        true
      } else if range.at(1) == none {
        line >= range.at(0)
      } else {
        line >= range.at(0) and line <= range.at(1)
      }
    }
    if (args.enabled.get)() != true {
      return it
    }
  
    let block-label = state("codly-label").get()
    let languages = (args.languages.get)()
    let display-names = (args.display-name.get)()
    let display-icons = (args.display-icon.get)()
    let lang-outset = (args.lang-outset.get)()
    let language-block = {
      let fn = (args.lang-format.get)()
      if fn == none {
        (..) => none
      } else if fn == auto {
        default-language-block
      } else {
        fn
      }
    }
    let default-color = (args.default-color.get)()
    let radius = (args.radius.get)()
    let offset = (args.offset.get)()
    let stroke = (args.stroke.get)()
    let zebra-color = (args.zebra-fill.get)()
    let numbers-format = (args.number-format.get)()
    let numbers-alignment = (args.number-align.get)()
    let padding = (args.inset.get)()
    let breakable = (args.breakable.get)()
    let fill = (args.fill.get)()
    let smart-indent = (args.smart-indent.get)()
    let skips = {
      let skips = (args.skips.get)()
      if skips == none {
        ()
      } else {
        skips.sorted(key: (x) => x.at(0)).dedup()
      }
    }
    let skip-line = (args.skip-line.get)()
    let skip-number = (args.skip-number.get)()

    let reference-by = (args.reference-by.get)()
    if not reference-by in ("line", "item") {
      panic("codly: reference-by must be either 'line' or 'item'")
    }

    let reference-sep = (args.reference-sep.get)()
    let reference-number-format = (args.reference-number-format.get)()

    let annotation-format = {
      let fn = (args.annotation-format.get)()
      if fn == none {
        (_) => none
      } else {
        fn
      }
    }
    let annotations = {
      let annotations = (args.annotations.get)()
      annotations = if annotations == none {
        ()
      } else {
        annotations
          .sorted(key: (x) => x.start)
          .map((x) => {
            if (not "end" in x) or x.end == none {
              x.insert("end", x.start)
            }

            if (not "content" in x) {
              x.insert("content", none)
            }

            if "label" in x and block-label == none {
              panic("codly: label " + str(x.label) + " is only allowed in a figure block")
            }

            x
          })
      }

      // Check for overlapping annotations.
      let current = none
      for a in annotations {
        if current != none and a.start <= current.end {
          panic("codly: overlapping annotations")
        }
        current = a
      }

      annotations
    }
    let has-annotations = annotations != none and annotations.len() > 0

    let highlight-stroke = (args.highlight-stroke.get)()
    let highlight-fill = (args.highlight-fill.get)()
    let highlight-radius = (args.highlight-radius.get)()
    let highlight-inset = (args.highlight-inset.get)()
    let highlights = {
      let highlights = (args.highlights.get)()
      if highlights == none {
        ()
      } else {
        highlights
          .sorted(key: (x) => x.line)
          .map((x) => {
            if not "start" in x or x.start == none {
              x.insert("start", 0)
            }

            if not "end" in x or x.end == none {
              x.insert("end", 999999999)
            }

            if not "fill" in x {
              x.insert("fill", default-color)
            }

            if "label" in x and block-label == none {
              panic("codly: label " + str(x.label) + " is only allowed in a figure block")
            }
            x
          })
      }
    }

    let start = if range == none { 1 } else { range.at(0) };

    // Get the widest annotation.
    let annot-bodies-width = annotations.map((x) => x.content).map(measure).map((x) => x.width)
    let num = annotation-format(annotations.len())
    let lr-width = measure(math.lr("}", size: 5em) + num).width;
    let annot-width = annot-bodies-width.fold(0pt, (a, b) => calc.max(a, b)) + 2 * padding + lr-width

    // Get the height of an individual line.
    let line-height = measure(it.lines.at(0, default: [`Hello, world!`])).height + 2 * padding

    let items = ()
    let height = measure[1].height
    let current-annot = none
    let first-annot = false
    let annots = 0
    for (i, line) in it.lines.enumerate() {
      first-annot = false

      // Check for annotations
      let annot = annotations.at(0, default: none)
      if annot != none and i == annot.start {
        current-annot = annot
        first-annot = true
        annots += 1
      }

      // Cleanup annotations
      if current-annot != none and i > current-annot.end {
        current-annot = none
        _ = annotations.remove(0)
      }

      // Annotation printing
      let annot(extra: none) = if current-annot != none and first-annot {
        let height = line-height * (current-annot.end - current-annot.start + 1)
        let num = annotation-format(annots)
        let label = if "label" in current-annot and current-annot.label != none {
          let referenced = if reference-by == "line" {
            reference-number-format(line.number + offset)
          } else {
            num
          }
          place(hide[#heading(level: level-annot)[#box(referenced)#box(str(block-label))] #current-annot.label])
        } else {
          none
        }

        let annot-content = {
          $lr(}, size: #height) #num #current-annot.content #label$
        }

        (grid.cell(
          rowspan: current-annot.end - current-annot.start + 1,
          align: left + horizon,
          annot-content + extra
        ), )
      } else if current-annot != none or not has-annotations {
        ()
      } else {
        (extra, )
      }

      // Try and look for a skip
      let skip = skips.at(0, default: none)
      if skip != none and i == skip.at(0) {
        items.push(skip-number)
        items.push(skip-line)
        // Advance the offset.
        offset += skip.at(1)
        _ = skips.remove(0)
      }

      if not in_range(line.number) {
        continue
      }

      // Always push the formatted line number
      let l = line.body

      // Must be done before the smart indentation code.
      // Otherwise it results in two paragraphs.
      if numbers-format != none {
        items.push(numbers-format(line.number + offset))
      } else {
        l += box(height: height, width: 0pt)
      }

      // Apply highlights
      let hl = highlights.at(0, default: none)
      let highlighted = l
      while hl != none and i == hl.line {
        let fill = highlight-fill(hl.fill)
        let stroke = highlight-stroke(hl.fill)
        let tag = if "tag" in hl { hl.tag } else { none }
        assert(l.has("children"), message: "highlighted line must have children")

        let get-len(child) = {
          let len = 0
          let fields = child.fields()

          if "children" in fields {
            for c in fields.children {
              len += get-len(c)
            }
          } else if "text" in fields {
            len += fields.text.len()
          } else if "child" in fields {
            len += get-len(fields.child)
          } else if "body" in fields {
            len += get-len(fields.body)
          } else {
            
          }

          return len
        }

        let children = ()
        let collection = none
        let i = 0
        let len = highlighted.children.len()
        for (index, child) in highlighted.children.enumerate() {
          let last = index == len - 1
          let args = child.fields()
          let len = get-len(child)

          if collection != none {
            collection.push(child)

            let label = if "label" in hl and hl.label != none {
              let referenced = if reference-by == "line" {
                reference-number-format(line.number + offset)
              } else {
                hl.tag
              }
              place(hide[#heading(level: level-highlight)[#box(referenced)#box(str(block-label))] #hl.label])
            } else {
              none
            }

            if i + len >= hl.end or last {
              if tag == none {
                children.push(box(
                  radius: highlight-radius,
                  clip: true,
                  fill: fill,
                  stroke: stroke,
                  inset: highlight-inset,
                  baseline: highlight-inset,
                  collection.join() + label
                ))
              } else {
                let col = collection.join()
                let height-col = measure(col).height
                let height-tag = measure(tag).height
                let max-height = calc.max(height-col, height-tag) + 2 * highlight-inset
                children.push(box(
                  radius: (
                    top-right: 0pt,
                    bottom-right: 0pt,
                    rest: highlight-radius,
                  ),
                  height: max-height,
                  clip: true,
                  fill: fill,
                  stroke: stroke,
                  inset: highlight-inset,
                  baseline: highlight-inset,
                  collection.join()
                ))
                children.push(h(0pt, weak: true))
                children.push(box(
                  radius: (
                    top-left: 0pt,
                    bottom-left: 0pt,
                    rest: highlight-radius,
                  ),
                  height: max-height,
                  clip: true,
                  fill: fill,
                  stroke: stroke,
                  inset: highlight-inset,
                  baseline: highlight-inset,
                  tag + label
                ))
              }
              collection = none
            }
          } else if collection == none and (i >= hl.start or i + len >= hl.start) and (i < hl.end) {
            collection = (child, )
          } else {
            children.push(child)
          }

          i += len
        }

        highlighted = children.join()
        _ = highlights.remove(0)
        hl = highlights.at(0, default: none)
      }


      // Smart indentation code.
      if smart-indent and l.has("children") {
        // Check the indentation of the line by taking l,
        // and checking for the first element in the sequence.
        let first = l.children.at(0, default: none)
        if first != none and first.has("text") {
          let match = first.text.match(indent_regex)

          // Ensure there is a match and it starts at the beginning of the line.
          if match != none and match.start == 0 {
            // Calculate the indentation.
            let indent = match.end - match.start

            // Then measure the necessary indent.
            let indent = first.text.slice(match.start, match.end)
            let width = measure([#indent]).width

            // We add the indentation to the line.
            highlighted = {
              set par(hanging-indent: width)
              highlighted
            }
          }
        }
      }

      if line.number != start or (display-names != true and display-icons != true) {
        items = (..items, highlighted, ..annot())
        continue
      } else if it.lang == none {
        items = (..items, highlighted, ..annot())
        continue
      }
      
      // The language block (icon + name)
      let language-block = if it.lang in languages {
        let lang = languages.at(it.lang);
        let name = if type(lang) == str {
          lang
        } else if display-names and "name" in lang  {
          lang.name
        } else {
          []
        }
        let icon = if display-icons and "icon" in lang {
          lang.icon
        } else {
          []
        }
        let color = if "color" in lang {
          lang.color
        } else {
          default-color
        }
        (language-block)(name, icon, color)
      } else if display-names {
        (language-block)(it.lang, [], default-color)
      }

      // Push the line and the language block in a grid for alignment
      let lb = measure(language-block);

      if has-annotations {
        items = (..items, highlighted, ..annot(extra: place(
          right + horizon,
          dx: lang-outset.x,
          dy: lang-outset.y,
          language-block
        )))
      } else {
        items.push(grid(
          columns: (1fr, lb.width + 2 * padding),
          highlighted,
          place(
            right + horizon,
            dx: lang-outset.x,
            dy: lang-outset.y,
            language-block
          ),
        ))
      }
    }

    // If the fill or zebra color is a gradient, we will draw it on a separate layer.
    let is-complex-fill = ((type(fill) != color and fill != none) 
        or (type(zebra-color) != color and zebra-color != none))

    return {
      block(
        breakable: breakable,
        clip: true,
        width: 100%,
        radius: radius,
        stroke: stroke,
        {
          if is-complex-fill {
            // We use place to draw the fill on a separate layer.
            place(
              grid(
                columns: if has-annotations {
                  (1fr, annot-width)
                } else {
                  (1fr, )
                },
                stroke: none,
                inset: padding * 1.5,
                fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
                  zebra-color
                } else {
                  fill
                },
                ..it.lines.map((line) => hide(line))
              )
            )
          }
          if numbers-format != none {
            grid(
              columns: if has-annotations {
                (auto, 1fr, annot-width)
              } else {
                (auto, 1fr)
              },
              inset: padding * 1.5,
              stroke: none,
              align: (numbers-alignment, left + horizon),
              fill: if is-complex-fill {
                none
              } else {
                (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
                  zebra-color
                } else {
                  fill
                }
              },
              ..items,
            )
          } else {
            grid(
              columns: if has-annotations {
                (1fr, annot-width)
              } else {
                (1fr)
              },
              inset: padding * 1.5,
              stroke: none,
              align: (numbers-alignment, left + horizon),
              fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
                zebra-color
              } else {
                fill
              },
              ..items,
            )
          }
        }
      )

      codly-offset()
      codly-range(start: 1, end: none)
      state("codly-skips").update((_) => ())
      state("codly-annotations").update((_) => ())
      state("codly-highlights").update((_) => ())
    }
  }

  body
}

/// Allows setting codly setting locally.
/// Anything that happens inside the block will have the settings applied only to it.
/// The pre-existing settings will be restored after the block. This is useful
/// if you want to apply settings to a specific block only.
/// 
/// #pre-example()
/// #example(`````
///  *Special:*
///  #local(default-color: red)[
///    ```
///    Hello, world!
///    ```
///  ]
/// 
///  *Normal:*
///  ```
///  Hello, world!
///  ```
/// `````, mode: "markup", scale-preview: 100%)
#let local(body, ..args) = context {
  let old = __codly-save()
  codly(..args)
  body
  __codly-load(old)
}