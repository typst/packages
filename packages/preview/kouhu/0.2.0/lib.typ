/// Get all builtin texts. Returns in `dictionary[string, list[string]]`.
/// 
/// *Example:*
/// Show the number of paragraphs in each builtin text.
/// #example(`#builtin-text-list().pairs().map(p => (p.at(0), p.at(1).len())))`, mode: "markup")
///
/// -> dictionary
#let builtin-text-list() = {
  return json("data/zhlipsum.json")
}

/// Output selected Chinese lorem ipsum paragraphs.
///
/// *Example 1:*
/// Cut the first several characters of a paragraph from Lu Xun's _Zhufu_（《祝福》）.
/// #example(`#kouhu(builtin-text: "zhufu", indices: 18, length: 99)`, mode: "markup")
///
/// *Example 2:*
/// Cut multiple paragraphs from _Zhufu_.
/// #example(`#kouhu(builtin-text: "zhufu", offset: 5, indices: (2, 18), length: 31, between-para: "——")`, mode: "markup")
///
/// *Example 3:*
/// Repeat some text until the specified length.
/// #example(`#kouhu(custom-text: ("奥利",), between-para: none, length: 31)`, mode: "markup")
/// - builtin-text (string): Name of the builtin text, see @@builtin-text-list() for a full list and length.
/// - custom-text (array): Custom text to use. If not `none`, `builtin-text` will be ignored.
/// - offset (int): Offset of the paragraph to start from.
/// - indices (int, array): Indices (*NOT RANGE*) of paragraphs to use (`offset` will be added). A single integer means a single paragraph, an array means multiple paragraphs, and `none` means all paragraphs. Any out-of-bound index will be ignored.
/// - length (int): Length of grapheme (characters) to print. `kouhu` will repeat over selected paragraphs until `length` is reached, and the final paragraph will likely be truncated. 0 for unlimited, i.e. print all selected paragraphs for only once.
/// - before-para (content): Content inserted before each paragraph.
/// - after-para (content): Content inserted after each paragraph.
/// - between-para (content): Content inserted between two paragraphs (has no effect if only one paragraph is selected).
/// -> doc
#let kouhu(
  builtin-text: "simp",
  custom-text: none,
  offset: 0,
  indices: none,
  length: 0,
  before-para: none,
  after-para: none,
  between-para: parbreak(),
) = {

  // load builtin text or use custom text
  let text = custom-text
  if text == none {
    let data = builtin-text-list()
    if builtin-text in data {
      text = data.at(builtin-text)
    } else {
      panic("Builtin text '" + builtin-text + "' not found")
    }
  }

  // normalize indices
  let selected_para = ()
  indices = if indices == none {
    range(1, text.len() + 1)
  } else if type(indices) == int {
    (indices,)
  } else {
    indices
  }

  // select paragraphs according to argument, and
  // truncate to specified length of grapheme
  let length_set = false
  let remaining = 1e10 // use a large number here
  if length > 0 {
    remaining = length
    length_set = true
  }
  while remaining > 0 {
    for i in indices {
      let i_ = i + offset - 1
      if i_ >= 0 and i_ < text.len() {
        let t = text.at(i_).clusters()
        if t.len() > remaining {
          selected_para.push(t.slice(0, remaining).join())
          remaining = 0
          break
        } else {
          selected_para.push(t.join())
          remaining -= t.len()
        }
      }
    }
    // break if user does not specify length
    if not length_set {
      break
    }
  }

  // print paragraphs
  let i = 0
  for p in selected_para {
    if before-para != "" {
      before-para
    }
    p
    if after-para != "" {
      after-para
    }
    if between-para != "" and i < selected_para.len() - 1 {
      between-para
    }
    i += 1
  }

}
