#import "date.typ": _toDate, sameDayOrLater

#let _reportAccount = (account, from: none, to: none) => {
  if (from != none) {
    let (_from, error) = _toDate(from)
    if (error != none) {
      return (none, "from: " + error)
    }
    from = _from
  }

  if (to != none) {
    let (_to, error) = _toDate(to)
    if (error != none) {
      return (none, "to: " + error)
    }
    to = _to
  }

  let plus = 0
  let minus = 0

  if (
    (from == none or sameDayOrLater(from, account.opening_date))
      and (to == none or sameDayOrLater(account.opening_date, to))
  ) {
    if (account.start_amount > 0) {
      plus += account.start_amount
    } else {
      minus += account.start_amount
    }
  }

  for entry in account.log {
    if (from != none and not sameDayOrLater(from, entry.date)) { continue }

    if (to != none and not sameDayOrLater(entry.date, to)) { continue }

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
#let reportAccount = (account, from: none, to: none) => {
  let (report, error) = _reportAccount(account, from: from, to: to)
  assert.eq(error, none, message: "" + error)
  return report
}

#let _namePrefixes = name => {
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
    for prefix in _namePrefixes(account.name) {
      prefixes.insert(prefix, 1)
    }
  }

  return prefixes.keys().sorted()
}

#let _reportLedger = (ledger, from: none, to: none) => {
  let accountReports = (:)
  for account in ledger.accounts.values() {
    let (report, error) = _reportAccount(account, from: from, to: to)

    if (error != none) {
      return (none, error)
    }

    accountReports.insert(account.name, report)
  }

  let prefixReports = (:)
  for prefix in _prefixes(ledger.accounts.values()) {
    let defaultSum = (total: 0, plus: 0, minus: 0)
    let currencySums = (:)

    for (accountName, report) in accountReports {
      if (not accountName.starts-with(prefix)) {
        continue
      }

      let existing = currencySums.at(report.currency, default: defaultSum)
      let next = (
        total: report.total + existing.total,
        plus: report.plus + existing.plus,
        minus: report.minus + existing.minus,
      )

      let nextDict = (:)
      nextDict.insert(report.currency, next)
      currencySums = (:..currencySums, ..nextDict)
    }

    prefixReports.insert(prefix, currencySums)
  }

  return (
    (
      accounts: accountReports,
      prefixes: prefixReports,
      all: (:..prefixReports, ..accountReports),
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
#let reportLedger = (ledger, from: none, to: none) => {
  let (report, error) = _reportLedger(ledger, from: from, to: to)
  assert.eq(error, none, message: "" + error)
  return report
}
