#import "date.typ": sameDayOrLater
#import "transaction.typ": _validateDeltaSums
#import "account.typ": _log

/**
 * Creates a new, empty ledger.
 */
#let mkLedger = () => (accounts: (:), transactions: ())

#let _addAccount = (ledger, account) => {
  if (account.name in ledger.accounts) {
    return (none, "Account name '" + account.name + "' already present in ledger.")
  }

  let ledger = (..ledger, accounts: (..ledger.accounts, account.name: account))

  return (ledger, none)
}

/**
 * Given a ledger and an account creates a new ledger that includes the account.
 */
#let addAccount = (ledger, account) => {
  let (ledger, error) = _addAccount(ledger, account)
  assert.eq(error, none, message: "" + error)
  return ledger
}

#let _addTransaction = (ledger, transaction) => {
  if (ledger.transactions.len() > 0) {
    // If a lastTransaction exists it must be same day or before current one.
    let lastTransaction = ledger.transactions.last()

    if (not sameDayOrLater(lastTransaction.date, transaction.date)) {
      return (
        none,
        "last transaction in ledger is from "
          + lastTransaction.date.display()
          + ". Will not add transaction from "
          + transaction.date.display()
          + " after it.",
      )
    }
  }

  // Transaction must have valid delta sums
  let error = _validateDeltaSums(transaction.deltas)
  if (error != none) {
    return (none, error)
  }

  // Transaction must be added to account logs
  let updated_accounts = (:..ledger.accounts)
  for delta in transaction.deltas {
    let account = ledger.accounts.at(delta.account, default: none)

    if (account == none) {
      return (none, "account '" + delta.account + "' not found in ledger.")
    }

    let (account, error) = _log(account, transaction.date, delta.amount, transaction.name, transaction.narration)
    if (account == none) {
      return (none, error)
    }

    updated_accounts.at(account.name) = account
  }
  // Now that we know that all accounts can be processed, and the transaction is fine we modify the ledger.
  let ledger = (
    ..ledger,
    accounts: updated_accounts,
    transactions: (..ledger.transactions, transaction),
  )

  return (ledger, none)
}

/**
 * Given a ledger and a transaction creates a new ledger with the transaction applied.
 */
#let addTransaction = (ledger, transaction) => {
  let (ledger, error) = _addTransaction(ledger, transaction)
  assert.eq(error, none, message: "" + error)
  return ledger
}
