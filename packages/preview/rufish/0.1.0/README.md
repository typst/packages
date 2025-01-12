# rufish

[`rufish`](https://github.com/f0rgenet/rufish) is a Russian lipsum text generator for [Typst](https://typst.app). It provides a set of built-in Russian text samples and allows you to generate Russian placeholder text for your documents and designs.

`rufish` is inspired by the [kouhu](https://github.com/Harry-Chen/kouhu) package, a Chinese lipsum text generator for Typst. Similar to how `kouhu` generates Chinese placeholder text, `rufish` offers Russian text generation tailored for Typst users. You can generate Russian text samples of various types.

## Why "rufish"?

The name "rufish" combines "ru" (for Russian language) and "fish" (from the Russian Wikipedia definition of "Lorem ipsum" as a placeholder text). In Russian, "Lorem ipsum  " is commonly referred to as "рыба-текст" ("fish text"), which is used to describe dummy text that serves as a template for font and page layout samples. The term "рыба" (fish) is a uniquely Russian expression for this concept, hence its inclusion in the name.

## Usage
```typst
#import "@preview/rufish:0.1.0": rufish, types

#rufish(100) // Generate 100 words of Russian transliterated lorem ipsum text
#rufish(words: 100, types.pangram) // Generate 100 words of Russian pangram text
#rufish(words: 100, types.pushkin) // Generate 100 words of Russian text authored by Pushkin
```

## Available Types

All available text types can be imported with:
```typst
#import "src/lib.typ": types
```

The types include:
- `lorem`: Standard lorem ipsum text
- `pangram`: Russian pangram
- `pushkin`: Texts by Alexander Pushkin
- And other works by famous Russian authors, sourced from the [Welikolepie](https://github.com/yackermann/Welikolepie/) repository.

### Parameters

- `words`: The number of words to generate (positive integer).
- `type`: Choose the type of text to generate (e.g., "lorem", "pangram", etc.). If not specified, the default type is "lorem".

## Inspiration

This package was inspired by the [kouhu](https://github.com/Harry-Chen/kouhu) Typst package, which provides a Chinese lipsum text generator. By borrowing some concepts from `kouhu`, `rufish` was created to provide a similar functionality for the Russian language.

## License

`rufish` is licensed under the MIT License. See [LICENSE](LICENSE) for more details.