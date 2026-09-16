# NOTICE

This notice describes third-party material included in the distributed Typst package `glotter`.

## License Boundary

`glotter` is distributed under:

```text
MIT AND CC-BY-SA-3.0
```

- Typst package code is licensed under the MIT License.
- `glotter.wasm` embeds model data from the fastText model `lid.176.ftz`, licensed under Creative Commons Attribution-ShareAlike 3.0 Unported.
- The standalone `lid.176.ftz` file is not included in this package.

License texts are provided in:

```text
LICENSE-MIT
LICENSE-CC-BY-SA-3.0
```

## fastText Model

`glotter.wasm` embeds model data from:

```text
Name: fastText language identification model
Variant: lid.176.ftz
Supported languages: 176
Original distributor: Facebook AI Research / fastText
Source: https://fasttext.cc/docs/en/language-identification.html
Download URL: https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.ftz
License: Creative Commons Attribution-ShareAlike 3.0 Unported
SPDX identifier: CC-BY-SA-3.0
```

The fastText documentation states that the language identification models were trained on data from Wikipedia, Tatoeba, and SETimes.

## Distribution Notes

The standalone `lid.176.ftz` file is intentionally excluded from this package.
However, `glotter.wasm` embeds the model data, so redistribution of this package must preserve attribution and CC-BY-SA-3.0 license information for the embedded model data.

For the current artifact:

```text
glotter.wasm SHA-256: 3bf6b3ee225e884655dce348ea367c2ca76a99dfa027fdeeff83fceb69a3ca2a
lid.176.ftz build input SHA-256: 8f3472cfe8738a7b6099e8e999c3cbfae0dcd15696aac7d7738a8039db603e83
```

The model was not modified, retrained, quantized, or converted by this package before embedding.

This attribution does not imply endorsement by Facebook, Meta, fastText, the fastText authors, Wikipedia, Tatoeba, SETimes, or any other upstream project or data source.