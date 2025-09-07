# Color My Agda

An unofficial Typst package providing syntax highlight for Agda.

## Use

After importing the package, you can use a [show
rule](https://typst.app/docs/reference/styling/#show-rules).

````typst
#import "@preview/color-my-agda:0.1.0": init-color-my-agda

#show: init-color-my-agda

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
