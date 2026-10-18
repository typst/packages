#let _empty-model = (:)

#let _model-score(model, feature, key) = {
  model.at(feature, default: _empty-model).at(key, default: 0)
}

#let _compute-base-score(model) = {
  let total = model
    .values()
    .fold(0, (feature-sum, feature) => {
      (
        feature-sum
          + feature.values().fold(0, (score-sum, score) => score-sum + score)
      )
    })
  -total * 0.5
}

#let _ngram(chars, start, end) = chars.slice(start, end).join("")

#let _parse-with-model(sentence, model, base-score) = {
  if sentence == "" {
    return ()
  }

  let chars = sentence.codepoints()
  if chars.len() == 0 {
    return ()
  }

  let state = range(1, chars.len()).fold((chunks: (), current: chars.at(0)), (
    state,
    i,
  ) => {
    let score = (
      base-score
        + (if i > 2 { _model-score(model, "UW1", chars.at(i - 3)) } else { 0 })
        + (if i > 1 { _model-score(model, "UW2", chars.at(i - 2)) } else { 0 })
        + _model-score(model, "UW3", chars.at(i - 1))
        + _model-score(model, "UW4", chars.at(i))
        + (
          if i + 1 < chars.len() {
            _model-score(model, "UW5", chars.at(i + 1))
          } else { 0 }
        )
        + (
          if i + 2 < chars.len() {
            _model-score(model, "UW6", chars.at(i + 2))
          } else { 0 }
        )
        + (
          if i > 1 {
            _model-score(model, "BW1", _ngram(chars, i - 2, i))
          } else { 0 }
        )
        + _model-score(model, "BW2", _ngram(chars, i - 1, i + 1))
        + (
          if i + 1 < chars.len() {
            _model-score(model, "BW3", _ngram(chars, i, i + 2))
          } else { 0 }
        )
        + (
          if i > 2 {
            _model-score(model, "TW1", _ngram(chars, i - 3, i))
          } else { 0 }
        )
        + (
          if i > 1 {
            _model-score(model, "TW2", _ngram(chars, i - 2, i + 1))
          } else { 0 }
        )
        + (
          if i + 1 < chars.len() {
            _model-score(model, "TW3", _ngram(chars, i - 1, i + 2))
          } else { 0 }
        )
        + (
          if i + 2 < chars.len() {
            _model-score(model, "TW4", _ngram(chars, i, i + 3))
          } else { 0 }
        )
    )

    if score > 0 {
      (chunks: state.chunks + (state.current,), current: chars.at(i))
    } else {
      (chunks: state.chunks, current: state.current + chars.at(i))
    }
  })

  state.chunks + (state.current,)
}

/// Creates a BudouX parser from a model dictionary.
///
/// The returned parser has two callable fields:
/// - `parse(sentence: string)`: Returns segmented chunks as an array of strings.
/// - `separate(sentence: string, separator: any)`: Joins chunks with the separator (default: none).
/// -> dictionary
#let create-parser(model) = {
  let base-score = _compute-base-score(model)
  (
    model: model,
    parse: sentence => _parse-with-model(sentence, model, base-score),
    separate: (sentence, separator: none) => {
      _parse-with-model(sentence, model, base-score).join(separator)
    },
  )
}

/// Pretrained Japanese BudouX model.
/// -> dictionary
#let japanese-model = json("models/ja.json")

/// Pretrained Simplified Chinese BudouX model.
/// -> dictionary
#let simplified-chinese-model = json("models/zh-hans.json")

/// Pretrained Traditional Chinese BudouX model.
/// -> dictionary
#let traditional-chinese-model = json("models/zh-hant.json")

/// Pretrained Thai BudouX model.
/// -> dictionary
#let thai-model = json("models/th.json")

/// Parser created from the pretrained Japanese model.
///
/// The returned parser has two callable fields:
/// - `parse(sentence: string)`: Returns segmented chunks as an array of strings.
/// - `separate(sentence: string, separator: any)`: Joins chunks with the separator (default: none).
/// -> dictionary
#let japanese-parser = create-parser(japanese-model)

/// Parser created from the pretrained Simplified Chinese model.
///
/// The returned parser has two callable fields:
/// - `parse(sentence: string)`: Returns segmented chunks as an array of strings.
/// - `separate(sentence: string, separator: any)`: Joins chunks with the separator (default: none).
/// -> dictionary
#let simplified-chinese-parser = create-parser(simplified-chinese-model)

/// Parser created from the pretrained Traditional Chinese model.
///
/// The returned parser has two callable fields:
/// - `parse(sentence: string)`: Returns segmented chunks as an array of strings.
/// - `separate(sentence: string, separator: any)`: Joins chunks with the separator (default: none).
/// -> dictionary
#let traditional-chinese-parser = create-parser(traditional-chinese-model)

/// Parser created from the pretrained Thai model.
///
/// The returned parser has two callable fields:
/// - `parse(sentence: string)`: Returns segmented chunks as an array of strings.
/// - `separate(sentence: string, separator: any)`: Joins chunks with the separator (default: none).
/// -> dictionary
#let thai-parser = create-parser(thai-model)
