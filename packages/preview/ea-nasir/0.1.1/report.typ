#import "date.typ": _to-date, same-day-or-later

#let _report-account = (account, from: none, to: none) => {
  if (from != none) {
    let (_from, error) = _to-date(from)
    if (error != none) {
      return (none, "from: " + error)
    }
    from = _from
  }

  if (to != none) {
    let (_to, error) = _to-date(to)
    if (error != none) {
      return (none, "to: " + error)
    }
    to = _to
  }

  let plus = 0
  let minus = 0

  if (
    (from == none or same-day-or-later(from, account.opening_date))
      and (to == none or same-day-or-later(account.opening_date, to))
  ) {
    if (account.start_amount > 0) {
      plus += account.start_amount
    } else {
      minus += account.start_amount
    }
  }

  for entry in account.log {
    if (from != none and not same-day-or-later(from, entry.date)) { continue }

    if (to != none and not same-day-or-later(entry.date, to)) { continue }

    if (entry.amount > 0) { plus += entry.amount } else {
      minus += entry.amount
    }
  }

  return (
    (
      name: account.name,
      currency: account.currency,
      from: from,
      to: to,
      total: plus + minus,
      plus: plus,
      minus: minus,
    ),
    none,
  )
}

/**
 * Create a report for an account over an optional timeframe.
 * Arguments are:
 * - account: the account to create the report for.
 * - from: none|datetime|str
 * - to: none|datetime|str
 */
#let report-account = (account, from: none, to: none) => {
  let (report, error) = _report-account(account, from: from, to: to)
  assert.eq(error, none, message: "" + error)
  return report
}

#let _name-prefixes = name => {
  let parts = name.split(":")

  if (parts.len() <= 1) { return () }

  let prefixes = ()
  for i in range(1, parts.len()) {
    prefixes.push(parts.slice(0, i).join(":"))
  }

  return prefixes
}

#let _prefixes = accounts => {
  let prefixes = (:)

  for account in accounts {
    for prefix in _name-prefixes(account.name) {
      prefixes.insert(prefix, 1)
    }
  }

  return prefixes.keys().sorted()
}

#let _report-ledger = (ledger, from: none, to: none) => {
  let account-reports = (:)
  for account in ledger.accounts.values() {
    let (report, error) = _report-account(account, from: from, to: to)

    if (error != none) {
      return (none, error)
    }

    account-reports.insert(account.name, report)
  }

  let prefix-reports = (:)
  for prefix in _prefixes(ledger.accounts.values()) {
    let default-sum = (total: 0, plus: 0, minus: 0)
    let currency-sums = (:)

    for (account-name, report) in account-reports {
      if (not account-name.starts-with(prefix)) {
        continue
      }

      let existing = currency-sums.at(report.currency, default: default-sum)
      let next = (
        total: report.total + existing.total,
        plus: report.plus + existing.plus,
        minus: report.minus + existing.minus,
      )

      let next-dict = (:)
      next-dict.insert(report.currency, next)
      currency-sums = (:..currency-sums, ..next-dict)
    }

    prefix-reports.insert(prefix, currency-sums)
  }

  return (
    (
      accounts: account-reports,
      prefixes: prefix-reports,
      all: (:..prefix-reports, ..account-reports),
      from: from,
      to: to,
    ),
    none,
  )
}

/**
 * Create a report for a ledger over an optional timeframe.
 * Arguments are:
 * - ledger: the ledger to create the report for.
 * - from: none|datetime|str
 * - to: none|datetime|str
 */
#let report-ledger = (ledger, from: none, to: none) => {
  let (report, error) = _report-ledger(ledger, from: from, to: to)
  assert.eq(error, none, message: "" + error)
  return report
}
