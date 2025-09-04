#import "@preview/tiaoma:0.3.0" // For QR code

#let olaii-upn-qr(
  ime-placnika: "",
  naslov-placnika: "",
  kraj-placnika: "",
  iban-placnika: "",
  referenca-placnika-1: "",
  referenca-placnika-2: "",
  namen-placila: "",
  rok-placila: "",
  koda-namena: "",
  datum-placila: "",
  nujno: false,
  polog: false,
  dvig: false,

  ime-prejemnika: "",
  naslov-prejemnika: "",
  kraj-prejemnika: "",
  iban-prejemnika: "",
  referenca-prejemnika-1: "",
  referenca-prejemnika-2: "",

  znesek: "",
  qr-content: "",

  top-offset: 0mm,
  left-offset: 0mm,

  debug: false,
  debug-with-background: false,
) = {
  // Debug
  let debug = debug
  let stroke-width = if (debug) { 0.5pt } else { 0pt };

  // Font
  set text(
    font: "Arial",
    size: 8pt,
    fill: black,
  )

  // Default rect
  set block(
    fill: none,
    stroke: 0pt,
    inset: 0pt,
  )
  set rect(
    fill: none,
    stroke: 0pt,
    inset: 0pt,
  )

  // Boolean box
  let boolean-box(value) = stack(
    dir: ttb,
    v(0.5mm),
    rect(
      width: 4mm, 
      height: 4mm, 
      stroke: stroke-width,
      align(center + horizon, block(if (value == true) {"X"}))
    )
  )

  // Test data
  let data = (
    placnik: (
      ime: ime-placnika,
      naslov: naslov-placnika,
      kraj: kraj-placnika,
      iban: iban-placnika,
      referenca1: referenca-placnika-1,
      referenca2: referenca-placnika-2,
      namen: namen-placila,
      rok-placila: rok-placila,
      koda-namena: koda-namena,
      datum-placila: datum-placila,
      nujno: nujno,
      polog: polog,
      dvig: dvig,
    ),
    prejemnik: (
      ime: ime-prejemnika,
      naslov: naslov-prejemnika,
      kraj: kraj-prejemnika,
      iban: iban-prejemnika,
      referenca1: referenca-prejemnika-1,
      referenca2: referenca-prejemnika-2,
    ),
    znesek: znesek,
    qr-content: qr-content,
  )

  /*
  let qrCode = ""
  qrCode += "UPNQR" + "\n" // 1. Vodilni slog
  qrCode += data.placnik.iban + "\n" // 2. IBAN plačnika
  qrCode += "" + "\n" // 3. Polog
  qrCode += "" + "\n" // 4. Dvig
  qrCode += data.placnik.referenca1 + " " + data.placnik.referenca2 + "\n" // 5. Referenca plačnika 
  qrCode += data.placnik.ime + "\n" // 6. Ime plačnika (Obvezno)
  qrCode += data.placnik.naslov + "\n" // 7. Ulica in št. plačnika (Obvezno)
  qrCode += data.placnik.kraj + "\n" // 8. Kraj plačnika (Obvezno)
  qrCode += data.znesek + "\n" // 9. Znesek (Obvezno)
  qrCode += "" + "\n" // 10. Datum plačika
  qrCode += "" + "\n" // 11. Nujno
  qrCode += data.placnik.koda-namena + "\n" // 12. Koda namena (Obvezno)
  qrCode += data.placnik.namen + "\n" // 13. Namen plačila (Obvezno)
  qrCode += data.placnik.rok-placila + "\n" // 14. Rok plačila
  qrCode += data.prejemnik.iban + "\n" // 15. IBAN prejemnika (Obvezno)
  qrCode += data.prejemnik.referenca1 + " " + data.prejemnik.referenca2 + "\n" // 16. Referenca prejemnika (Obvezno)
  qrCode += data.prejemnik.ime + "\n" // 17. Ime prejemnika (Obvezno)
  qrCode += data.prejemnik.naslov + "\n" // 18. Ulica in št. prejemnika (Obvezno)
  qrCode += data.prejemnik.kraj + "\n" // 19. Kraj prejemnika (Obvezno)
  qrCode += "" + "\n" // 19. Kontrolna vsota (Obvezno)
  */

  // Wrapper
  block(
    height: 99mm, // A bit smaller so 3 can fit on one page
    width: 210mm,
    stroke: stroke-width,
    inset: 0pt,
    clip: true,
    fill: none,
    
    // Offset wrapper
    place(
      top + left,
      dx: left-offset,
      dy: top-offset,
      stack(
        dir: ltr,
        spacing: 0pt,

        if debug-with-background {
          // Background
          place(
            dx: 0pt, 
            dy: 0pt, 
            image("assets/upn-qr.png", height: 99mm, width: 210mm),
          )
        },

        // ----------------------------------------------
        // -------------------- Left --------------------
        // ----------------------------------------------
        block(
          width: 60mm,
          height: 100%,
          stroke: stroke-width,
          inset: (
            top: 6mm,
            right: 3.5mm,
            bottom: 3.5mm,
            left: 4mm,
          ),

          stack(
            dir: ttb,

            // Ime plačnika
            block(
              width: 52.5mm,
              height: 13.5mm,
              stroke: stroke-width,
              inset: 4pt,
              data.placnik.ime + "\n" + data.placnik.naslov + "\n" + data.placnik.kraj
            ),

            v(3mm),

            // Namen / rok plačila
            block(
              width: 52.5mm,
              height: 9mm,
              stroke: stroke-width,
              inset: 4pt,
              data.placnik.namen,
            ),

            v(3mm),

            // Znesek
            align(right, block(
              width: 40mm,
              height: 5mm,
              stroke: stroke-width,
              inset: 4pt,
              data.znesek,
            )),

            v(3mm),

            // IBAN in referenca prejemnika
            block(
              width: 52.5mm,
              height: 13.5mm,
              stroke: stroke-width,
              inset: 4pt,
              data.prejemnik.iban + "\n" + data.prejemnik.referenca1 + " " + data.prejemnik.referenca2,
            ),

            v(3mm),

            // Ime prejemnika
            block(
              width: 52.5mm,
              height: 13.5mm,
              stroke: stroke-width,
              inset: 4pt,
              data.prejemnik.ime + "\n" + data.prejemnik.naslov + "\n" + data.prejemnik.kraj
            ),
          ),
        ),

        // ----------------------------------------------
        // -------------------- Right --------------------
        // ----------------------------------------------
        block(
          width: 150mm, 
          height: 100%, 
          stack(
            dir: ttb,

            // -------------------- Top (PLAČNIK) --------------------
            block(
              width: 100%,
              height: 55mm,
              stroke: stroke-width,
              inset: (
                top: 6mm,
                left: 3.5mm,
                right: 4mm,
                bottom: 0mm,
              ),

              stack(
                dir: ttb,
                spacing: 3.5mm,

                // QR code, rows 1-4
                stack(
                  dir: ltr,
                  spacing: 3mm,

                  // Left
                  block(
                    width: 40mm,
                    height: 39.5mm,
                    inset: 3mm,
                    stroke: stroke-width,
                    // Koda QR
                    { if (data.qr-content != "") { tiaoma.upnqr(data.qr-content) }}
                  ),

                  // Right
                  stack(
                    dir: ttb,

                    // Row 1
                    stack(
                      dir: ltr,

                      // IBAN Plačnika
                      block(
                        width: 72mm,
                        height: 5mm,
                        stroke: stroke-width,
                        inset: 4pt,
                        data.placnik.iban,
                      ),

                      // Spacer
                      h(7.5mm),

                      // Polog
                      boolean-box(data.placnik.polog),

                      // Spacer
                      h(7.5mm),

                      // Dvig
                      boolean-box(data.placnik.dvig),
                    ),

                    v(3mm),

                    // Row 2
                    stack(
                      dir: ltr,
                      spacing: 2mm,

                      // Referenca plačnika 1
                      block(
                        width: 15mm,
                        height: 5mm,
                        stroke: stroke-width,
                        inset: 4pt,
                        data.placnik.referenca1,
                      ),

                      // Referenca plačnika 2
                      block(
                        width: 82.5mm,
                        height: 5mm,
                        stroke: stroke-width,
                        inset: 4pt,
                        data.placnik.referenca2,
                      ),
                    ),

                    v(3mm),

                    // Row 3
                    // Ime, ulica in kraj plačnika
                    block(
                      width: 99.5mm,
                      height: 15mm,
                      stroke: stroke-width,
                      inset: 4pt,
                      data.placnik.ime + "\n" + data.placnik.naslov + "\n" + data.placnik.kraj
                    ),

                    v(3.5mm),

                    // Row 4
                    stack(
                      dir: ltr,

                      // Spacer
                      h(7.75mm),

                      // Znesek
                      block(
                        width: 42mm,
                        height: 5mm,
                        stroke: stroke-width,
                        inset: 4pt,
                        data.znesek,
                      ),
                    
                      // Spacer
                      h(6mm),

                      // Datum plačila
                      block(
                        width: 30mm,
                        height: 5mm,
                        stroke: stroke-width,
                        inset: 4pt,
                        data.placnik.datum-placila,
                      ),

                      // Spacer
                      h(6mm),

                      // Nujno
                      boolean-box(data.placnik.nujno),
                    ),
                  ),
                ),

                // Row 5
                stack(
                  dir: ltr,
                  spacing: 2mm,

                  // Koda namena
                  block(
                    width: 15mm,
                    height: 5mm,
                    stroke: stroke-width,
                    inset: 4pt,
                    data.placnik.koda-namena,
                  ),

                  // Namen plačila
                  block(
                    width: 94mm,
                    height: 5mm,
                    stroke: stroke-width,
                    inset: 4pt,
                    data.placnik.namen,
                  ),

                  // Rok plačila
                  block(
                    width: 29mm,
                    height: 5mm,
                    stroke: stroke-width,
                    inset: 4pt,
                    data.placnik.rok-placila,
                  ),
                ),
              ),
            ),

            // -------------------- Bottom (PREJEMNIK) --------------------
            block(
              width: 100%,
              height: 44mm,
              stroke: stroke-width,
              inset: (
                top: 3mm,
                left: 3.5mm,
                right: 4mm,
                bottom: 0mm,
              ),

              stack(
                dir: ttb,
                spacing: 3mm,

                // Row 1
                // IBAN prejemnika
                block(
                  width: 128mm,
                  height: 5mm,
                  stroke: stroke-width,
                  inset: 4pt,
                  data.prejemnik.iban,
                ),

                // Row 2
                stack(
                  dir: ltr,
                  spacing: 2mm,

                  // Referenca prejemnika 1
                  block(
                    width: 15mm,
                    height: 5mm,
                    stroke: stroke-width,
                    inset: 4pt,
                    data.prejemnik.referenca1,
                  ),

                  // Referenca prejemnika 2
                  block(
                    width: 83mm,
                    height: 5mm,
                    stroke: stroke-width,
                    inset: 4pt,
                    data.prejemnik.referenca2,
                  ),
                ),

                // Row 3
                // Ime, ulica in kraj prejemnika
                block(
                  width: 100mm,
                  height: 15mm,
                  stroke: stroke-width,
                  inset: 4pt,
                  data.prejemnik.ime + "\n" + data.prejemnik.naslov + "\n" + data.prejemnik.kraj
                ),
              ),
            ),
          ),
        ),
      ),
    )
  )
}