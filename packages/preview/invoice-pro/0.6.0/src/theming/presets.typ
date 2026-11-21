// Presets = a LOOK (patches) on a default LAYOUT. Looks patch tokens, options and
// only the look-safe fields of standard areas (schema: area-style-fields),
// never geometry, so every look works on every layout (CI: tests/looks.typ).
//
// The shipped set (names stable; the appearance of the EXPERIMENTAL ones may evolve
// in minor releases): classic, plain (frozen), corporate, elegant, prestige, bold,
// technical, soft, compact, boxed. Every look lives in looks/<name>.typ and builds
// on the shared helpers in looks/kit.typ; elegant and prestige share the serif
// family (looks/serif.typ). `minimal` is a docs recipe, not a preset.
#import "build.typ": build-theme
#import "layouts.typ"
#import "looks/corporate.typ" as corporate-look
#import "looks/elegant.typ" as elegant-look
#import "looks/prestige.typ" as prestige-look
#import "looks/bold.typ" as bold-look
#import "looks/technical.typ" as technical-look
#import "looks/soft.typ" as soft-look
#import "looks/compact.typ" as compact-look
#import "looks/boxed.typ" as boxed-look

#let looks = (
  classic: (),
  corporate: corporate-look.look,
  elegant: elegant-look.look,
  prestige: prestige-look.look,
  bold: bold-look.look,
  technical: technical-look.look,
  soft: soft-look.look,
  compact: compact-look.look,
  boxed: boxed-look.look,
)

#let _region(env) = env.at("region", default: none)

// Default layouts follow the SENDER's region (env.region, see layouts.typ); an
// explicit `layout:` always wins.

/// The recommended default: DIN 5008 form A in Germany and for
/// unknown regions, form B in Austria, SN 010130 in Switzerland, .. (the default of
/// `invoice`). FROZEN look; the layout follows `theme.layout.for-region`.
#let classic = build-theme(
  name: "classic",
  layout: env => layouts.for-region(_region(env)),
  looks.classic,
)
/// Successor of `blank`: classic look, no furniture, on the sender's paper. FROZEN.
#let plain = build-theme(
  name: "plain",
  layout: env => layouts.plain-for-region(_region(env)),
  looks.classic,
)
/// Two-colour enterprise look: brand rail, filled table header, payable bar, serif
/// display title. On the sender's sidebar layout (a4-sidebar; us-letter-sidebar in
/// the US). Replaces `modern`. EXPERIMENTAL.
#let corporate = build-theme(
  name: "corporate",
  layout: env => layouts.sidebar-for-region(_region(env)),
  looks.corporate,
)
/// Serif family, ink: centred letterhead, hairlines, no fills - the sender's window
/// layout, DIN 5008 form B where the region rule picks form A (the centred
/// letterhead needs form B's 37 mm zone). EXPERIMENTAL.
#let elegant = build-theme(
  name: "elegant",
  layout: env => {
    let l = layouts.for-region(_region(env))
    if l.name == "din-5008-a" { layouts.din-5008-b } else { l }
  },
  looks.elegant,
)
/// Serif family, onyx and champagne: a full-bleed letterhead band on the digital
/// band layout of the sender's paper (a4-band, us-letter-band in the US); on window
/// layouts the letterhead box becomes the onyx surface. Digital-first. EXPERIMENTAL.
#let prestige = build-theme(
  name: "prestige",
  layout: env => layouts.band-for-region(_region(env)),
  looks.prestige,
)
/// Poster block in the brand colour with the document word and the amount due,
/// capital mono labels, heavy rules, a colour bar for the payable amount; digital
/// paper of the sender's region. Agencies and studios. EXPERIMENTAL.
#let bold = build-theme(
  name: "bold",
  layout: env => layouts.digital-for-region(_region(env)),
  looks.bold,
)
/// Spec sheet for IT and engineering: mono labels and figures, a fine rule grid,
/// the payable amount inverted - digital paper of the sender's region. EXPERIMENTAL.
#let technical = build-theme(
  name: "technical",
  layout: env => layouts.digital-for-region(_region(env)),
  looks.technical,
)
/// Warm and friendly for cafés, practices and B2C: serif voice, rounded cards,
/// dotted rules - digital paper of the sender's region. EXPERIMENTAL.
#let soft = build-theme(
  name: "soft",
  layout: env => layouts.digital-for-region(_region(env)),
  looks.soft,
)
/// Maximum density for 40-80 line invoices: 8.5 pt, item-number and unit columns,
/// a filled repeating header, delivery-note groups, boxed totals; on the dense
/// layout of the sender's paper (a4-dense, us-letter-dense). Wholesale and B2B
/// supply. EXPERIMENTAL (as is its layout).
#let compact = build-theme(
  name: "compact",
  layout: env => layouts.dense-for-region(_region(env)),
  looks.compact,
)
/// Print-first ruled form boxes, heavy grotesque title, mono form labels; no fill
/// carries meaning. On the sender's window layout. EXPERIMENTAL.
#let boxed = build-theme(
  name: "boxed",
  layout: env => layouts.for-region(_region(env)),
  looks.boxed,
)
