#let plg = plugin("cjk_num_format.wasm")

/// Generate a string with the given value formatted with thousands separators.
/// ```example
/// #set text(lang: "ja", region: "jp")
/// #cnm.sep-by-ten-thousands(12345670000000)\
/// #cnm.sep-by-ten-thousands(1145141919810)\
/// #cnm.sep-by-ten-thousands(1145141919810000)\
/// #cnm.sep-by-ten-thousands(135700012255)\
/// ```
///
/// - value (int): The number to format.
/// - separators (array): An array of strings to use as thousands separators.
/// - lang (str): The language code to use for formatting (e.g., "en", "zh").
/// - region (str): The region code to use for formatting (e.g., "US", "CN").
/// -> str
#let sep-by-ten-thousands(
  value,
  separators: none,
  lang: none,
  region: none,
) = context {
  // we're not using `numbering` here because `numbering('壹', xxx) doesn't support korean`
  str(
    plg.sep_by_ten_thousands(
      cbor.encode((
        lang: if lang == none { text.lang } else { lang },
        region: if region == none { text.region } else { region },
        value: value,
        separators: separators,
      )),
    ),
  )
}

#let fallback(data, seq, default: none) = {
  if seq.len() == 0 {
    return default
  }
  data.at(seq.at(0), default: fallback(data, seq.slice(1), default: default))
}

/// A flexible content function that returns a value based on the current language and region.
///
/// - ..args (named arguments): Named arguments that can be used to specify the content for different languages and regions.
/// Example:
/// ```typ
/// #flex-content(
///   ja: "for Japanese",
///   ko: "for Korean",
///   zh: (
///    cn: [For China Mainland],
///    sg: 123123,
///    tw: "for Taiwan",
///   ),
///   en: (
///    ie: "Aye class!",
///    us: [Ishowmeat],
///    gb: 3443.234,
///   )
/// )
/// ```
/// - fallback-sequence (dict): The fallback sequence in case the language or region is not supported.
/// -> content
#let flex-content(
  fallback-sequence: (
    zh: (
      // Simplified Realms
      cn: ("sg", "tw", "hk", "mo"),
      sg: ("cn", "tw", "hk", "mo"),
      // Traditional Funland
      tw: ("hk", "mo", "cn", "sg"),
      hk: ("tw", "cn", "sg", "mo"),
      mo: ("tw", "cn", "sg", "hk"),
      // Standard(R)
      default: ("cn", "tw", "hk", "mo", "sg"),
    ),
    // how did I even come up with this?
    default: ("zh", "ja", "en", "ko"),
  ),
  ..args,
) = context {
  let (l, r) = (text.lang, text.region)
  if r == none {
    r = "default"
  } else {
    r = lower(r)
  }
  let a = args.at(l, default: fallback(args.named(), fallback-sequence.default))
  if type(a) == str {
    a
  } else if type(a) == dictionary {
    a.at(
      r,
      default: {
        fallback(a, fallback-sequence.at(l, default: (:)).at(r, default: ()))
      },
    )
  }
}


#let _year-with-beginning(pfx, negative-pfx: none, year, arabic) = {
  let year-str = flex-content(
    zh: "年",
    ja: "年",
    ko: "년",
  )
  let first-year = flex-content(
    zh: "元年",
    ja: "元年",
    ko: "원년",
  )
  if arabic {
    // If arabic is true, return the year in Arabic numerals
    if year < 0 {
      negative-pfx + str(calc.abs(year)) + year-str
    } else if year == 0 {
      pfx + first-year
    } else {
      pfx + str(year + 1) + year-str
    }
  } else {
    if year < 0 {
      negative-pfx + numbering("一", calc.abs(year)) + year-str
    } else if year == 0 {
      pfx + first-year
    } else if year <= 100 {
      pfx + numbering("一", year + 1) + year-str
    } else {
      let year-char-map = "〇一二三四五六七八九十".clusters()
      let y = year + 1
      let ret = ""
      while y != 0 {
        ret = year-char-map.at(calc.rem(y, 10)) + ret
        y = calc.floor(y / 10)
      }
      pfx + ret + year-str
    }
  }
}

/// Format a date in CJK style, including the year, month, and day.
/// ```example
/// #cnm.cjk-date-format(
///   datetime(year: 2023, month: 10, day: 1),
/// )
/// ```
///
/// - pfx (str, content): Prefix for the date string.
/// ```example
/// #cnm.cjk-date-format(
///   pfx: "西元",
///   datetime(year: 2023, month: 10, day: 1),
/// )
/// ```
/// - negative-pfx (str, content): Prefix for negative years.
/// ```example
/// #cnm.cjk-date-format(
///   negative-pfx: "西元前",
///   datetime(year: -2023, month: 10, day: 1),
/// )
/// ```
/// - date (datetime): The date to format.
/// - established (int): The year when the era was established.
/// - arabic (auto, bool): Whether to use Arabic numerals for the year.
/// ```example
/// #cnm.cjk-date-format(
///   arabic: true,
///   datetime(year: 2023, month: 10, day: 1),
/// )
/// ```
/// - alternative-january (auto, bool): Whether to use "元月" for January.
/// ```example
/// #cnm.cjk-date-format(
///   alternative-january: true,
///   datetime(year: 2023, month: 1, day: 1),
/// )
/// ```
/// - alternative-20 (auto, bool): Whether to use the alternative 2x day format (廿x)
/// ```example
/// #cnm.cjk-date-format(
///   alternative-20: true,
///   datetime(year: 2023, month: 2, day: 20),
/// )\
/// #cnm.cjk-date-format(
///   alternative-20: true,
///   datetime(year: 2023, month: 2, day: 25),
/// )
/// ```
/// - alternative-30 (auto, bool): Whether to use the alternative 3x day format (卅x).
/// ```example
/// #cnm.cjk-date-format(
///   alternative-30: true,
///   datetime(year: 2023, month: 3, day: 30),
/// )\
/// #cnm.cjk-date-format(
///   alternative-30: true,
///   datetime(year: 2023, month: 3, day: 31),
/// )
/// ```
/// - weekday (auto, bool, array): Whether to include the weekday in the format. The first day of the week is Monday.
/// ```example
/// #cnm.cjk-date-format(
///   weekday: true,
///   datetime(year: 2025, month: 6, day: 22),
/// )\
/// #set text(lang: "ja")
/// #cnm.cjk-date-format(
///   weekday: auto,
///   datetime(year: 2023, month: 10, day: 1),
/// )\
/// #set text(lang: "ko")
/// #cnm.cjk-date-format(
///   weekday: true,
///   datetime(year: 2023, month: 10, day: 1),
/// )\
/// #set text(lang: "zh")
/// #cnm.cjk-date-format(
///   weekday: ("牛奶奶", "柳奶奶", "卖牛奶", "柳奶", "流奶", [牛奶], [椰奶！]),
///   datetime(year: 2023, month: 10, day: 1),
/// )
/// ```
/// -> content
#let cjk-date-format(
  pfx: none,
  negative-pfx: none,
  date,
  established: 1,
  arabic: auto,
  alternative-january: auto,
  alternative-20: auto,
  alternative-30: auto,
  weekday: false,
) = context {
  let arabic = arabic
  let alternative-january = if alternative-january == auto {
    false
  } else {
    alternative-january
  }
  let alternative-20 = if alternative-20 == auto {
    false
  } else {
    alternative-20
  }
  let alternative-30 = if alternative-30 == auto {
    false
  } else {
    alternative-30
  }
  if arabic == auto {
    if text.lang == "ko" {
      arabic = true
    } else {
      arabic = false
    }
  }
  let month-str = flex-content(
    zh: "月",
    ja: "月",
    ko: "월",
  )
  let day-str = flex-content(
    zh: "日",
    ja: "日",
    ko: "일",
  )
  let ret = ""
  ret += _year-with-beginning(pfx, negative-pfx: negative-pfx, date.year() - established, arabic)
  ret += (
    if arabic {
      str(date.month())
    } else {
      let a = numbering("一", date.month())
      if alternative-january {
        a = a.replace("一", "元")
      }
      a
    }
      + month-str
  )
  ret += (
    if arabic {
      str(date.day())
    } else {
      let a = numbering("一", date.day())
      if alternative-20 {
        a = a.replace("二十", "廿")
      }
      if alternative-30 {
        a = a.replace("三十", "卅")
      }
      a
    }
      + day-str
  )
  if weekday != false {
    let weekday-strings = if weekday == auto or weekday == true {
      (
        flex-content(
          zh: "周一",
          ja: "(月)",
          ko: "월요일",
        ),
        flex-content(
          zh: "周二",
          ja: "(火)",
          ko: "화요일",
        ),
        flex-content(
          zh: "周三",
          ja: "(水)",
          ko: "수요일",
        ),
        flex-content(
          zh: "周四",
          ja: "(木)",
          ko: "목요일",
        ),
        flex-content(
          zh: "周五",
          ja: "(金)",
          ko: "금요일",
        ),
        flex-content(
          zh: "周六",
          ja: "(土)",
          ko: "토요일",
        ),
        flex-content(
          zh: "周日",
          ja: "(日)",
          ko: "일요일",
        ),
      )
    } else if type(weekday) == array {
      weekday
    }
    ret += weekday-strings.at(date.weekday() - 1)
  }
  ret
}

/// Format a date in the Republic of China (ROC) calendar style.
/// ```example
/// #cnm.roc-date-format(
///   datetime(year: 1949, month: 9, day: 30),
/// )\
/// #cnm.roc-date-format(
///   datetime(year: 1912, month: 10, day: 1),
/// )\
/// #cnm.roc-date-format(
///   datetime(year: 1910, month: 10, day: 1),
/// )\
/// #cnm.roc-date-format(
///   datetime(year: 2025, month: 10, day: 1),
/// )\
/// #cnm.roc-date-format(
///   datetime(year: 2025, month: 10, day: 1),
///   arabic: true,
/// )
/// ```
///
/// - pfx (str, content): Prefix for the date string.
/// - negative-pfx (str, content): Prefix for negative years.
/// - date (datetime): The date to format.
/// - ..args (named arguments): Additional arguments for customization. See @cjk-date-format for details.
/// -> content
#let roc-date-format(date, pfx: auto, negative-pfx: auto, ..args) = {
  let default-pfx = flex-content(
    zh: (cn: "民国", tw: "民國"),
    ja: "民国",
    ko: "민국",
  )
  let default-negative-pfx = flex-content(
    zh: "民前",
    ja: "民国前",
    ko: "민국전",
  )
  cjk-date-format(
    pfx: if pfx == auto { default-pfx } else { pfx },
    negative-pfx: if negative-pfx == auto { default-negative-pfx } else { negative-pfx },
    date,
    established: 1912,
    ..args,
  )
}

/// Format a date in the Juche calendar style (North Korea's calendar).
///
/// - pfx (str, content): Prefix for the date string.
/// - negative-pfx (str, content): Prefix for negative years.
/// - date (datetime): The date to format.
/// - ..args (named arguments): Additional arguments for customization. See @cjk-date-format for details.
/// -> content
#let juche-date-format(date, pfx: auto, negative-pfx: auto, ..args) = {
  let default-pfx = flex-content(
    zh: (cn: "主体", tw: "主體"),
    ja: "主体",
    ko: "주체",
  )
  let default-negative-pfx = flex-content(
    zh: "主体前",
    ja: "主体前",
    ko: "주체전",
  )
  cjk-date-format(
    pfx: if pfx == auto { default-pfx } else { pfx },
    negative-pfx: if negative-pfx == auto { default-negative-pfx } else { negative-pfx },
    date,
    established: 1912,
    ..args,
  )
}

/// Format a date in the Japanese era style (e.g., Meiji, Taisho, Showa, Heisei, Reiwa).
/// ```example
/// #cnm.japan-date-format(
///   datetime(year: 2023, month: 10, day: 1),
/// )\
/// #cnm.japan-date-format(
///   datetime(year: 1989, month: 1, day: 6),
/// )\
/// #cnm.japan-date-format(
///   datetime(year: 1989, month: 1, day: 7),
/// )
/// ```
/// - date (datetime): The date to format.
/// - ..args (named arguments): Additional arguments for customization. See @cjk-date-format for details.
/// -> content
#let japan-date-format(date, ..args) = {
  let meiji = datetime(year: 1868, month: 9, day: 1)
  let taisho = datetime(year: 1912, month: 7, day: 30)
  let showa = datetime(year: 1926, month: 12, day: 25)
  let heisei = datetime(year: 1989, month: 1, day: 7)
  let reiwa = datetime(year: 2019, month: 4, day: 30)
  // match the datetime
  let meiji-pfx = flex-content(
    zh: "明治",
    ja: "明治",
    ko: "명치",
  )
  let taisho-pfx = flex-content(
    zh: "大正",
    ja: "大正",
    ko: "대정",
  )
  let showa-pfx = flex-content(
    zh: "昭和",
    ja: "昭和",
    ko: "쇼와",
  )
  let heisei-pfx = flex-content(
    zh: "平成",
    ja: "平成",
    ko: "헤이세이",
  )
  let reiwa-pfx = flex-content(
    zh: "令和",
    ja: "令和",
    ko: "레와",
  )
  if date < meiji {
    cjk-date-format(date, ..args)
  } else if date < taisho {
    cjk-date-format(pfx: meiji-pfx, date, established: meiji.year(), ..args)
  } else if date < showa {
    cjk-date-format(pfx: taisho-pfx, date, established: taisho.year(), ..args)
  } else if date < heisei {
    cjk-date-format(pfx: showa-pfx, date, established: showa.year(), ..args)
  } else if date < reiwa {
    cjk-date-format(pfx: heisei-pfx, date, established: heisei.year(), ..args)
  } else {
    cjk-date-format(pfx: reiwa-pfx, date, established: reiwa.year(), ..args)
  }
}

/// Format a number in Chinese currency style. This function is based on ```typ numbering("壹", v)``` but adds units for the whole number and the first two decimal places.
/// ```example
/// #cnm.daxie(123456)\
/// #cnm.daxie(8642.99)\
/// #cnm.daxie(2356, u1: "圆", whole: "正")
/// ```
///
/// - v (int, float): The value to format.
/// - u1 (str): The unit for the whole number (e.g., "元").
/// - u2 (str): The unit for the first decimal place (e.g., "角").
/// - u3 (str): The unit for the second decimal place (e.g., "分").
/// - whole (str): The string to append if the value is a whole number (e.g., "整").
/// -> str
#let daxie(v, u1: "元", u2: "角", u3: "分", whole: "整") = {
  // this only works for Chinese
  // check if float. If so, check the last two digits
  let ret = numbering("壹", calc.floor(v)) + u1
  if type(v) == float {
    let last-two-digits = calc.round(calc.rem(v * 100, 100))
    let first-digit = calc.floor(last-two-digits / 10)
    let second-digit = calc.floor(calc.rem(last-two-digits, 10))
    if first-digit != 0 {
      ret += numbering("壹", first-digit) + u2
    }
    if second-digit != 0 {
      ret += numbering("壹", second-digit) + u3
    }
    if last-two-digits == 0 {
      ret += whole
    }
  } else {
    ret += whole
  }
  ret
}
