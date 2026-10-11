# Third-party notices

## nibart

`solids3d` depends on the Typst package [nibart](https://github.com/fergousA/nibart) 0.3.0
(`@preview/nibart:0.3.0`), MIT licence, author FERGOUS Abdelhak. It is not bundled: Typst downloads it on
import. It provides the pens (`broadnib`, `copperplate`, `nibpen`), the MetaPost-like paths and the braces
(`delimiter`) used by the pencil / vintage pens, `engraving`, `knot3`, `brace3` and `plate`.

Since 0.4.0 the package contains no binary and no third-party code (the WebAssembly pen module of
*premetadated*, MPL-2.0, bundled until 0.3.0, was removed).
