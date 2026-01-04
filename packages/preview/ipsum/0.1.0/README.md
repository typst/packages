# Ipsum

Ipsum is a package which provides blind text generation through different modes such as natural writing, dialogue patterns, geometric structures and mathematical sequences in multiple paragraphs rather than a single block.

## Usage

```typ
#import "@preview/ipsum:0.1.0": *

// Standard "human" patterns (default with 5 paragraphs)
#ipsum(/*args*/)
```

View examples and minidoc [here](https://github.com/neuralpain/ipsum/tree/main/examples).

## Ipsum Parameters

Enable `hint` to view the effective parameters the active mode.

```typ
#ipsum(hint: true)
```

### Global Parameters

These parameters apply to most or all modes.

| Parameter         |   Default   | Description                                          |
| ----------------- | :---------: | ---------------------------------------------------- |
| `mode`            | `"natural"` | The generation method.                               |
| `pars`            |     `5`     | Number of paragraphs to generate.                    |
| `indent`          |   `0em `    | Paragraph first line indent.                         |
| `spacing`         |    `1em`    | Vertical spacing between paragraphs.                 |
| `stats`           |   `false`   | Show generation statistics and notes.                |
| `word-count`      |   `false`   | Prefixes every paragraph with its word count.        |
| `hint`            |   `false`   | Displays the valid parameters for the selected mode. |
| `ignore-limits`   |   `false`   | Allow values to go past safe limits.                 |
| `ignore-warnings` |   `false`   | Hide warning text.                                   |

### Generation Modes

Text generation is available in the following modes

- Human: `natural`, `dialogue`
- Geometric: `fade`, `fit`
- Logarithmic: `grow`
- Sequential: `fibonacci`

#### Natural Flow (`mode: "natural"`)

The default mode. Simulates the flow of human writing. It randomly alternates between standard, long, and short paragraphs.

<!-- Best for: Articles, blog posts, essays. -->

| Parameter | Default | Description                                    |
| --------- | :-----: | ---------------------------------------------- |
| `average` |  `60`   | The baseline word count per paragraph.         |
| `var`     |  `30`   | How much the length deviates from the average. |
| `seed`    |  `42`   | Random seed for different variations.          |

**Example:**

```typ
// I want 8 paragraphs with an average of 73 words, keeping
// the length changes within 14 words using a specific
// random pattern seed of 592.
#ipsum(mode: "natural", pars: 8, average: 73, var: 14, seed: 592)
```

#### Dialogue Scene (`mode: "dialogue"`)

Generates a mix of narrative prose and spoken dialogue enclosed in quotation marks. Can be used for testing how book pages, interviews or conversations may look.

<!-- Best for: Typesetting fiction, testing distinct paragraph styles. -->

| Parameter  | Default | Description                                       |
| ---------- | :-----: | ------------------------------------------------- |
| `events`   |  `10`   | Total number of lines (narrative or spoken).      |
| `ratio`    | `0.618` | Probability (0.0 to 1.0) that a line is dialogue. |
| `seed`     |  `42`   | Random seed for the conversation flow.            |
| `h-indent` |  `0em`  | Paragraph hanging indent.                         |

**Example:**

```typ
// I want 5 exchange events where 70% of the text (ratio: 0.7)
// is spoken dialogue.
#ipsum(mode: "dialogue", events: 5, ratio: 0.7, indent: 2em)
```

#### Geometric Fade (`mode: "fade"`)

Generates paragraphs that decay in length geometrically. Starts with a big paragraph and gets smaller and smaller. Great for testing visual flow.

<!-- Best for: Introductions, newsletter openers, marketing copy. -->

| Parameter | Default | Description                                 |
| --------- | :-----: | ------------------------------------------- |
| `start`   |  `100`  | The word count of the *first* paragraph.    |
| `ratio`   | `0.618` | Decay rate. `< 1.0` shrinks, `> 1.0` grows. |

**Example:**

```typ
// I want to start with a long 80-word block and have each
// of the 4 paragraphs shrink by 40% (ratio: 0.6) compared
// to the one before it.
#ipsum(mode: "fade", start: 80, pars: 4, ratio: 0.6)
```

#### Logarithmic Growth (`mode: "grow"`)

The opposite of a fade. Starts with a short sentence and slowly builds up into longer, denser blocks of text.

<!-- Best for: Technical documentation, dramatic build-ups. -->

| Parameter | Default | Description                        |
| --------- | :-----: | ---------------------------------- |
| `base`    |  `20`   | Minimum base word count.           |
| `factor`  |  `50`   | The steepness of the growth curve. |

**Example:**

```typ
// I want 4 paragraphs with the first one starting at a `base`
// of 10 words, expanding by a factor of 25 as they go.
#ipsum(mode: "grow", pars: 4, base: 10, factor: 25, word-count: true)
```

#### Geometric Fit (`mode: "fit"`)

Copywriting. Specify exactly how many words you need in total (e.g., 200 words), and it will be divided up across your paragraphs. Useful for areas with a hard word limit or limited space and want to see how text looks broken up.

<!-- Best for: Magazine layouts, fixed-height sidebars. -->

| Parameter | Default | Description                                                       |
| --------- | :-----: | ----------------------------------------------------------------- |
| `total`   |  `300`  | The sum of words across all generated paragraphs.                 |
| `ratio`   | `0.618` | The size relationship between the current paragraph and the next. |

**Example:**

```typ
// I want to fit a total of 250 words into 5 paragraphs,
// making each one 25% smaller (ratio: 0.75) than the last.
#ipsum(mode: "fit", total: 250, pars: 5, ratio: 0.75, stats: true, word-count: true)
```

#### Fibonacci Sequence (`mode: "fibonacci"`)

Generates paragraph lengths corresponding to the Fibonacci sequence (`1, 1, 2, 3, 5, 8...`).

| Parameter | Default | Description                                 |
| --------- | :-----: | ------------------------------------------- |
| `steps`   |   `8`   | How many steps of the sequence to generate. |
| `reverse` | `true`  | Switch to reverse the sequence.             |

**Example:**

```typ
// I want 7 paragraphs with word counts based on the Fibonacci
// sequence, ordered from largest to smallest (reverse: true).
#ipsum(mode: "fibonacci", steps: 7, reverse: true, spacing: 0.5em, word-count: true)
```

## Safety Thresholds & Limits

The following guardrails are implemented to keep the Typst compiler working responsively:

* Word Threshold: Warns you if you try to generate more than 100,000 words.
* Paragraph Threshold: Warns you if you exceed 50 paragraphs.
* Fibonacci Limits: Prevents generating more than 25 steps (as Fibonacci numbers grow exponentially and put stress on the system).

Use `ignore-warnings: true` and `ignore-limits: true` to disable guardrails [accordingly](#global-parameters).
