#let to_string(it) = {
  if it == none {
    " "
  } else if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to_string).join()
  } else if it.has("body") {
    to_string(it.body)
  } else if it == [ ] {
    " "
  }
}

// first letter
#let first_letter(it) = {
  if type(it) == str {
    lower(it.at(0))
  } else if it.has("text") {
    lower(it.text.at(0))
  } else {
    panic("it must be a string or an array of string")
  }
}

#let _amlos_dict = state("amlos-dict", ())

/// strict: if true, same word in different form/case/style will be treated as different word
/// keepform: if true, the word will be kept in its original form for some proper nouns like "iPhone"
///  or symbols
#let index(group: "default", word, strict: false, keepform: false, modifier: none) = context {
  if type(group) != str {
    panic("group must be a string")
  }
  // the index of amlos-dict give a unique cat to the word
  let record = (
    group: group,
    key: if strict { word } else { lower(to_string(word)) },
    word: word,
    keepform: keepform,
    modifier: modifier,
    loc: here(),
  )
  _amlos_dict.update(old => old + (record,))

  word
}


#let use_word_list(group, cat_func: first_letter, fn) = context {
  let group = if type(group) == str {
    (group,)
  } else if type(group) == array {
    group
  } else {
    panic("group must be a string or an array of string")
  }

  let res = (:)
  let last_page = none
  let max_page = none
  let min_page = none
  let max_page_loc = none
  let min_page_loc = none

  let queried = _amlos_dict.get().filter(it => it.group in group).sorted(key: it => (it.key, to_string(it.modifier)))

  for (key, keepform, word, modifier, loc) in queried {
    // filter the word by group
    let int_page_num = counter(page).at(loc).at(0)
    let page_num = if loc.page-numbering() == none {
      int_page_num
    } else {
      numbering(loc.page-numbering(), int_page_num)
    }

    let linked_page_num = link(loc, page_num)
    let cat = cat_func(word)

    // if the word is not in the result, we need to add a new record
    // if the word is in the result, we need to check if it is a new word
    if not cat in res or res.at(cat).last().key != key {
      let record = (
        key: key,
        word: if keepform { word } else { lower(word) },
        children: (
          (
            modifier: modifier,
            loc: (linked_page_num,),
          ),
        ),
      )
      res.insert(cat, (..res.at(cat, default: ()), record))
      max_page = int_page_num
      min_page = int_page_num
      min_page_loc = linked_page_num
      max_page_loc = linked_page_num
    } else if lower(res.at(cat).last().children.last().modifier) != lower(modifier) {
      // if the modifier is different, we need to add a new record
      res.at(cat).last().children.push((modifier: modifier, loc: (linked_page_num,)))
    } else if last_page != int_page_num {
      // for same word and same modifier, but different page
      res.at(cat).last().children.last().loc.push(linked_page_num)
    }


    res.at(cat).last().min_page = if min_page < int_page_num {
      min_page_loc
    } else {
      min_page = int_page_num
      min_page_loc = linked_page_num
      linked_page_num
    }

    res.at(cat).last().max_page = if max_page > int_page_num {
      max_page_loc
    } else {
      max_page = int_page_num
      max_page_loc = linked_page_num
      linked_page_num
    }

    last_page = int_page_num
  }

  fn(res)
}

