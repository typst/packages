# HamNoSys (Hamburg Notation System)

HamNoSys is a system for the phonetic transcription of signed languages. The HamNoSysUnicode font uses the Unicode Private Use Area for the HamNoSys symbols.

The font (and the symbol names) are taken from the TeX package [_hamnosys_](https://ctan.org/pkg/hamnosys?lang=en), maintained by Thomas Hanke & Marc Schulder. You will first need to download the TeX package and find the HamNoSysUnicode font.

If you're working locally, install the font (or pass its location to Typst with the `--font-path` argument). If you're using the [Typst web service](https://typst.app), you just need to include the font among your uploaded files. Without the font, this package is useless.

Second, include the line

```Typst
#import "@preview/hamnosys-includer:1.0.0": ham, hamnosys, hamnosys-text
```

in your document.

## Direct Entry

You can enter the symbols directly into your Typst document. There's no way to actually type most of them, as they're mostly in the Unicode Private Use Area, but this is handy if you want to copy and paste from elsewhere. If you do this, you should wrap them in the `#hamnosys-text` function.

This is demonstrated in [`README.pdf`](https://github.com/TestTimothy/Typst-HamNoSys/blob/main/docs/README.pdf).

If you don't use the function, it might work anyway, but you may have some other font which uses the same Unicode code points for other purposes. (And some of the symbols, such as `hamquery` and `hamexclaim`, are not in the Private Use Area, and are certainly defined by other fonts.) Using `#hamnosys-text` ensures that the HamNoSysUnicode font is used, which is what you want.

## Entry by Symbol Name

If you're typing yourself, it's much easier to use the names of the symbols. There are two ways to do this.

### Use the `#hamnosys` function

```Typst
You can sign "Hamburg" as #hamnosys("hamceeall,hamthumbopenmod,hamfingerstraightmod,
hamextfingerul,hampalmdl,hamforehead,hamlrat,hamclose,hamparbegin,
hammover,hamreplace,hampinchall,hamfingerstraightmod,hamparend")
```

In the input string, symbol names should be separated with commas. You may optionally additionally use whitespace. All symbol names begin with `ham`, and you can leave that off, so the above could just as easily be given as

```Typst
You can sign "Hamburg" as #hamnosys("ceeall, thumbopenmod, fingerstraightmod,
 extfingerul, palmdl, forehead, lrat, close, parbegin, mover, replace, pinchall, fingerstraightmod, parend")
```

### Use the `#ham` variable

For shorter blocks of text, it may be easier to use a variable rather than a function call. So instead of `#hamnosys("close")`, you can write `#ham.close`, which is less typing.

### Symbol Names

HamNoSys symbol names occasionally include digits. The TeX package changed these to words, so for example `hampinch12open` was changed to `hampinchonetwoopen`, because that's necessary in TeX. For this Typst package, both sets of names work.

