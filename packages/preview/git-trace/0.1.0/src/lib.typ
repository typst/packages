// Git metadata helpers for Typst.

#let _at(arr, i, default: none) = {
  if i < 0 or i >= arr.len() { default } else { arr.at(i) }
}

#let _div(a, b) = int(calc.floor(a / b))

#let _pad2(n) = {
  let s = str(n)
  if s.len() == 1 { "0" + s } else { s }
}

#let _clean-reflog-message(msg) = {
  if msg == none { none } else {
    let s = msg
    if s.starts-with("commit (") {
      let parts = s.split("): ")
      _at(parts, parts.len() - 1, default: s)
    } else if s.starts-with("commit: ") {
      s.replace("commit: ", "")
    } else if s.starts-with("commit ") {
      let parts = s.split(": ")
      _at(parts, parts.len() - 1, default: s)
    } else {
      s
    }
  }
}

#let _git-head(git_dir: ".git") = read(git_dir + "/HEAD").trim()

#let _git-reflog-last(git_dir: ".git") = {
  let lines = read(git_dir + "/logs/HEAD").split("\n")
  lines.filter(line => line.trim() != "").last(default: none)
}

#let git-head-ref(git_dir: ".git") = {
  let head = _git-head(git_dir: git_dir)
  if head.starts-with("ref: ") { head.replace("ref: ", "") } else { none }
}

#let git-branch(git_dir: ".git") = {
  let ref = git-head-ref(git_dir: git_dir)
  if ref == none { none } else { ref.split("/").last(default: none) }
}

#let git-head-hash(git_dir: ".git") = {
  let line = _git-reflog-last(git_dir: git_dir)
  if line == none { none } else {
    let left = _at(line.split("\t"), 0, default: "")
    let parts = left.split(" ")
    _at(parts, 1, default: none)
  }
}

#let git-last-commit(git_dir: ".git") = {
  let line = _git-reflog-last(git_dir: git_dir)
  if line == none { (branch: none, hash: none, message: none, date: none) } else {
    let branch = git-branch(git_dir: git_dir)
    let chunks = line.split("\t")
    let left = _at(chunks, 0, default: "")
    let message = _clean-reflog-message(_at(chunks, 1, default: none))
    let parts = left.split(" ")
    let hash = _at(parts, 1, default: none)
    let ts = _at(parts, parts.len() - 2, default: none)
    let tz = _at(parts, parts.len() - 1, default: none)
    let date = if ts == none or tz == none { none } else { ts + " " + tz }
    (branch: branch, hash: hash, message: message, date: date)
  }
}

#let git-format-date(date) = {
  if date == none { none } else {
    let parts = date.split(" ")
    let ts = _at(parts, 0, default: none)
    let tz = _at(parts, 1, default: "+0000")
    if ts == none { none } else {
      let tzchars = tz.clusters()
      let sign = _at(tzchars, 0, default: "+")
      let hh = (_at(tzchars, 1, default: "0") + _at(tzchars, 2, default: "0"))
      let mm = (_at(tzchars, 3, default: "0") + _at(tzchars, 4, default: "0"))
      let offset = (int(hh) * 3600 + int(mm) * 60) * (if sign == "-" { -1 } else { 1 })

      let seconds = int(ts) + offset
      let sec = int(calc.rem(seconds, 60))
      let minutes_total = _div(seconds, 60)
      let min = int(calc.rem(minutes_total, 60))
      let hours_total = _div(minutes_total, 60)
      let hour = int(calc.rem(hours_total, 24))
      let days = _div(hours_total, 24)

      // Convert days since 1970-01-01 to date using a 400-year cycle algorithm.
      let z = days + 719468
      let era = _div(z, 146097)
      let doe = z - era * 146097
      let yoe = _div(doe - _div(doe, 1460) + _div(doe, 36524) - _div(doe, 146096), 365)
      let y = yoe + era * 400
      let doy = doe - (365 * yoe + _div(yoe, 4) - _div(yoe, 100))
      let mp = _div(5 * doy + 2, 153)
      let d = doy - _div(153 * mp + 2, 5) + 1
      let m = mp + 3 - 12 * _div(mp, 10)
      let y = y + _div(mp, 10)

      _pad2(d) + "-" + _pad2(m) + "-" + str(y) + " " + _pad2(hour) + ":" + _pad2(min)
    }
  }
}
