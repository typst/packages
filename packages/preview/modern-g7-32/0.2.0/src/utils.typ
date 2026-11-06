#let small-text = body => context {
  let target-size = query(<modern-g7-32-parameters>)
    .first()
    .value
    .small-text-size
  set text(size: target-size)
  body
}

#let fetch-field(field, expected-keys, default: (:), hint: "") = {
  let expected-keys-arg-error = "Ожидаемые ключи должны быть списком строк, например '(arg1*, arg2), здесь arg1 - обязательный агрумент, а arg2 - необязательный'"

  assert(type(expected-keys) == array, message: expected-keys-arg-error)
  assert(
    expected-keys.map(elem => type(elem)).all(elem => elem == str),
    message: expected-keys-arg-error,
  )

  assert(
    type(default) == dictionary,
    message: "Стандартные значения должны быть определены в словаре, например: 'default: (arg1: false)'",
  )
  assert(
    default.len() <= expected-keys.len(),
    message: "Количество стандартных значений должно быть не больше числа ожидаемых аргументов",
  )

  let get-default(key) = (key, default.at(key, default: none))

  let clean-expected-keys = expected-keys.map(key => key.replace("*", ""))
  let required-keys = expected-keys
    .filter(key => key.at(-1) == "*")
    .map(key => key.slice(0, -1))
  let not-required-keys = expected-keys.filter(key => key.at(-1) != "*")

  if type(field) == type(none) {
    return clean-expected-keys.map(get-default).to-dict()
  }

  if type(field) == dictionary {
    for key in required-keys {
      assert(
        key in field.keys(),
        message: "В словаре "
          + hint
          + " отсутствует обязательный ключ '"
          + key
          + "'",
      )
    }
    for key in field.keys() {
      assert(
        key in clean-expected-keys,
        message: "В словаре "
          + hint
          + " обнаружен неожиданный ключ '"
          + key
          + "', допустимые ключи: "
          + repr(expected-keys),
      )
    }
    let result = clean-expected-keys.map(get-default).to-dict()
    for (key, value) in field {
      result.insert(key, value)
    }
    return result
  } else if type(field) == array {
    assert(
      field.len() >= required-keys.len(),
      message: "В списке "
        + hint
        + " указаны не все обязательные элементы: "
        + repr(required-keys),
    )
    assert(
      field.len() <= expected-keys.len(),
      message: "В списке "
        + hint
        + " указано слишком много аргументов, требуемые: "
        + repr(expected-keys),
    )
    let result = (:)
    for (i, key) in clean-expected-keys.enumerate() {
      result.insert(key, field.at(i, default: default.at(key, default: none)))
    }
    return result
  } else if type(field) in (str, int, length) {
    let result = clean-expected-keys.map(get-default).to-dict()
    result.insert(clean-expected-keys.at(0), field)
    return result
  } else {
    panic(
      "Некорректный тип поля "
        + repr(type(field))
        + "("
        + repr(field)
        + ") используйте словарь, список или строку для значения "
        + hint,
    )
  }
}

#let unbreak-name(name) = {
  if name == none { return }
  return name.replace(" ", "\u{00A0}")
}

#let sign-field(name, position, part: none, details: "подпись, дата") = {
  let part-cell = []
  if part != none {
    part-cell = table.cell(align: top)[(#small-text[#part])]
  }

  set par(justify: false)
  table(
    stroke: none,
    inset: (x: 0pt, y: 3pt),
    columns: (5fr, 1fr, 3fr, 1fr, 3fr),
    [#position], [], [], [], table.cell(align: bottom)[#unbreak-name(name)],
    table.hline(start: 2, end: 3),
    [], [], table.cell(align: center)[#small-text[#details]], [], part-cell
  )
}

#let get-numbering-alphabet(number) = {
  let alphabet = (
    "а",
    "б",
    "в",
    "г",
    "д",
    "е",
    "ж",
    "з",
    "и",
    "к",
    "л",
    "м",
    "н",
    "о",
    "п",
    "р",
    "с",
    "т",
    "у",
    "ф",
    "х",
    "ц",
    "ч",
    "ш",
    "щ",
    "э",
    "ю",
    "я",
  )
  let result = ""

  while number > 0 {
    result = alphabet.at(calc.rem(number - 1, 28)) + result
    number = calc.floor(number / 28)
  }

  return result
}

#let heading-numbering(..nums) = {
  nums = nums.pos()
  let letter = upper(get-numbering-alphabet(nums.first()))
  let rest = nums.slice(1).map(elem => str(elem))
  if rest != none {
    return (letter, rest).flatten().join(".")
  }
  return letter
}

#let enum-numbering(number) = {
  return [#get-numbering-alphabet(number))]
}
