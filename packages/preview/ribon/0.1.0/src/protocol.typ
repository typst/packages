/// Ribon: RNA secondary-structure visualization and analysis.
///
/// Computation is performed by a deterministic Rust/WASM core. All visible
/// geometry is emitted with native Typst vector primitives.

#let _engine = plugin("../ribon_plugin.wasm")

#import "constraints.typ": folding-constraints

#let _decode(value) = json(value)
#let _constraint-bytes(value) = bytes(json.encode(value))

/// Configure document-time resource safety. The default rejects requests that
/// are exact but predictably exponential or too large for an interactive
/// Typst build. Set `allow-expensive` only for intentional, bounded work.
#let execution-policy(allow-expensive: false) = (
  allow-expensive: allow-expensive,
)

/// Construct an immutable thermodynamic model value.
///
/// Pass the returned dictionary to every analysis operation that must share
/// identical temperature, loop, dangle, salt, and MEA settings.
#let analysis-model(
  id: "ribon-rnastructure-6.6-rna",
  temperature: 37.0,
  min-loop: 3,
  dangles: 2,
  salt: 1.021,
  mea-gamma: 1.0,
) = (
  "id": id,
  "temperature_celsius": temperature,
  "min_loop": min-loop,
  "dangles": dangles,
  "salt_molar": salt,
  "mea_gamma": mea-gamma,
)

/// Construct the built-in RNAstructure 6.6 DNA thermodynamic model.
/// DNA input may use `T`, which is retained in public results and drawings.
/// No additional monovalent-salt correction is applied to this family.
#let dna-model(
  temperature: 37.0,
  min-loop: 3,
  dangles: 2,
  mea-gamma: 1.0,
) = analysis-model(
  id: "ribon-rnastructure-6.6-dna",
  temperature: temperature,
  min-loop: min-loop,
  dangles: dangles,
  salt: 1.021,
  mea-gamma: mea-gamma,
)

/// Build a normalized custom-table overlay. `tables` may contain any of the
/// documented snake_case table keys (for example `stack_37` or `hairpin_dh`);
/// omitted tables inherit the selected base family.
#let thermodynamic-parameter-overrides(name, fingerprint-sha256, tables: (:)) = {
  let profile = (
    "schema_version": 1,
    "name": name,
    "fingerprint_sha256": fingerprint-sha256,
  )
  for (key, value) in tables { profile.insert(key, value) }
  profile
}

/// Construct a model backed by a validated normalized parameter overlay.
#let custom-model(
  parameter-overrides,
  base: "rna",
  temperature: 37.0,
  min-loop: 3,
  dangles: 2,
  salt: 1.021,
  mea-gamma: 1.0,
) = {
  let model = analysis-model(
    id: "ribon-custom-thermodynamic-v1",
    temperature: temperature,
    min-loop: min-loop,
    dangles: dangles,
    salt: salt,
    mea-gamma: mea-gamma,
  )
  model.insert("parameter_base", base)
  model.insert("parameter_overrides", parameter-overrides)
  model
}

/// Execute one operation and return the raw protocol response envelope.
///
/// Unlike `request`, this function does not panic for analysis errors. Inspect
/// `ok` and `error.(code, message)` when user-supplied inputs may be invalid.
#let try-request(
  operation,
  input,
  model: analysis-model(),
  constraints: none,
  options: (:),
  execution: execution-policy(),
  id: none,
) = {
  let message = (
    "schema_version": 1,
    "operation": operation,
    "input": input,
    "model": model,
    "constraints": if constraints == none { folding-constraints() } else { constraints },
    "options": options,
    "execution": execution,
  )
  if id != none { message.insert("id", id) }
  _decode(_engine.run(bytes(json.encode(message))))
}

/// Execute one operation through the versioned stable Rust/WASM protocol.
///
/// The returned envelope contains `ok`, `engine`, `model`, and
/// `result.(kind, data)`. Invalid inputs panic with the stable error code; use
/// `try-request` to handle an unsuccessful envelope explicitly.
#let request(
  operation,
  input,
  model: analysis-model(),
  constraints: none,
  options: (:),
  execution: execution-policy(),
  id: none,
) = {
  let response = try-request(
    operation,
    input,
    model: model,
    constraints: constraints,
    options: options,
    execution: execution,
    id: id,
  )
  if not response.ok {
    panic("ribon " + response.error.code + ": " + response.error.message)
  }
  response
}

/// Extract the typed data payload from a protocol response.
#let data(response) = {
  if type(response) != dictionary or response.at("schema_version", default: 0) != 1 {
    panic("expected a ribon analysis/1 response")
  }
  if not response.at("ok", default: false) {
    panic("cannot read data from an unsuccessful ribon response")
  }
  response.result.data
}

#let result-data(value) = if type(value) == dictionary and value.at("schema_version", default: 0) == 1 {
  data(value)
} else { value }

/// Run MFE, partition function, pair probabilities, centroid, MEA, and
/// ensemble summaries in one pure-Rust analysis call.
