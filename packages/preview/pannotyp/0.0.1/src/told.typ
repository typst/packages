#import "util.typ"

#let ragok = (
  "a": (
    // 0   1    2    3    4    5    6    7    8    9
    ("a", "e", "a", "a", "e", "e", "a", "e", "a", "e"),
    // X   11   12   13   14   15   16   17   18   19
    ("x", "e", "e", "a", "e", "e", "a", "e", "a", "e"),
    // X   10   20   30   40   50   60   70   80   90
    ("x", "e", "a", "a", "e", "e", "a", "e", "a", "e"),
    // ...... 10e2 10e3 10e4 10e5 10e6 10e7 10e8 10e9
    ("x", "x", "a", "e", "e", "e", "a", "a", "a", "a"),
  ),
  "ad": (
    // 0     1     2     3     4     5     6     7     8     9
    ("ad", "ed", "od", "ad", "ed", "öd", "od", "ed", "ad", "ed"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "ed", "ed", "ad", "ed", "öd", "od", "ed", "ad", "ed"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "ed", "ad", "ad", "ed", "ed", "ad", "ed", "ad", "ed"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "ad", "ed", "ed", "ed", "od", "od", "od", "ad"),
  ),
  "an": (
    // 0     1     2     3     4     5     6     7     8     9
    ("án", "en", "en", "an", "en", "en", "an", "en", "an", "en"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "en", "en", "an", "en", "en", "an", "en", "an", "en"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "en", "an", "an", "en", "en", "an", "en", "an", "en"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "an", "en", "en", "en", "n", "n", "n", "an"),
  ),
  "as": (
    // 0     1     2     3     4     5     6     7     8     9
    ("ás", "es", "es", "as", "es", "ös", "os", "es", "as", "es"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "es", "es", "as", "es", "ös", "os", "es", "as", "es"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "es", "as", "as", "es", "es", "as", "es", "as", "es"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "as", "es", "es", "es", "s", "s", "s", "os"),
  ),
  "at": (
    // 0     1     2     3     4     5     6     7     8     9
    ("át", "et", "őt", "at", "et", "öt", "ot", "et", "at", "et"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "et", "őt", "at", "et", "öt", "ot", "et", "at", "et"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "et", "at", "at", "et", "et", "at", "et", "at", "et"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "at", "et", "et", "et", "t", "t", "t", "at"),
  ),
  "ba": (
    // 0     1     2     3     4     5     6     7     8     9
    ("ba", "be", "be", "ba", "be", "be", "ba", "be", "ba", "be"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "be", "be", "ba", "be", "be", "ba", "be", "ba", "be"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "be", "ba", "ba", "be", "be", "ba", "be", "ba", "be"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "ba", "be", "be", "be", "ba", "ba", "ba", "ba"),
  ),
  "bol": (
    // 0      1      2      3      4      5      6      7      8      9
    ("ból", "ből", "ből", "ból", "ből", "ből", "ból", "ből", "ból", "ből"),
    // X     11     12     13     14     15     16     17     18     19
    ("xxx", "ből", "ből", "ból", "ből", "ből", "ból", "ből", "ból", "ből"),
    // X     10     20     30     40     50     60     70     80     90
    ("xxx", "ből", "ból", "ból", "ből", "ből", "ból", "ből", "ból", "ből"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "ból", "ből", "ből", "ből", "ból", "ból", "ból", "ból"),
  ),
  "hoz": (
    // 0      1      2      3      4      5      6      7      8      9
    ("hoz", "hez", "höz", "hoz", "hez", "höz", "hoz", "hez", "hoz", "hez"),
    // X     11     12     13     14     15     16     17     18     19
    ("xxx", "hez", "höz", "hoz", "hez", "höz", "hoz", "hez", "hoz", "hez"),
    // X     10     20     30     40     50     60     70     80     90
    ("xxx", "hez", "hoz", "hoz", "hez", "hez", "hoz", "hez", "hoz", "hez"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "hoz", "hez", "hez", "hez", "hoz", "hoz", "hoz", "hoz"),
  ),
  "nal": (
    // 0      1      2      3      4      5      6      7      8      9
    ("nál", "nél", "nél", "nál", "nél", "nél", "nál", "nél", "nál", "nél"),
    // X     11     12     13     14     15     16     17     18     19
    ("xxx", "nél", "nél", "nál", "nél", "nél", "nál", "nél", "nál", "nél"),
    // X     10     20     30     40     50     60     70     80     90
    ("xxx", "nél", "nál", "nál", "nél", "nél", "nál", "nél", "nál", "nél"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "nál", "nél", "nél", "nél", "nál", "nál", "nál", "nál"),
  ),
  "nak": (
    // 0      1      2      3      4      5      6      7      8      9
    ("nak", "nek", "nek", "nak", "nek", "nek", "nak", "nek", "nak", "nek"),
    // X     11     12     13     14     15     16     17     18     19
    ("xxx", "nek", "nek", "nak", "nek", "nek", "nak", "nek", "nak", "nek"),
    // X     10     20     30     40     50     60     70     80     90
    ("xxx", "nek", "nak", "nak", "nek", "nek", "nak", "nek", "nak", "nek"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "nak", "nek", "nek", "nek", "nak", "nak", "nak", "nak"),
  ),
  "ra": (
    // 0     1     2     3     4     5     6     7     8     9
    ("ra", "re", "re", "ra", "re", "re", "ra", "re", "ra", "re"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "re", "re", "ra", "re", "re", "ra", "re", "ra", "re"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "re", "ra", "ra", "re", "re", "ra", "re", "ra", "re"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "ra", "re", "re", "re", "ra", "ra", "ra", "ra"),
  ),
  "rol": (
    // 0      1      2      3      4      5      6      7      8      9
    ("ról", "ről", "ről", "ról", "ről", "ről", "rol", "ről", "ról", "ről"),
    // X     11     12     13     14     15     16     17     18     19
    ("xxx", "ről", "ről", "ról", "ről", "ről", "rol", "ről", "ról", "ről"),
    // X     10     20     30     40     50     60     70     80     90
    ("xxx", "ről", "ról", "ról", "ről", "ről", "ról", "ről", "ról", "ről"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "ról", "ről", "ről", "ről", "ról", "ról", "ról", "ról"),
  ),
  "szor": (
    // 0        1       2       3       4       5       6       7       8       9
    // @typstyle off
    ("szor", "szer", "ször", "szor", "szer", "ször", "szor", "szer", "szor", "szer"),
    // X       11      12      13      14      15      16      17      18      19
    // @typstyle off
    ("xxxx", "szer", "ször", "szor", "szer", "ször", "szor", "szer", "szor", "szer"),
    // X      10       20      30      40      50      60      70      80      90
    // @typstyle off
    ("xxxx", "szer", "szor", "szor", "szer", "szer", "szor", "szer", "szor", "szer"),
    // 10e0   10e1    10e2    10e3    10e4    10e5    10e6    10e7    10e8    10e9
    // @typstyle off
    ("xxxx", "xxxx", "szor", "szer", "szer", "szer", "szor", "szor", "szor", "szor"),
  ),
  "tol": (
    // 0      1      2      3      4      5      6      7      8      9
    ("tól", "től", "től", "tól", "től", "től", "tol", "től", "tól", "től"),
    // X     11     12     13     14     15     16     17     18     19
    ("xxx", "től", "től", "tól", "től", "től", "tol", "től", "tól", "től"),
    // X     10     20     30     40     50     60     70     80     90
    ("xxx", "től", "tól", "tól", "től", "től", "tól", "től", "tól", "től"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "tól", "től", "től", "től", "tól", "tól", "tól", "tól"),
  ),
  "ul": (
    // 0     1     2     3     4     5     6     7     8     9
    ("ul", "ül", "ül", "ul", "ül", "ül", "ul", "ül", "ul", "ül"),
    // X    11    12    13    14    15    16    17    18    19
    ("xx", "ül", "ül", "ul", "ül", "ül", "ul", "ül", "ul", "ül"),
    // X    10    20    30    40    50    60    70    80    90
    ("xx", "ül", "ul", "ul", "ül", "ül", "ul", "ül", "ul", "ül"),
    // 10e0 10e1 10e2  10e3  10e4  10e5  10e6  10e7  10e8  10e9
    ("xx", "xx", "ul", "ül", "ül", "ül", "ul", "ul", "ul", "ul"),
  ),
  "val": (
    // 0       1      2      3       4      5      6      7      8      9
    ("val", "gyel", "vel", "mal", "gyel", "tel", "tal", "tel", "cal", "cel"),
    // X      11     12     13      14     15     16     17     18     19
    ("xxx", "gyel", "vel", "mal", "gyel", "tel", "tal", "tel", "cal", "cel"),
    // X      10     20     30      40     50     60     70     80     90
    ("xxx", "zel", "szal", "cal", "nel", "nel", "nal", "nel", "nal", "nel"),
    // 10e0  10e1   10e2   10e3   10e4   10e5   10e6   10e7   10e8   10e9
    ("xxx", "xxx", "zal", "rel", "rel", "rel", "val", "val", "val", "dal"),
  ),
)

// Count trailing zeros
#let ctz(i) = {
  if i == 0 {
    return 0
  }
  let ret = 0
  while calc.rem(i, 10) == 0 {
    ret += 1
    i /= 10
  }
  return ret
}

#let told_get(i, r) = {
  let z = ctz(i)
  // trailing zeros
  if z == 1 {
    r.at(2).at(int(i / 10))
  } else if z > 1 {
    r.at(3).at(z, default: "a")
  } else {
    // no trailing zeros
    if i < 10 {
      return r.at(0).at(i)
    }
    while i > 10 {
      i = calc.rem(i, 10)
    }
    r.at(1).at(i)
  }
}

#let told_handler(i, rag) = {
  if rag == "a" or rag == "e" {
    told_get(i, ragok.a)
  } else if rag == "ad" or rag == "ed" or rag == "öd" {
    told_get(i, ragok.ad)
  } else if rag == "adik" or rag == "edik" or rag == "ödik" {
    told_get(i, ragok.ad)
    "ik"
  } else if rag == "an" or rag == "en" {
    told_get(i, ragok.an)
  } else if rag == "as" or rag == "es" or rag == "ös" {
    told_get(i, ragok.as)
  } else if rag == "at" or rag == "et" or rag == "ot" {
    told_get(i, ragok.at)
  } else if rag == "ba" or rag == "be" {
    told_get(i, ragok.ba)
  } else if rag == "ban" or rag == "ben" {
    told_get(i, ragok.ba)
    "n"
  } else if rag == "ból" or rag == "ből" {
    told_get(i, ragok.bol)
  } else if rag == "hoz" or rag == "hez" or rag == "höz" {
    told_get(i, ragok.hoz)
  } else if rag == "nak" or rag == "nek" {
    told_get(i, ragok.nak)
  } else if rag == "nál" or rag == "nél" {
    told_get(i, ragok.nal)
  } else if rag == "ra" or rag == "re" {
    told_get(i, ragok.ra)
  } else if rag == "ról" or rag == "ről" {
    told_get(i, ragok.rol)
  } else if rag == "szor" or rag == "szer" or rag == "ször" {
    told_get(i, ragok.szor)
  } else if rag == "tól" or rag == "től" {
    told_get(i, ragok.tol)
  } else if rag == "ul" or rag == "ül" {
    told_get(i, ragok.ul)
  } else if rag == "val" or rag == "vel" {
    told_get(i, ragok.val)
  } else {
    panic("told: ismeretlen rag", rag)
  }
}

#let told(target, rag, rag2: none, form: "normal", supplement: auto) = {
  context {
    let ld = util.getLabelData(target, form: form)
    let i = ld.counter.last()

    if i != none and i > 1000000000 {
      panic("told: counter is too big")
    }

    // generate t1 and t2
    let t1 = told_handler(i, rag)
    let t2 = ""
    if rag2 != none {
      t2 = told_handler(i, rag2)
    }

    // supplement
    let supp = supplement
    if supplement == auto {
      supp = ld.supplement
      if form == "page" {
        supp = page.supplement
      }
    }

    return (
      link(
        target,
        box(numbering(ld.numbering, ..ld.counter) + "-" + t1 + t2) + " " + supp,
      )
    )
  }
}
