// `theme.layout`: page masters as plain data (+ `derive`, the envelope catalogue and
// the region mapping: for-region, paper-for-region, digital-for-region, plain-for-region,
// sidebar-for-region, band-for-region, dense-for-region).
// Stable: din-5008-a, din-5008-b, a4-digital, us-letter-digital, plain.
// Experimental: us-letter-10, a4-window-right, a4-window-left, a4-sidebar, us-letter-sidebar (corporate),
// a4-band, us-letter-band (prestige), a4-dense, us-letter-dense (compact).
// Experimental: sn-010130-right/-left (Swiss window layouts, no QR-bill zone).
// 0.6.x preview, opt-in: reserve-qr-bill(layout) adds the Swiss QR-bill zone (placeholder slip).
#import "../theming/layouts.typ": (
  a4-band, a4-dense, a4-digital, a4-sidebar, a4-window-left, a4-window-right,
  band-for-region, dense-for-region, digital-for-region, din-5008-a, din-5008-b,
  envelope, folded, for-region, paper-for-region, plain, plain-for-region,
  reserve-qr-bill, sidebar-for-region, sn-010130-left, sn-010130-right,
  us-letter-10, us-letter-band, us-letter-dense, us-letter-digital,
  us-letter-sidebar,
)
#import "../theming/layout-ops.typ": derive
