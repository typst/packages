#let tax-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.tax-number
    } else { label }
    let val = if value == auto {
      ctx.sender.at("tax-nr", default: none)
    } else { value }
    (title, val)
  }
}

#let vat-id(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.vat-id
    } else { label }
    let val = if value == auto {
      ctx.sender.at("vat-id", default: none)
    } else { value }
    (title, val)
  }
}

#let invoice-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.invoice-number
    } else { label }
    let val = if value == auto { ctx.invoice-nr } else { value }
    (title, val)
  }
}

#let invoice-date(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.invoice-date
    } else { label }
    let val = if value == auto {
      if type(ctx.invoice-date) == datetime {
        (ctx.locale.format.date)(ctx.invoice-date)
      } else {
        ctx.invoice-date
      }
    } else {
      if type(value) == datetime {
        (ctx.locale.format.date)(value)
      } else {
        value
      }
    }
    (title, val)
  }
}

#let service-time(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.service-time
    } else { label }
    let val = if value == auto {
      let dates = ()
      if "items" in ctx and ctx.items != none {
        for item in ctx.items {
          if item.date != none {
            if type(item.date) == array {
              for d in item.date {
                if type(d) == datetime {
                  dates.push(d)
                }
              }
            } else if type(item.date) == datetime {
              dates.push(item.date)
            }
          }
        }
      }
      if dates.len() == 0 {
        if type(ctx.invoice-date) == datetime {
          (ctx.locale.format.date)(ctx.invoice-date)
        } else {
          ctx.invoice-date
        }
      } else {
        let min-date = dates.first()
        let max-date = dates.first()
        for d in dates {
          if d < min-date { min-date = d }
          if d > max-date { max-date = d }
        }
        let format-date(d) = {
          if type(d) == datetime {
            (ctx.locale.format.date)(d)
          } else {
            str(d)
          }
        }
        if min-date == max-date {
          format-date(min-date)
        } else {
          format-date(min-date) + " – " + format-date(max-date)
        }
      }
    } else {
      value
    }
    (title, val)
  }
}

#let customer-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.customer-number
    } else { label }
    let val = if value == auto {
      ctx.at("customer-nr", default: ctx.recipient.at(
        "customer-nr",
        default: ctx.recipient.at("id", default: ctx.recipient.at(
          "customer-id",
          default: none,
        )),
      ))
    } else { value }
    (title, val)
  }
}

#let buyer-reference(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.buyer-reference
    } else { label }
    let val = if value == auto {
      ctx.recipient.at("buyer-reference", default: ctx.recipient.at(
        "leitweg-id",
        default: ctx.at("buyer-reference", default: none),
      ))
    } else { value }
    (title, val)
  }
}

#let recipient-vat-id(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.recipient-vat-id
    } else { label }
    let val = if value == auto {
      ctx.recipient.at("vat-id", default: none)
    } else { value }
    (title, val)
  }
}

#let recipient-tax-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.recipient-tax-number
    } else { label }
    let val = if value == auto {
      ctx.recipient.at("tax-nr", default: none)
    } else { value }
    (title, val)
  }
}

#let order-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.order-number
    } else { label }
    let val = if value == auto {
      ctx.at("order-nr", default: ctx.recipient.at("order-nr", default: ctx.at(
        "po-nr",
        default: ctx.recipient.at("po-nr", default: none),
      )))
    } else { value }
    (title, val)
  }
}

#let order-date(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.order-date
    } else { label }
    let val = if value == auto {
      let raw = ctx.at("order-date", default: ctx.recipient.at(
        "order-date",
        default: none,
      ))
      if type(raw) == datetime {
        (ctx.locale.format.date)(raw)
      } else {
        raw
      }
    } else {
      if type(value) == datetime {
        (ctx.locale.format.date)(value)
      } else {
        value
      }
    }
    (title, val)
  }
}

#let project(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.project
    } else { label }
    let val = if value == auto {
      ctx.at("project", default: ctx.at("project-nr", default: none))
    } else { value }
    (title, val)
  }
}

#let contract-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.contract-number
    } else { label }
    let val = if value == auto {
      ctx.at("contract-nr", default: none)
    } else { value }
    (title, val)
  }
}

#let quote-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.quote-number
    } else { label }
    let val = if value == auto {
      ctx.at("quote-nr", default: ctx.at("offer-nr", default: none))
    } else { value }
    (title, val)
  }
}

#let delivery-note-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.delivery-note-number
    } else { label }
    let val = if value == auto {
      ctx.at("delivery-note-nr", default: none)
    } else { value }
    (title, val)
  }
}

#let delivery-address(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.delivery-address
    } else { label }
    let val = if value == auto {
      let da = ctx.at(
        "delivery-address",
        default: ctx.recipient.at("delivery-address", default: none),
      )
      if da != none {
        let parts = ()
        if da.name-inline != none and da.name-inline != "" {
          parts.push(da.name-inline)
        }
        if da.address-inline != none and da.address-inline != "" {
          parts.push(da.address-inline)
        }
        if da.city-inline != none and da.city-inline != "" {
          parts.push(da.city-inline)
        }
        if parts.len() > 0 { parts.join(", ") } else { none }
      } else {
        none
      }
    } else { value }
    (title, val)
  }
}

#let preceding-invoice-nr(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.preceding-invoice-number
    } else { label }
    let val = if value == auto {
      ctx.at("preceding-invoice-nr", default: ctx.at(
        "original-invoice-nr",
        default: none,
      ))
    } else { value }
    (title, val)
  }
}

#let due-date(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.due-date
    } else { label }
    let val = if value == auto {
      let d = ctx.at("due-date", default: none)
      if d == none and "payment-goal" in ctx and ctx.payment-goal != none {
        if ctx.payment-goal.at("date", default: none) != none {
          d = ctx.payment-goal.date
        } else if (
          ctx.payment-goal.at("days", default: none) != none
            and type(ctx.invoice-date) == datetime
        ) {
          d = ctx.invoice-date + duration(days: ctx.payment-goal.days)
        }
      }
      if type(d) == datetime {
        (ctx.locale.format.date)(d)
      } else {
        d
      }
    } else {
      if type(value) == datetime {
        (ctx.locale.format.date)(value)
      } else {
        value
      }
    }
    (title, val)
  }
}

#let payment-reference(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.payment-reference
    } else { label }
    let val = if value == auto {
      ctx.at("payment-reference", default: ctx.at(
        "reference",
        default: ctx.invoice-nr,
      ))
    } else { value }
    (title, val)
  }
}

#let contact-person(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.contact-person
    } else { label }
    let val = if value == auto {
      let contact = ctx.sender.at("contact", default: none)
      if type(contact) == dictionary {
        contact.at("name", default: none)
      } else if ctx.sender.at("contact-name", default: none) != none {
        ctx.sender.contact-name
      } else if contact != none {
        contact
      } else {
        ctx.at("contact-person", default: ctx.at("clerk", default: none))
      }
    } else { value }
    (title, val)
  }
}

#let contact-phone(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.contact-phone
    } else { label }
    let val = if value == auto {
      let contact = ctx.sender.at("contact", default: none)
      if type(contact) == dictionary and "phone" in contact {
        contact.phone
      } else {
        ctx.sender.at("phone", default: none)
      }
    } else { value }
    (title, val)
  }
}

#let contact-email(label: auto, value: auto) = {
  ctx => {
    let title = if label == auto {
      ctx.locale.strings.reference.contact-email
    } else { label }
    let val = if value == auto {
      let contact = ctx.sender.at("contact", default: none)
      if type(contact) == dictionary and "email" in contact {
        contact.email
      } else {
        ctx.sender.at("email", default: none)
      }
    } else { value }
    (title, val)
  }
}

// Preset Packs
#let preset-b2b() = (
  invoice-nr(),
  customer-nr(),
  order-nr(),
  invoice-date(),
  service-time(),
  due-date(),
  tax-nr(),
  vat-id(),
  recipient-vat-id(),
)

#let preset-b2g() = (
  invoice-nr(),
  buyer-reference(),
  order-nr(),
  invoice-date(),
  service-time(),
  due-date(),
  tax-nr(),
  vat-id(),
  recipient-vat-id(),
)

#let preset-project() = (
  invoice-nr(),
  customer-nr(),
  project(),
  invoice-date(),
  service-time(),
  due-date(),
  tax-nr(),
  vat-id(),
  recipient-vat-id(),
)

#let preset-din-5008() = (
  order-nr(),
  order-date(),
  contact-person(),
  invoice-date(),
)
