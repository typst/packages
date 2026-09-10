#!/usr/bin/env python3
"""pdfclock — turn chalkdeck's clock markers into a LIVE PDF clock.

Typst can typeset a deck but it cannot emit a wall clock: `datetime.today()`
gives the date and `.hour()` is `none`, and there is no way to write a PDF
form field from Typst markup. powerdot has both, because it is not typesetting
its clock at all — reading `powerdot.dtx`, the clock is a `/Widget`
annotation whose value Acrobat JavaScript rewrites every second:

    var pdclock_0 = app.setInterval("pdshowtime()", 1000);

That is a PDF-level trick, so it can be done to a finished PDF from outside.
This script does exactly that, in three steps:

  1. find the invisible marker `#CLK#` that `chalkdeck` leaves in the corner
     of every slide (transparent text, so it is in the content stream and
     therefore locatable, but nothing shows on paper);
  2. cover each marker with a read-only text form field, one per page, named
     `chalkclock.N` — the same shape as powerdot's `pdclock.N`;
  3. attach a document-level JavaScript that calls `app.setInterval` to
     rewrite every field once a second.

The result ticks in Acrobat Reader exactly as powerdot's does, and degrades
to the value baked in at `--freeze` everywhere else.

    python3 tools/pdfclock.py deck.pdf -o deck-live.pdf
    python3 tools/pdfclock.py deck.pdf --format "h:MM tt" --refresh 60000

Requires pymupdf. Viewer support is the same as powerdot's and no better:
Acrobat runs it, most other readers ignore JavaScript entirely.
"""

import argparse
import sys

try:
    import fitz  # pymupdf
except ImportError:
    sys.exit("pdfclock: needs pymupdf — pip install pymupdf")

MARKER = "#CLK#"


def build_js(nfields, fmt, refresh, countdown_from=None):
    """The document-level script, after powerdot's `\\pd@startclock`."""
    # Acrobat's util.printd formats a Date; a countdown has to be arithmetic
    # on a target instead, so the two cases produce different bodies.
    if countdown_from is None:
        set_value = "util.printd('%s', now)" % fmt
    else:
        set_value = (
            "(function(){var left=Math.max(0,%d-Math.floor((now-t0)/1000));"
            "var m=Math.floor(left/60),s=left%%60;"
            "return m+':'+(s<10?'0':'')+s;})()" % int(countdown_from)
        )
    return (
        "var t0 = new Date();\n"
        "function chalkshowtime() {\n"
        "  var now = new Date();\n"
        "  var v = %s;\n"
        "  for (var i = 0; i < %d; i++) {\n"
        "    var f = this.getField('chalkclock.' + i);\n"
        "    if (f) f.value = v;\n"
        "  }\n"
        "  this.dirty = false;\n"
        "}\n"
        "chalkshowtime();\n"
        "var chalkclock_timer = app.setInterval('chalkshowtime()', %d);\n"
        % (set_value, nfields, int(refresh))
    )


def _sample_ink(page, rect):
    """Pick a legible ink by looking at what is actually behind the clock.

    The corner may be a dark slate or white paper depending on the theme, and
    a fixed grey is invisible on one of them. Rendering the patch and reading
    its mean luminance settles it by MEASUREMENT rather than by assumption.
    """
    try:
        pad = fitz.Rect(rect.x0 - 6, rect.y0 - 4, rect.x1 + 6, rect.y1 + 4)
        pix = page.get_pixmap(clip=pad, colorspace=fitz.csGRAY)
        mean = sum(pix.samples) / max(1, len(pix.samples))
    except Exception:
        return (0.5, 0.5, 0.5)
    # light backdrop -> dark ink, and the other way round
    return (0.22, 0.22, 0.22) if mean > 128 else (0.80, 0.84, 0.88)


def add_clock(src, dst, fmt="HH:MM:ss", refresh=1000, size=None,
              colour=None, freeze="00:00:00", countdown=None, quiet=False):
    doc = fitz.open(src)
    n = 0
    for page in doc:
        for rect in page.search_for(MARKER):
            w = fitz.Widget()
            # The marker is transparent text sized like the clock, so its
            # own bounding box is the right place and the right height.
            w.rect = rect
            w.field_type = fitz.PDF_WIDGET_TYPE_TEXT
            w.field_name = "chalkclock.%d" % n
            w.field_value = freeze
            w.text_fontsize = size if size else max(4, rect.height * 0.82)
            w.text_color = colour if colour else _sample_ink(page, rect)
            w.fill_color = None          # no box: it sits on the backdrop
            w.border_width = 0
            w.text_format = 0
            w.field_flags = 1            # ReadOnly, as powerdot's /Ff 1
            w.field_display = 0
            page.add_widget(w)
            n += 1
    if n == 0:
        sys.exit("pdfclock: no %s markers found — compile the deck with "
                 "`clock: (live: true, ..)`" % MARKER)

    js = build_js(n, fmt, refresh, countdown)
    jx = doc.get_new_xref()
    doc.update_object(jx, "<< /S /JavaScript >>")
    doc.update_stream(jx, js.encode(), new=True)
    nx = doc.get_new_xref()
    doc.update_object(nx, "<< /JavaScript << /Names [ (chalkdeck) %d 0 R ] "
                          ">> >>" % jx)
    doc.xref_set_key(doc.pdf_catalog(), "Names", "%d 0 R" % nx)
    # NeedAppearances lets the viewer redraw the field when JS changes it
    doc.xref_set_key(doc.pdf_catalog(), "AcroForm/NeedAppearances", "true")
    doc.save(dst, garbage=0, deflate=True)
    if not quiet:
        print("pdfclock: %d clock field%s written to %s"
              % (n, "" if n == 1 else "s", dst))
    return n


def main():
    ap = argparse.ArgumentParser(description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pdf")
    ap.add_argument("-o", "--output")
    ap.add_argument("--format", default="HH:MM:ss",
                    help="Acrobat util.printd format (default HH:MM:ss); "
                         "e.g. 'h:MM tt' for a 12-hour am/pm clock")
    ap.add_argument("--refresh", type=int, default=1000,
                    help="milliseconds between updates (default 1000)")
    ap.add_argument("--countdown", type=int, metavar="MINUTES",
                    help="count down from MINUTES since the deck was opened, "
                         "instead of showing the time of day")
    ap.add_argument("--size", type=float, help="font size in points")
    ap.add_argument("--colour", "--color", dest="colour", metavar="RRGGBB",
                    help="clock ink as a hex triplet; default is chosen by "
                         "sampling the backdrop behind the corner")
    ap.add_argument("--freeze", default="00:00:00",
                    help="value shown by viewers without JavaScript")
    args = ap.parse_args()
    out = args.output or args.pdf.replace(".pdf", "-live.pdf")
    cd = args.countdown * 60 if args.countdown else None
    col = None
    if args.colour:
        h = args.colour.lstrip("#")
        col = tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    add_clock(args.pdf, out, fmt=args.format, refresh=args.refresh,
              size=args.size, colour=col, freeze=args.freeze, countdown=cd)


if __name__ == "__main__":
    main()
