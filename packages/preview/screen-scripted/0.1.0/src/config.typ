#let sp_config = state("scripted/config", (:))

#let default_config() = (
  check-strict: true,
  bold-slugs: true,
  dialogue-cont: true,  // Set to "false" for manual dialogue continuation
  slug-dashes: "double",  // "single" | "double"
  cont-str: "CONT'D",
)

#let _validate_user_config(input_config) = {
  let keys = default_config().keys()

  for k in input_config.keys() {
    if k not in keys {
      assert(
        false,
        message: "Input config value '" + k
          + "' not expected. Expected keys: "
          + keys.join(", "),
      )
    }
  }
}
