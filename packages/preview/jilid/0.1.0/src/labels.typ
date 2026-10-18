// `lang` picks the default words.
// `labels` replaces single words.
#let strings = (
  course: (id: "Mata Kuliah :", en: "Course :"),
  lecturer: (id: "Dosen Pengampu :", en: "Lecturer :"),
  students: (id: [Disusun oleh :], en: "Prepared by :"),
  student-id: (id: "NIM", en: "NIM"),
  lecturer-id: (id: "NIP", en: "NIP"),
  program: (id: "PROGRAM STUDI", en: "STUDY PROGRAM OF"),
  faculty: (id: "FAKULTAS", en: "FACULTY OF"),
  department: (id: "JURUSAN", en: "DEPARTMENT OF"),
  toc: (id: [DAFTAR ISI], en: [TABLE OF CONTENTS]),
  lof: (id: [DAFTAR GAMBAR], en: [LIST OF FIGURES]),
  lot: (id: [DAFTAR TABEL], en: [LIST OF TABLES]),
  loc: (id: [DAFTAR KODE], en: [LIST OF CODES]),
  appendix-list: (id: [DAFTAR LAMPIRAN], en: [LIST OF APPENDICES]),
  bibliography: (id: [DAFTAR PUSTAKA], en: [BIBLIOGRAPHY]),
  appendices: (id: [LAMPIRAN-LAMPIRAN], en: [APPENDICES]),
  appendix: (id: "Lampiran", en: "Appendix"),
  appendix-short: (id: "L", en: "A"),
  chapter: (id: "BAB", en: "CHAPTER"),
  figure: (id: "Gambar", en: "Figure"),
  table: (id: "Tabel", en: "Table"),
  code: (id: "Kode", en: "Code"),
  equation: (id: "Persamaan", en: "Equation"),
  section: (id: "Bagian", en: "Section"),
  page: (id: "halaman", en: "page"),
)

// pick every word for `lang`.
// then put the user's words over them.
#let resolve(overrides, lang) = {
  let out = (:)
  let missing = ()
  for (key, entry) in strings {
    if lang in entry { out.insert(key, entry.at(lang)) } else {
      missing.push(key)
    }
  }
  for (key, value) in overrides {
    assert(
      key in strings,
      message: "jilid: unknown `labels` key `"
        + key
        + "`. Valid keys: "
        + strings.keys().map(k => "`" + k + "`").join(", ")
        + ".",
    )
    assert(
      type(value) != dictionary,
      message: "jilid: `labels."
        + key
        + "` takes the text itself, e.g. `labels: ("
        + key
        + ": [..])`, not a dictionary of languages.",
    )
    out.insert(key, value)
  }
  missing = missing.filter(key => key not in overrides)
  assert(
    missing.len() == 0,
    message: "jilid: language `"
      + lang
      + "` is not built in (built in: `id`, `en`). Provide it through `labels` for: "
      + missing.map(k => "`" + k + "`").join(", ")
      + ".",
  )
  out
}
