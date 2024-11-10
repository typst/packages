# Typst Wordle

Play wordle with [Typst](https://typst.app/)!

https://github.com/user-attachments/assets/6c9a8081-5165-41fe-b167-67b61c36669e

## Rule

Wordle is a guessing game for predefined five-letter English words.

1. By typing a five-letter English word and end it with `?`, you can "guess" an English word:

    ```typ
    #import "@preview/wordle:0.1.0": wordle
    #show: wordle.with(seed: datetime.today())

    // Enter a five-letter word and add a '?' at the end.
    // One attempt per one line.
    world?
    cream?
    ```

2. The guessed English word is automatically colored by character.
    - Green: The letter appears in that position in the correct word
    - Yellow: The letter appears in the correct word (but not in that position)
    - Gray: The letter does not appear in the correct word (anymore)

3. Let's guess the correct English word within 6 guesses!

## Options

```typst
#show: wordle.with(
  // Random seed (int | datetime | none)
  seed: datetime.today(),
  // Number of maximum attempts (int)
  max-guesses: 6,
  // Virtual keyboard array displayed below (str[])
  key-layout: ("qwertyuiop", "asdfghjkl", "zxcvbnm"),
)
```
