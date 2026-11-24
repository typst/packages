#import "../components/dynamic.typ": dynamic

/// Core dynamic context query function.
#let dynamic = dynamic
#let get = dynamic

// --- Top-Level Invoicing Metadata
#let invoice-nr = dynamic("invoice-nr")
#let invoice-date = dynamic("invoice-date")
#let date = dynamic("invoice-date")
#let due-date = dynamic("due-date")
#let customer-nr = dynamic("customer-nr")
#let order-nr = dynamic("order-nr")
#let order-date = dynamic("order-date")
#let project = dynamic("project")
#let contract-nr = dynamic("contract-nr")
#let quote-nr = dynamic("quote-nr")
#let delivery-note-nr = dynamic("delivery-note-nr")
#let preceding-invoice-nr = dynamic("preceding-invoice-nr")
#let payment-reference = dynamic("payment-reference")
#let buyer-reference = dynamic("buyer-reference")
#let subject = dynamic("subject")

// --- Banking
#let iban = dynamic("iban")
#let bic = dynamic("bic")

// --- Sender Details
#let sender = (
  name: dynamic("sender", "name"),
  tax-nr: dynamic("sender", "tax-nr"),
  vat-id: dynamic("sender", "vat-id"),
  address: dynamic("sender", "address"),
  city: dynamic("sender", "city"),
  country: dynamic("sender", "country"),
  email: dynamic("sender", "contact", "email"),
  phone: dynamic("sender", "contact", "phone"),
)

// --- Recipient Details
#let recipient = (
  name: dynamic("recipient", "name"),
  tax-nr: dynamic("recipient", "tax-nr"),
  vat-id: dynamic("recipient", "vat-id"),
  address: dynamic("recipient", "address"),
  city: dynamic("recipient", "city"),
  country: dynamic("recipient", "country"),
  buyer-reference: dynamic("recipient", "buyer-reference"),
  customer-nr: dynamic("recipient", "customer-nr"),
)

// --- Totals
#let total = (
  gross: dynamic("total", "gross"),
  net: dynamic("total", "net"),
)
