#import "date.typ": _toDate, sameDayOrLater

#let _mkAccount = (name, opening_date, currency, start_amount, description, monotone) => {
  if (type(name) != str or name.len() == 0) {
    return (none, "name must be a non-empty string.")
  }

  let (opening_date, error) = _toDate(opening_date)
  if (opening_date == none) {
    return (none, "opening_date: " + error)
  }

  if (type(currency) != str or currency.len() == 0) {
    return (none, "currency must be a non-empty string.")
  }

  if (start_amount != none and type(start_amount) != int and type(start_amount) != decimal) {
    return (none, "start_amount must be of type none, int or decimal.")
  }
  if start_amount == none {
    start_amount = decimal(0)
  } else {
    start_amount = decimal(start_amount)
  }

  if (description != none and type(description) != str and type(description) != content) {
    return (none, "description must be of type none, str, content.")
  }

  if (monotone != none and monotone != "positive" and monotone != "negative") {
    return (none, "monotone must be one of {none, 'positive', 'negative'}")
  }

  return (
    (
      name: name,
      opening_date: opening_date,
      currency: currency,
      start_amount: start_amount,
      description: description,
      monotone: monotone,
      log: (), // array(dictionary(date, amount, name, narration))
    ),
    none,
  )
}

/**
 * mkAccount creates an account given the following parameters:
 * - name
 * - opening_date
 * - currency
 * - start_amount
 * - description: none|str|content
 * - monotone: none|"positive"|"negative"
 */
#let mkAccount = (name, opening_date, currency, start_amount, description, monotone) => {
  let (account, error) = _mkAccount(name, opening_date, currency, start_amount, description, monotone)
  assert.ne(account, none, message: "" + error)
  return account
}

#let _log = (account, date, amount, name, narration) => {
  if (amount == 0) {
    return (none, "amount must be != 0 to log.")
  }

  if (account.monotone == "positive" and amount < 0) {
    return (none, "account has monotone == 'positive', but given amount is < 0.")
  }
  if (account.monotone == "negative" and amount > 0) {
    return (none, "account has monotone == 'negative', but given amount is > 0.")
  }

  let (date, error) = _toDate(date)
  if (date == none) {
    return (none, error)
  }

  if (not sameDayOrLater(account.opening_date, date)) {
    return (
      none,
      "date ("
        + date.display()
        + ") must be same day or later than account.opening_date ("
        + account.opening_date.display()
        + ").",
    )
  }

  if (account.log.len() > 0) {
    let lastDate = account.log.last().date
    if (not sameDayOrLater(lastDate, date)) {
      return (none, "Given date " + date.display() + "is earlier than last log entry (" + lastDate.display() + ").")
    }
  }

  let entry = (date: date, amount: amount, name: name, narration: narration)
  return ((..account, log: (..account.log, entry)), none)
}

/**
 * Create a new account with some change appended to it' log.
 * Parameters are:
 * - account: The account with the log we want to append to.
 * - date: datetime|str for the log entry, must be same day or later to the last log entry.
 * - amount: int|str|decimal
 * - name: non-empty string
 * - narration: string
 */
#let log = (account, date, amount, name, narration) => {
  let (account, error) = _log(account, date, amount, name, narration)
  assert.ne(account, none, message: "" + error)
  return account
}
