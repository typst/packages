HamNoSys is a system for the phonetic transcription of signed languages. The HamNoSysUnicode font uses the Unicode Private Use Area for the HamNoSys symbols. The font (and the symbol names) are taken from the TeX package _[hamnosys](https://ctan.org/pkg/hamnosys?lang=en)_, maintained by Thomas Hanke & Marc Schulder.

To use, first install the font HamNoSysUnicode. You can find the font within the TeX package linked above. (If you're using the [Typst web service](https://typst.app), you just need to include the font among your uploaded files.) Without the font, this package is useless.

This defines the functions `#hamnosys-text`, which allows input of HamNoSys symbols directly, and `#hamnosys`, which allows input of symbols by name.

Most (not all) HamNoSys symbols are defined in the Unicode Private Use Area, so cannot be typed, but if you copy and paste symbols from elsewhere you should use `#hamnosys-text` to ensure that the HamNoSysUnicode font is used.

To enter symbols by name, use the `#hamnosys` function.

```
You can sign "Hamburg" as #hamnosys("hamceeall,hamthumbopenmod,hamfingerstraightmod,
hamextfingerul,hampalmdl,hamforehead,hamlrat,hamclose,hamparbegin,
hammover,hamreplace,hampinchall,hamfingerstraightmod,hamparend")
```

In the input string, symbol names should be separated with commas. You may optionally additionally use whitespace. All symbol names begin with `ham`, and you can leave that off, so the above could just as easily be given as

```
You can sign "Hamburg" as #hamnosys("ceeall, thumbopenmod, fingerstraightmod,
extfingerul, palmdl, forehead, lrat, close, parbegin, mover, replace, pinchall,
fingerstraightmod, parend")
```

HamNoSys symbol names occasionally include digits. The TeX package changed these to words, so for example `hampinch12open` was changed to `hampinchonetwoopen`, because that's necessary in TeX. For this Typst package, both sets of names work.
