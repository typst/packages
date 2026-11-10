#import "date.typ": _toDate

#let _mkDelta = (account, amount, currency) => {
  if (type(account) != str or account.len() == 0) {
    return (none, "account must be a non-empty string.")
  }

  if (type(amount) == float) {
    return (none, "amount may not be a float.")
  }
  if (type(amount) != decimal and type(amount) != str and type(amount) != int) {
    return (none, "amount must be a decimal, int or str.")
  }

  if (type(currency) != str or currency.len() == 0) {
    return (none, "currency must be a non-empty string.")
  }

  return ((account: account, amount: decimal(amount), currency: currency), none)
}

/**
 * Create a delta that can later become part of a transaction.
 * A delta is composed of:
 * - account: the name of the account. A non-empty string.
 * - amount: decimal|str|int
 * - currency: A non-empty string matching the currency of the account.
 */
#let mkDelta = (account, amount, currency) => {
  let (delta, error) = _mkDelta(account, amount, currency)
  assert.ne(delta, none, message: "" + error)
  return delta
}

#let _validateDelta = delta => {
  if (type(delta) != dictionary) {
    return (none, "delta must be a dictionary.")
  }

  let (account: account, amount: amount, currency: currency) = delta

  if (type(account) != str or account.len() == 0) {
    return (none, "account must be a non-empty string.")
  }
  if (type(amount) != decimal) {
    return (none, "amount must be of type decimal.")
  }
  if (type(currency) != str or currency.len() == 0) {
    return (none, "currency must be a non-empty string.")
  }

  return (delta, none)
}

/**
 * Verifies that a given delta is valid.
 * A valid delta is returned, an invalid one causes an assertion failure.
 */
#let validateDelta = delta => {
  let (delta, error) = _validateDelta(delta)
  assert.ne(delta, none, message: "" + error)
  return delta
}

#let _validateDeltaSums = deltas => {
  // we expect the per-currency sums to all be 0.
  let currency_sums = (:)

  if (deltas.len() == 0) { return "deltas must be a non-empty list." }

  for delta in deltas {
    let (amount: amount, currency: currency) = delta
    currency_sums.insert(currency, amount + currency_sums.at(currency, default: decimal(0)))
  }

  for (currency, amount) in currency_sums.pairs() {
    if (amount != 0) {
      return "amount should be 0 for currency '" + currency + "', but is " + str(amount) + "."
    }
  }

  return none
}

#let _uniqueDeltaAccounts = deltas => {
  let accounts = (:)

  for delta in deltas {
    if delta.account in accounts {
      return "Account name '" + delta.account + "' is present in more than one delta."
    }

    accounts.insert(delta.account, none)
  }

  return none
}

#let _mkTransaction = (date, name, narration, deltas, description) => {
  let (date, error) = _toDate(date)
  if (date == none) { return (none, "mkTransaction: " + error) }

  if (type(name) != str or name.len() == 0) {
    return (none, "name must be a non-empty string.")
  }

  if (type(narration) != str) {
    // narration is allowed to be empty.
    return (none, "narration must be of type str.")
  }

  if (type(deltas) != array or deltas.len() == 0) {
    return (none, "deltas must be a non-empty array.")
  }
  for delta in deltas {
    let (delta, error) = _validateDelta(delta)
    if (error != none) {
      return (none, "invalid delta in mkTransaction: " + error)
    }
  }

  let error = _validateDeltaSums(deltas)
  if (error != none) {
    return (none, error)
  }

  let error = _uniqueDeltaAccounts(deltas)
  if (error != none) {
    return (none, error)
  }

  if (description != none and type(description) != str and type(description) != content) {
    return (none, "description must be none, str or content.")
  }

  return (
    (
      date: date,
      name: name,
      narration: narration,
      description: description,
      deltas: deltas,
    ),
    none,
  )
}

/**
 * Creates a new transaction given the following parameters:
 * - date: datetime|str of the transaction
 * - name: non-empty string
 * - narration: string
 * - deltas: longer than 1 array of deltas
 * - description: none|str|content
 */
#let mkTransaction = (date, name, narration, deltas, description) => {
  let (transaction, error) = _mkTransaction(date, name, narration, deltas, description)
  assert.ne(transaction, none, message: "" + error)
  return transaction
}
