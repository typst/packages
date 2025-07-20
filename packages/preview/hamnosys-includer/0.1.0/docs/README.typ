#set page(margin: (top: 1.5cm))
#show raw: set text(font: ("HamNoSysUnicode", "DejaVu Sans Mono"))

#import "hamnosys.typ": hamnosys, hamnosys-text

= HamNoSys (Hamburg Notation System)

HamNoSys is a system for the phonetic transcription of signed languages. The HamNoSysUnicode font uses the Unicode Private Use Area for the HamNoSys symbols.

The font (and the symbol names) are taken from the TeX package #link("https://ctan.org/pkg/hamnosys?lang=en")[_hamnosys_], maintained by Thomas Hanke & Marc Schulder.

To use, first install the font HamNoSysUnicode. (If you're using the #link("https://typst.app")[Typst web service], you just need to include the font among your uploaded files.) Without the font, this package is useless. Second, include the line

```Typst
#import "hamnosys.typ": hamnosys, hamnosys-text
```

in your document.

== `#hamnosys-text`

You can enter the symbols directly into your Typst document. There's no way to actually type most of them, as they're mostly in the Unicode Private Use Area, but this is handy if you want to copy and paste from elsewhere. If you do this, you should wrap them in the `#hamnosys-text` function.

This input:
```Typst
#hamnosys-text("")
```

Gives this output: \
#hamnosys-text("")

If you don't use the function, it might work anyway, but you may have some other font which uses the same Unicode code points for other purposes. (And some of the symbols, such as `hamquery` and `hamexclaim`, are not in the Private Use Area, and are certainly defined by other fonts.) Using `#hamnosys-text` ensures that the HamNoSysUnicode font is used, which is what you want.

== `#hamnosys`

If you're typing yourself, it's much easier to use the names of the symbols, as each symbol has a name. To do this, use the `#hamnosys` function.

This input:
```Typst
You can sign "Hamburg" as #hamnosys("hamceeall,hamthumbopenmod,hamfingerstraightmod,
hamextfingerul,hampalmdl,hamforehead,hamlrat,hamclose,hamparbegin,
hammover,hamreplace,hampinchall,hamfingerstraightmod,hamparend")
```

Gives this output: \
You can sign "Hamburg" as  #hamnosys("hamceeall,hamthumbopenmod,hamfingerstraightmod,
hamextfingerul,hampalmdl,hamforehead,hamlrat,hamclose,hamparbegin,
hammover,hamreplace,hampinchall,hamfingerstraightmod,hamparend")

In the input string, symbol names should be separated with commas. You may optionally additionally use spaces. All symbol names begin with `ham`, and you can leave that off, so the above could just as easily be given as

```Typst
You can sign "Hamburg" as #hamnosys("ceeall, thumbopenmod, fingerstraightmod,
 extfingerul, palmdl, forehead, lrat, close, parbegin, mover, replace, pinchall, fingerstraightmod, parend")
```

= Licence

Since the TeX package which inspired this (and, importantly, the font which this also uses) are under the LPPL, I suppose it's necessary that this is too, though that does feel a bit odd for a Typst package.

#sym.copyright Timothy Green, 2025.

