#import "@preview/cades:0.3.1": qr-code

// Invoice-specific components — absender, empfaenger, and geschaeftszeile are shared from letter.

/// Your line items as a table.
///
/// Columns: what you did, how many, price each, total.
/// Sums it up at the bottom.
///
/// - posten (array): items as (("What you did", qty, price), ...)
/// -> content
#let posten_table(posten) = {
  if posten.len() > 0 {
    let gesamt_summe = posten.map(p => p.at(1) * p.at(2)).sum()
    
    table(
      columns: (1fr, auto, auto, auto),
      inset: 7pt,
      align: (left, center, right, right),
      stroke: none,
      
      table.hline(stroke: 0.5pt),
      [*Beschreibung*], [*Anzahl*], [*Einzelpreis*], [*Gesamt*],
      table.hline(stroke: 0.25pt),
      
      ..posten.map(p => (
        [#p.at(0)],
        [#p.at(1)],
        [#p.at(2) €],
        [#(p.at(1) * p.at(2)) €]
      )).flatten(),
      
      table.hline(stroke: 0.5pt),
      [], [], [*Gesamtbetrag:*], [*#gesamt_summe €*],
      table.hline(stroke: 0.5pt)
    )
  }
}

/// Bank details plus QR code.
///
/// Bank info on the left, QR on the right. No QR?
/// Just the bank info.
///
/// - absender (dictionary): your name, bank, IBAN, BIC
/// - qr (bool): show the code?
/// - epc-string (str): the data for the QR
/// - zeilenabstand (length): line spacing
#let bank_qr_block(absender, qr, epc-string, zeilenabstand) = {
  let kontoinhaber = if absender.at("kontoinhaber", default: none) != none {
    absender.kontoinhaber
  } else {
    absender.name
  }
  let bic = absender.at("bic", default: "")
  block(width: 100%, breakable: false)[
    #v(2 * zeilenabstand)
    
    #if qr and absender.iban != "" [
      // QR Code and bank details side by side
      #grid(
        columns: (1fr, auto),
        gutter: 2em,
        [
          Bitte überweisen Sie den Gesamtbetrag innerhalb von 14 Tagen auf das folgende Konto:
          #v(0.5em)
          #grid(
            columns: (auto, 1fr),
            gutter: 12pt,
            [*Kontoinhaber:*], [#kontoinhaber],
            [*Bank:*], [#absender.bank],
            [*IBAN:*], [#absender.iban],
          )
        ],
        [
          #qr-code(epc-string, width: 3.5cm)
          #v(0.3em)
          #text(size: 7pt, fill: black.lighten(40%))[Scannen für Überweisung]
        ],
      )
    ] else [
      Bitte überweisen Sie den Gesamtbetrag innerhalb von 14 Tagen auf das folgende Konto:
      #v(0.5em)
      #grid(
        columns: (auto, 1fr),
        gutter: 12pt,
        [*Kontoinhaber:*], [#kontoinhaber],
        [*Bank:*], [#absender.bank],
        [*IBAN:*], [#absender.iban],
      )
    ]
  ]
}

/// The "no VAT" note for small businesses (§ 19 UStG).
///
/// German law wants this on the invoice if you're exempt.
///
/// - zeilenabstand (length): line spacing
#let kleinunternehmer_notice(zeilenabstand) = {
  v(1 * zeilenabstand)
  text(size: 9pt, style: "italic")[
    Als Kleinunternehmer im Sinne von § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.
  ]
}

/// Build the EPC string for the GiroCode QR.
///
/// Banking apps read this and fill in the transfer form for you.
///
/// - kontoinhaber (str): who owns the account
/// - bic (str): BIC
/// - iban (str): IBAN
/// - qr-amount (float): how much to pay
/// - qr-verwendungszweck (str): payment note
/// -> str
#let build_epc_string(kontoinhaber, bic, iban, qr-amount, qr-verwendungszweck) = {
  "BCD\n002\n1\nSCT\n" + bic + "\n" + kontoinhaber + "\n" + iban + "\nEUR" + str(qr-amount) + "\n\n" + qr-verwendungszweck + "\n"
}
