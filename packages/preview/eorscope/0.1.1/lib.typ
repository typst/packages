// Statutory employer cost of an employee by country, from the EOR Scope
// dataset (https://eorscope.com/data/, CC BY 4.0). Code: MIT.
// Cost comparison, not legal or tax advice. EOR provider fees are not included.

#let _data = json("data/employer-costs.json")
#let _countries = _data.countries

/// Attribution line required by the CC BY 4.0 licence of the data.
#let attribution = "Source: EOR Scope, https://eorscope.com/data/ (CC BY 4.0). Cost comparison, not legal or tax advice."

/// Country record by ISO 3166-1 alpha-2 code (case-insensitive): name, region,
/// currency, published employer cost at the example salary, review dates and
/// the contribution lines with their official source.
#let country(iso) = {
  let key = upper(str(iso))
  assert(key in _countries, message: "eorscope: unknown country code " + repr(iso))
  _countries.at(key)
}

/// Every country, sorted by ISO code, optionally filtered by region.
#let countries(region: none) = {
  _countries.values().filter(c => region == none or c.region == region)
}

/// Sorted list of the regions in the dataset.
#let regions() = _countries.values().map(c => c.region).dedup().sorted()

/// True when the country publishes an "at least" figure (a declared floor),
/// not a total: its rate must be read and printed as "at least".
#let rate-is-floor(iso) = country(iso).total_declared_floor

// The word eorscope.com prints before the cost at a gross annual salary in local
// currency: "at least " for a declared floor, or above the threshold of a
// salary-dependent floor (ES: solidarity contribution above the maximum base,
// not modelled); "at most " below the threshold of a salary-dependent ceiling
// (FR: RGDU relief under 3 x SMIC, not modelled); "" otherwise and at the
// threshold itself.
#let _bound-word(c, gross-local) = {
  let t = c.at("total_bound_salary_threshold_local", default: none)
  let rule = c.at("total_bound_salary_rule", default: none)
  if c.total_declared_floor or (rule == "at_least_above" and gross-local > t) { "at least " } else if (
    rule == "at_most_below" and gross-local < t
  ) { "at most " } else { "" }
}

// Fixed-point string of v, rounded half away from zero on the shortest decimal
// that round-trips to v (as eorscope.com prints it): 32.15 gives "32.2".
#let _fixed(v, digits) = {
  let neg = v < 0
  let short = str(calc.abs(float(v)))
  let parts = short.split(".")
  let whole = parts.at(0)
  let frac = if parts.len() > 1 { parts.at(1) } else { "" }
  while frac.len() < digits + 1 { frac += "0" }
  let ds = (whole + frac.slice(0, digits)).clusters().map(int)
  if int(frac.at(digits)) >= 5 {
    let i = ds.len()
    let carry = true
    while carry {
      if i == 0 {
        ds.insert(0, 1)
        carry = false
      } else {
        i -= 1
        if ds.at(i) == 9 { ds.at(i) = 0 } else {
          ds.at(i) += 1
          carry = false
        }
      }
    }
  }
  let split = ds.len() - digits
  let s = ds.slice(0, split).map(str).join()
  if digits > 0 { s += "." + ds.slice(split).map(str).join() }
  if neg and s.clusters().any(c => c != "0" and c != ".") { s = "-" + s }
  s
}

// "1234567.89" -> "1,234,567.89"
#let _group(s) = {
  let neg = s.starts-with("-")
  let rest = if neg { s.slice(1) } else { s }
  let parts = rest.split(".")
  let whole = parts.at(0)
  let g = ""
  for (i, ch) in whole.clusters().enumerate() {
    if i > 0 and calc.rem(whole.len() - i, 3) == 0 { g += "," }
    g += ch
  }
  (if neg { "-" } else { "" }) + g + (if parts.len() > 1 { "." + parts.at(1) } else { "" })
}

/// Percent string of a rate (0.2225 -> "22.3" at 1 digit), as eorscope.com prints it.
#let format-percent(rate, digits: 1) = _fixed(calc.round(rate * 1e8) / 1e6, digits)

/// Amount with thousands separators: 1390.625 -> "1,390.63".
#let format-amount(v, digits: 2) = _group(_fixed(calc.round(v * 1e6) / 1e6, digits))

#let _or(v, default) = if v == none { default } else { v }

// Same operations, in the same order, as the cost engine of eorscope.com (and
// the eorscope CLI and Go module): contributions priced in local currency and
// converted at fx_local_per_usd; statutory extras priced on the gross in USD.
#let _compute(c, gross-local, gross-usd) = {
  let fx = c.fx_local_per_usd
  let share = c.assumptions.at("basic_share_of_gross", default: 1.0)
  let basic-share = calc.min(calc.max(share, 0.0), 1.0)
  let citizen-or-pr = if c.assumptions.at("employee_is_citizen_or_pr", default: 1.0) >= 1.0 { 1.0 } else { 0.0 }
  let lines = ()
  let cost-local = 0.0
  let cost-usd = 0.0
  for l in c.lines.filter(l => l.type == "contribution") {
    let gated = (l.max_gross != none and gross-local > l.max_gross) or (l.min_gross != none and gross-local < l.min_gross)
    let switched-off = l.id == "employer_cpf" and citizen-or-pr < 1.0
    if gated or switched-off {
      lines.push((
        id: l.id, name: l.name, kind: "contribution", amount: 0.0, skipped: true, capped: false,
        note: if switched-off { "Not applicable: employee is not a citizen or permanent resident" } else if l.applies == "" { "Not applicable at this salary" } else { l.applies },
        source-url: l.source_url, source-checked-at: l.source_checked_at,
      ))
      continue
    }
    let rate = _or(l.rate, 0.0)
    let factor = _or(l.base_factor, 1.0)
    let base = if l.base == "flat" { _or(l.flat, 0.0) } else if l.base == "basic" { gross-local * basic-share * factor } else { gross-local * factor }
    let annual = if l.base == "flat" { base } else if l.base == "band" {
      let top = if l.cap == none { base } else { calc.min(base, l.cap) }
      calc.max(top - _or(l.floor, 0.0), 0.0) * rate
    } else {
      let x = base
      if l.floor != none and x < l.floor { x = l.floor }
      if l.cap != none and x > l.cap { x = l.cap }
      x * rate
    }
    cost-local += annual
    cost-usd += annual / fx
    lines.push((
      id: l.id, name: l.name, kind: "contribution", amount: annual, skipped: false,
      capped: l.base != "flat" and l.cap != none and base > l.cap, note: l.applies,
      source-url: l.source_url, source-checked-at: l.source_checked_at,
    ))
  }
  for e in c.lines.filter(l => l.type == "statutory_extra" and l.in_total) {
    let v = _or(e.extra_value, 0.0)
    let amount(gross) = if e.extra_kind == "percent" {
      gross * (if e.base == "basic" { basic-share } else { 1.0 }) * (v / 100.0)
    } else if e.extra_kind == "months" { (gross / 12.0) * v } else if e.extra_kind == "days" { (gross / 260.0) * v } else { 0.0 }
    cost-local += amount(gross-local)
    cost-usd += amount(gross-usd)
    lines.push((
      id: e.id, name: e.name, kind: "statutory_extra", amount: amount(gross-local), skipped: false,
      capped: false, note: e.applies, source-url: e.source_url, source-checked-at: e.source_checked_at,
    ))
  }
  (
    iso: c.iso,
    country: c.country,
    currency: c.currency,
    salary: gross-local,
    cost: cost-local,
    total: gross-local + cost-local,
    cost-usd: cost-usd,
    rate: if gross-usd > 0 { cost-usd / gross-usd } else { 0.0 },
    rate-is-floor: _bound-word(c, gross-local) == "at least ",
    rate-is-ceiling: _bound-word(c, gross-local) == "at most ",
    base-is-ceiling: c.total_declared_ceiling,
    lines: lines,
  )
}

/// Statutory employer cost on top of a gross annual salary in local currency.
/// Returns a dictionary: `salary`, `cost` (employer contributions plus the
/// statutory extras counted in the total, per year, local currency), `total`
/// (salary + cost), `rate` (cost / salary, 0.2225 = 22.25 %), `rate-is-floor`
/// (read `cost` and `rate` as "at least": a declared floor, or ES above its
/// maximum base), `rate-is-ceiling` (read them as "at most": FR under 3 x SMIC),
/// `base-is-ceiling` and `lines`.
#let employer-cost(iso, salary) = {
  let c = country(iso)
  let gross = float(salary)
  assert(gross >= 0, message: "eorscope: salary must be zero or positive")
  _compute(c, gross, gross / c.fx_local_per_usd)
}

/// Employer cost over gross salary (0.2225 = 22.25 %). Without `salary`, the
/// rate published on eorscope.com at the country's example salary; with a
/// gross annual salary in local currency, the rate computed at that salary.
#let employer-rate(iso, salary: none) = {
  if salary == none { country(iso).employer_cost_pct / 100 } else { employer-cost(iso, salary).rate }
}

/// Rate as text, with "at least" for countries that publish a floor and "at
/// most" or "at least" where the salary falls in a salary-dependent bound:
/// "22.3%" for DE, "at least 3.8%" for IN, "30%" for AT. Without `salary`, the
/// bound is read at the example salary.
#let employer-rate-text(iso, salary: none, digits: 1) = {
  let c = country(iso)
  let p = if salary == none and digits == 1 { c.employer_cost_pct_printed } else {
    format-percent(employer-rate(iso, salary: salary), digits: digits)
  }
  // Trailing zeros dropped, as on eorscope.com: 30.0 prints "30".
  if p.contains(".") { p = p.trim("0", at: end).trim(".", at: end) }
  let gross = if salary == none { c.example_salary_usd * c.fx_local_per_usd } else { float(salary) }
  _bound-word(c, gross) + p + "%"
}

/// Ledger of the employer cost at a gross annual salary in local currency:
/// one row per contribution and statutory extra, then the total.
#let employer-cost-table(iso, salary, digits: 2) = {
  let r = employer-cost(iso, salary)
  let floor = if r.rate-is-floor { "at least " } else if r.rate-is-ceiling { "at most " } else { "" }
  let rows = r.lines.map(l => (
    l.name,
    if l.skipped { emph(l.note) } else if l.capped { [#format-amount(l.amount, digits: digits) (capped)] } else { format-amount(l.amount, digits: digits) },
  )).flatten()
  figure(
    table(
      columns: (1fr, auto),
      align: (left, right),
      table.header([*Employer cost line*], [*Per year (#r.currency)*]),
      ..rows,
      table.hline(),
      [*Employer cost (#floor#format-percent(r.rate)% of gross)*], [*#floor#format-amount(r.cost, digits: digits)*],
      [Gross salary + employer cost], [#floor#format-amount(r.total, digits: digits)],
    ),
    caption: [Statutory employer cost, #r.country, gross #format-amount(r.salary, digits: digits) #r.currency per year. #attribution],
  )
}

/// Published employer cost by country, at each country's example salary,
/// with "at least" for declared floors and the salary-dependent bound at the
/// example salary ("at most" for FR).
#let employer-rates-table(isos: none, region: none) = {
  let list = if isos == none { countries(region: region) } else { isos.map(country) }
  table(
    columns: (1fr, auto, auto, auto),
    align: (left, right, right, right),
    table.header([*Country*], [*Employer cost*], [*Example salary (USD/yr)*], [*Reviewed*]),
    ..list.map(c => (
      c.country,
      employer-rate-text(c.iso),
      format-amount(c.example_salary_usd, digits: 0),
      c.last_reviewed,
    )).flatten(),
    table.cell(colspan: 4, text(size: 0.8em, attribution)),
  )
}
