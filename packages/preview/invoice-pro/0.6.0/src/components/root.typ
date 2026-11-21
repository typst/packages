#import "../loom-wrapper.typ": loom, managed-motif
#import "../logic/payment-means.typ": resolve as resolve-payment-means
#import "../utils/text.typ": plain-text
#import "../utils/iban.typ": format-iban, normalize-iban
#import "../validation/issue.typ": blocking-classes, enforce, issue
#import "../validation/data.typ": check-data
#import "../theming/access.typ": theme-of, unsealed
#import "../theming/frame.typ": render-frame

// The data issues of the bank details: a missing or invalid IBAN makes the
// invoice unpayable (data class: it blocks the XML in draft, and it gets no
// EPC-QR code; the renderers print it as given), and an EPC-QR code that
// cannot be generated is shown as a placeholder naming its problems (lint).
// One id per account: the first is `iban`, the next `iban-2`, ...
#let _bank-issues(banks) = {
  let issues = ()
  for (i, bank) in banks.enumerate() {
    let suffix = if i == 0 { "" } else { "-" + str(i + 1) }
    let iban = format-iban(normalize-iban(bank.at("iban", default: "")))
    if not bank.at("iban-valid", default: true) {
      issues.push(if iban == "" {
        issue(
          "iban" + suffix,
          "data",
          "bank-details: the IBAN is missing. Set `iban` on `bank-details`.",
          ref: "EN 16931 BT-84",
          fix: "bank-details(iban: \"DE89 3704 0044 0532 0130 00\")",
          key: "iban-missing",
        )
      } else {
        issue(
          "iban" + suffix,
          "data",
          "bank-details: the IBAN \""
            + iban
            + "\" is not valid (wrong check digits or format). Check it for typos.",
          ref: "EN 16931 BT-84",
          fix: "bank-details(iban: \"DE89 3704 0044 0532 0130 00\")",
          key: "iban",
          args: (iban: iban),
        )
      })
    }
    let problems = bank.at("qr-problems", default: ())
    if problems.len() > 0 {
      issues.push(issue(
        "epc-qr" + suffix,
        "lint",
        "bank-details: the EPC-QR code cannot be generated: "
          + problems.map(problem => problem.message).join("; ")
          + ". Hide it with `qr-code: (display: false)` on `bank-details` if it is not needed.",
        ref: "EPC069-12",
        fix: "bank-details(.., qr-code: (display: false))",
        key: "epc-qr",
        args: (problems: problems.map(problem => problem.short).join(", ")),
      ))
    }
  }
  issues
}

// The data issues of a direct debit: an invalid creditor identifier or an
// invalid IBAN of the debited account makes the printed invoice wrong as
// well (data class, as an invalid IBAN of the bank details).
#let _direct-debit-issues(debit) = {
  if debit == none { return () }
  let issues = ()
  if not debit.at("creditor-id-valid", default: true) {
    let creditor = debit.creditor-id
    issues.push(issue(
      "creditor-id",
      "data",
      "direct-debit: the creditor identifier \""
        + creditor
        + "\" is not a valid SEPA creditor identifier (wrong check digits or format). Check it for typos.",
      ref: "EN 16931 BT-90",
      fix: "direct-debit(.., creditor-id: \"DE98ZZZ09999999999\")",
      key: "creditor-id",
      args: (creditor-id: creditor),
    ))
  }
  if not debit.at("debtor-iban-valid", default: true) {
    let iban = format-iban(debit.debtor-iban)
    issues.push(issue(
      "debtor-iban",
      "data",
      "direct-debit: the IBAN \""
        + iban
        + "\" of `debtor-iban` is not valid (wrong check digits or format). Check it for typos.",
      ref: "EN 16931 BT-91",
      fix: "direct-debit(.., debtor-iban: \"DE02 1203 0000 0000 2020 51\")",
      key: "debtor-iban",
      args: (iban: iban),
    ))
  }
  issues
}

/// The internal root container that wraps the invoice body.
/// It initializes the global context and provides the base document structure to the theme.
///
/// -> content
#let root(
  /// The content to be rendered within the document structure.
  /// -> content
  body,
) = {
  managed-motif(
    "root",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      nest("sender", {
        // missing values stay `none`: validation reports them, nothing prints a placeholder
        ensure("name", none)
        ensure("address", none)
        ensure("city", none)
        ensure("name-inline", none)
        ensure("address-inline", none)
        ensure("city-inline", none)
        ensure("country", "#sender.country")
        ensure("city-name", none)
        ensure("post-code", none)
        ensure("state", none)
        ensure("tax-nr", none)
        ensure("vat-id", none)
        ensure("address-lines", ())

        ensure("extra", ())
        update("extra", x => if type(x) == dictionary { x.pairs() } else { x })
      })

      nest("recipient", {
        // missing values stay `none`: validation reports them, nothing prints a placeholder
        ensure("name", none)
        ensure("address", none)
        ensure("city", none)
        ensure("name-inline", none)
        ensure("address-inline", none)
        ensure("city-inline", none)
        ensure("country", "#recipient.country")
        ensure("city-name", none)
        ensure("post-code", none)
        ensure("state", none)
        ensure("tax-nr", none)
        ensure("vat-id", none)
        ensure("address-lines", ())

        ensure("extra", ())
        update("extra", x => if type(x) == dictionary { x.pairs() } else { x })
      })

      ensure("invoice-date", datetime.today())
      ensure("subject", "#subject")
      ensure("references", ())
      ensure("invoice-nr", none)
      ensure("validation", (level: none, issues: ()))

      nest("locale", {
        ensure("lang", none)
        nest("meta", {
          ensure("region", "de")
        })
        nest("format", {
          ensure("date", (..) => panic("locale::format::date is not provided"))
        })
      })

      ensure("zugferd", none)
      ensure("zugferd-errors", "panic")

      // Internally Calculated
      nest("global", {
        nest("total", {
          ensure("net", decimal(0))
          ensure("gross", decimal(0))
          ensure("due", decimal(0))
          ensure("prepaid", decimal(0))
        })

        nest("formated-total", {
          ensure("net", "0")
          ensure("gross", "0")
          ensure("due", "0")
          ensure("prepaid", "0")
        })
      })
    }),
    measure: (ctx, children) => {
      let all-line-itmes = loom.query.collect-signals(
        children,
        kind: "line-items",
      )
      assert(
        all-line-itmes.len() <= 1,
        message: "There can only be one `line-items` element in the document!",
      )
      let line-items = all-line-itmes.first(default: (:))

      let bank-signals = loom.query.collect-signals(
        children,
        kind: "bank-details",
      )
      let bank-signal = bank-signals.first(default: none)

      let all-payment-terms = loom.query.collect-signals(
        children,
        kind: "payment-terms",
      )
      assert(
        all-payment-terms.len() <= 1,
        message: "There can only be one `payment-terms` element in the document!",
      )
      let payment-terms-signal = all-payment-terms.first(default: none)

      // The payment means: each bank details are an account of a credit
      // transfer; a direct debit, a payment card and `paid` occur once.
      let payment-means-signals = (:)
      for kind in ("direct-debit", "card-payment", "paid") {
        let signals = loom.query.collect-signals(children, kind: kind)
        assert(
          signals.len() <= 1,
          message: "There can only be one `"
            + kind
            + "` element in the document!",
        )
        payment-means-signals.insert(kind, signals.first(default: none))
      }
      assert(
        payment-means-signals.paid == none or payment-terms-signal == none,
        message: "An invoice that is `paid` has no `payment-terms`: nothing is left to pay. Remove the `payment-terms`.",
      )
      // Nor payment terms of its own: a text as `due-date` (e.g. "sofort")
      // would be printed and stated as the payment terms (BT-20) instead of
      // the sentence that the invoice is paid. A date is the due date the
      // payment met.
      let due-date = ctx.at("due-date", default: none)
      if (
        payment-means-signals.paid != none
          and type(due-date) in (str, content)
          and due-date not in ("", [])
      ) {
        assert(
          false,
          message: "An invoice that is `paid` has no payment terms: nothing is left to pay, but `due-date` is a text of payment terms. Remove `due-date`, or give the date the payment was due as a `datetime`.",
        )
      }
      let payment-means = resolve-payment-means(
        bank-signals,
        payment-means-signals.direct-debit,
        payment-means-signals.card-payment,
        payment-means-signals.paid,
      )

      let item-data = loom.mutator.batch(
        line-items.at("item-data", default: (:)),
        {
          import loom.mutator: *
          ensure("items", ())
          ensure("taxes", (:))
          ensure("net-total", decimal("0"))
          ensure("gross-total", decimal("0"))
          ensure("unmodified-net-total", decimal("0"))
          ensure("due-total", decimal("0"))
          ensure("prepaid-total", decimal("0"))
          ensure("prepayments", ())
          ensure("discounts", ())
          ensure("surcharges", ())
        },
      )

      // without a line-items block the totals are zero (the frame and the
      // validation report still render, e.g. the "no line items" marker)
      let total = (
        (
          net: decimal(0),
          gross: decimal(0),
          due: decimal(0),
          prepaid: decimal(0),
        )
          + line-items.at("total", default: (:))
      )
      let formated-total = line-items.at("formated-total", default: (:))

      let public = (
        total: total,
        formated-total: formated-total,
        bank: bank-signal,
        payment-means: payment-means,
      )

      let view = (
        item-data: item-data,
        payment-terms: payment-terms-signal,
        bank: bank-signal,
        payment-means: payment-means,
        // all bank details of the body: an account each (the first is `bank`)
        banks: bank-signals,
        total: total,
        formated-total: formated-total,
      )

      return (public, view)
    },
    draw: (ctx, public, view, body) => {
      let region = ctx.locale.meta.at("region", default: none)
      let region-code = if type(region) == str and region.len() == 2 {
        region
      } else { none }
      // Without a language code, keep the surrounding `text.lang`.
      let lang-args = if ctx.locale.lang != none { (lang: ctx.locale.lang) }
      set text(region: region-code, ..lang-args)

      let eval-ctx = (
        ctx
          + (
            items: view.item-data.items,
            payment-terms: view.payment-terms,
            bank: view.bank,
          )
      )

      import "../public/references.typ" as public-references
      let all-builder-fns = (
        public-references.tax-nr,
        public-references.vat-id,
        public-references.invoice-nr,
        public-references.invoice-date,
        public-references.service-time,
        public-references.customer-nr,
        public-references.buyer-reference,
        public-references.recipient-vat-id,
        public-references.recipient-tax-nr,
        public-references.order-nr,
        public-references.order-date,
        public-references.project,
        public-references.contract-nr,
        public-references.quote-nr,
        public-references.delivery-note-nr,
        public-references.delivery-address,
        public-references.preceding-invoice-nr,
        public-references.preceding-invoice-date,
        public-references.due-date,
        public-references.payment-reference,
        public-references.contact-person,
        public-references.contact-phone,
        public-references.contact-email,
        public-references.seller-tax-nr,
        public-references.seller-vat-id,
        public-references.buyer-vat-id,
        public-references.payee,
      )
      let all-preset-fns = (
        public-references.preset-b2b,
        public-references.preset-b2g,
        public-references.preset-project,
        public-references.preset-din-5008,
      )

      let eval-single-fn(fn) = {
        if fn in all-preset-fns {
          let inner-list = fn()
          inner-list.map(f => eval-single-fn(f))
        } else if fn in all-builder-fns {
          let closure = fn()
          closure(eval-ctx)
        } else {
          fn(eval-ctx)
        }
      }

      let process-raw-refs(raw) = {
        let items = ()
        if type(raw) == function {
          if raw in all-preset-fns {
            items = raw()
          } else {
            items = (raw,)
          }
        } else if type(raw) == array {
          items = raw
        } else if type(raw) == dictionary {
          items = raw.pairs()
        }

        let is-valid-val(v) = {
          v != none and v != "" and v != []
        }

        let flat-refs = ()
        for item in items {
          if type(item) == function {
            let res = eval-single-fn(item)
            if (
              type(res) == array
                and res.len() > 0
                and type(res.first()) == array
                and res.first().len() == 2
            ) {
              for pair in res {
                if pair.len() == 2 and is-valid-val(pair.at(1)) {
                  flat-refs.push(pair)
                }
              }
            } else if type(res) == array and res.len() == 2 {
              if is-valid-val(res.at(1)) {
                flat-refs.push(res)
              }
            }
          } else if (
            type(item) == array
              and item.len() == 2
              and (type(item.first()) == str or type(item.first()) == content)
          ) {
            let (k, v) = item
            if type(v) == function {
              let val = eval-single-fn(v)
              let val-extracted = if type(val) == array and val.len() == 2 {
                val.last()
              } else {
                val
              }
              if is-valid-val(val-extracted) {
                flat-refs.push((k, val-extracted))
              }
            } else {
              if is-valid-val(v) {
                flat-refs.push((k, v))
              }
            }
          } else if type(item) == array {
            for sub-item in process-raw-refs(item) {
              flat-refs.push(sub-item)
            }
          }
        }
        flat-refs
      }

      let normalized-references = process-raw-refs(ctx.references)

      let ctx = (
        ctx
          + (
            references: normalized-references,
            items: view.item-data.items,
            item-data: view.item-data,
            payment-terms: view.payment-terms,
            bank: view.bank,
            global: (
              total: view.total,
              formated-total: view.formated-total,
              bank: view.bank,
            ),
          )
      )

      // Validation: the measured checks join the up-front ones; the level decides.
      let level = ctx.validation.level
      let issues = if level == none { () } else {
        (
          ctx.validation.issues
            + check-data(
              "invoice",
              "measure",
              (
                items: view.item-data.items,
                taxes: view.item-data.taxes.values(),
                recipient: ctx.recipient,
              ),
              region: lower(str(ctx.locale.meta.at("region", default: "de"))),
            )
            + _bank-issues(view.banks)
            + _direct-debit-issues(view.payment-means.direct-debit)
        )
      }
      let issues = enforce(issues, level)
      // Draft: a machine-readable invoice with missing data is never attached
      // (a receiving system would book it automatically); the badge and the
      // report say that it was withheld, and the e-invoice is not validated.
      // Under `none` no check runs, so the XML is attached as `zugferd-errors`
      // decides ("off means off", documented on invoice()).
      let withheld = (
        ctx.zugferd != none and issues.any(x => x.class in blocking-classes)
      )
      let ctx = (
        ctx
          + (
            validation: ctx.validation
              + (
                issues: issues,
                e-invoice-withheld: withheld,
                e-invoice-profile: if ctx.zugferd != none {
                  if ctx.zugferd == auto { "auto" } else { ctx.zugferd }
                },
              ),
          )
      )

      let body = body
      if ctx.zugferd != none and not withheld {
        // Loaded here rather than at the top of the module, so that invoices
        // without an e-invoice do not load the e-invoice modules (code lists,
        // validator, serializer) at all.
        import "../zugferd/zugferd.typ": process-zugferd
        import "../logic/printed.typ": printed-record
        import "../theming/prints.typ": prints-of

        // What the printed invoice shows besides the components, for the
        // checks that it states what the e-invoice states.
        let printed = printed-record(
          prints-of(theme-of(ctx)),
          ctx.references,
          ctx.sender,
          ctx.recipient,
          body,
        )
        let result = process-zugferd(
          ctx + (printed: printed),
          view.item-data,
          payment-goal: view.payment-terms,
          bank: view.bank,
          payment-means: view.payment-means,
        )
        let errors = result.diagnostics.filter(d => d.level == "error")
        // The report module loads only when there is something to report.
        if errors.len() > 0 and ctx.zugferd-errors == "panic" {
          import "../zugferd/report.typ": format-report
          assert(false, message: format-report(result))
        }

        // The e-invoice is "factur-x.xml", or "xrechnung.xml" in the
        // XRECHNUNG profile (`file-name` of the profile). With errors,
        // "report" attaches the XML as a draft: under a name that no
        // receiving software takes for the e-invoice and only as
        // supplementary data. "ignore" skips the check on purpose and
        // attaches the XML like a valid one.
        let draft = errors.len() > 0 and ctx.zugferd-errors == "report"
        // MINIMUM and BASIC WL do not replace the visual invoice either, so
        // their XML is attached as data rather than as an alternative of it.
        let as-data = draft or result.profile.id in ("minimum", "basic-wl")
        pdf.attach(
          if draft { "/invoice-draft.xml" } else {
            "/" + result.profile.at("file-name", default: "factur-x.xml")
          },
          result.xml,
          relationship: if as-data { "data" } else { "alternative" },
          mime-type: "text/xml",
          description: if draft {
            "Draft of the ZUGFeRD / Factur-X invoice data with errors, not a valid e-invoice"
          } else { "ZUGFeRD / Factur-X invoice data" },
        )

        if ctx.zugferd-errors == "report" and result.diagnostics.len() > 0 {
          import "../zugferd/report.typ": format-report
          // The report is the `zugferd-report` part of the theme. Whatever it
          // returns is shown as content. A theme without a report (the part
          // `none`, or a renderer that returns nothing) must not hide errors:
          // they stop the compilation as with "panic", so no invalid
          // e-invoice goes out unnoticed.
          let part-ctx = unsealed(ctx)
          let render-report = part-ctx.theme.parts.at(
            "zugferd-report",
            default: none,
          )
          let report = if render-report != none {
            render-report(part-ctx, result)
          }
          if report in (none, "", []) {
            assert(
              errors.len() == 0,
              message: "The theme shows no e-invoice report (the part `zugferd-report` is `none` or returns nothing), so the errors below stop the compilation even with `zugferd-errors: \"report\"`.\n"
                + format-report(result),
            )
          } else {
            body = [#report] + body
          }
        }
      }

      // Compliance output lives in core, before and outside any theme code.
      // PDF metadata takes plain text: names and subjects may be styled
      // content or, for names, several lines. The author is the seller name
      // of the e-invoice (BT-27).
      let keywords = ("Invoice",)
      if ctx.zugferd != none and not withheld {
        keywords += ("ZUGFeRD", "Factur-X")
      }
      if issues.len() > 0 { keywords += ("Draft",) }
      let author-name = ctx.sender.at("name-inline", default: none)
      if author-name in (none, "", []) {
        author-name = ctx.sender.at("name", default: none)
      }
      let author = plain-text(author-name)
      let description = plain-text(ctx.subject)
      set document(
        title: ctx.subject,
        author: if author == "" { () } else { author },
        date: if type(ctx.invoice-date) == datetime { ctx.invoice-date } else {
          auto
        },
        description: if description == "" { none } else { description },
        keywords: keywords,
      )
      render-frame(ctx, body)
    },
    body,
  )
}
