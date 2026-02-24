# Color My Agda

An unofficial Typst package providing syntax highlight for Agda.

## Use

The package exposes a single styling function.

```
init-color-my-agda(content) -> content
```

You would usually use this in a [show
rule](https://typst.app/docs/reference/styling/#show-rules). For example, the
following two lines:

```typst
#import "@preview/color-my-agda:0.2.0": init-color-my-agda

#show: init-color-my-agda
```

style all subsequent `agda` raw blocks, such as

````typst
```agda
module hello-world where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.Unit using (⊤)
open import Agda.Builtin.String using (String)

postulate putStrLn : String → IO ⊤
{-# FOREIGN GHC import qualified Data.Text as T #-}
{-# COMPILE GHC putStrLn = putStrLn . T.unpack #-}

main : IO ⊤
main = putStrLn "Hello world!"
```
````

## Grammar

The Agda grammar used by this package is a [Sublime
Syntax](http://www.sublimetext.com/docs/3/syntax.html) file. It is automatically
generated from the official [TextMate grammar provided by
Agda](https://github.com/agda/agda-github-syntax-highlighting). The commit used
for the generation is currently `ba5005841ff9bdc5186af68befd58ed456fc7a8c`,
which is targeting Agda 2.8.0.

The converter used is [Sublime Syntax
Convertor](https://github.com/aziz/SublimeSyntaxConvertor).
