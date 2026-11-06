// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/entry.json
// Possible `spellcasting` data entries are as follows:
//
// array:
//   > dict:
//      > name: str -- required
//      > type: str -- required
//      > headerEntries: array: str
//      > constant: _arrayOfSpell
//      > will: _arrayOfSpell
//      > ritual: _arrayOfSpell
//      > rest: entrySpellcasting_frequency
//      > restLong: entrySpellcasting_frequency
//      > daily: entrySpellcasting_frequency
//      > weekly: entrySpellcasting_frequency
//      > monthly: entrySpellcasting_frequency
//      > yearly: entrySpellcasting_frequency
//      > charges: entrySpellcasting_frequency
//      > recharge: entrySpellcasting_recharge
//      > legendary: entrySpellcasting_frequency
//      > spells: dict:
//      >    > `0` (cantrips) array: str
//      >    > others: entrySpellcasting_level1to9
//      > footerEntries: array: str


// _arrayOfSpell
// array:
//    > str
//    > dict:
//        > `entry`: str -- required
//        > `hidden`: bool -- required


// entrySpellcasting_frequency
// dict:
//    "1", "2", ... "9", "1e", ..., "9e": _arrayOfSpell


// entrySpellcasting_recharge
// dict:
//    "1", ..., "6": _arrayOfSpell

// entrySpellcasting_level1to9
// dict:
//    > `lower`: int
//    > `slots`: int
//    > `spells`: array: string - required

////////////////////////////////////////////////////////////////////////////////////////////

#import "../../external.typ": transl, get
#import "regex.typ"


// _arrayOfSpell
#let array-of-spell(body) = {
  assert(type(body) == array, message: "`array-of-spell` - only `array` is supported.")

  // Map the array of "anything" to content. Comma separated.
  let mapped-spells = body.map(entry => {
    assert(
      type(entry) == str or type(entry) == dictionary,
      message: "`array-of-spell` - Spell entries can be either `str` or `dict`.",
    )

    if type(entry) == str {
      [#entry]
    } else if type(entry) == dictionary {
      assert(
        entry.keys().contains("entry") and entry.keys().contains("hidden"),
        message: "`array-of-spell` -Spell dict entries require both `entry` and `hidden` keys to be present. ",
      )

      // TODO: check hidden effect
      [#entry #hidden]
    }
  })

  return mapped-spells.join(", ")
}

#let show-base-array-of-spell(key, body) = {
  return [#key: #array-of-spell(body)#linebreak()]
}

// entrySpellcasting_frequency
// Note: "x" means x/day, while "xa" means x/day each (which could also be x/month, x/month each, etc)
#let entry-spellcasting-frequency(parent-key, body) = {
  assert(type(body) == dictionary, message: "`entry-spellcasting-frequency` - only `dict` is supported.")

  let spellcasting-frequency-keys = (
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
  )

  let spellcasting-frequency-keys-e = (
    "1e",
    "2e",
    "3e",
    "4e",
    "5e",
    "6e",
    "7e",
    "8e",
    "9e",
  )

  for key in body.keys() {
    assert(
      spellcasting-frequency-keys.contains(key) or spellcasting-frequency-keys-e.contains(key),
      message: "Invalid key",
    )
  }

  let spells = ()
  for (key, value) in body.pairs() {
    if key in spellcasting-frequency-keys {
      spells.push([#key: #array-of-spell(value)#linebreak()])
    }
    if key in spellcasting-frequency-keys-e {
      spells.push([#key/each: #array-of-spell(value)#linebreak()])
    }
  }

  return [#spells.join("")]
}


// entrySpellcasting_recharge

#let entry-spellcasting-recharge(key, body) = {
  let spellcasting-recharge = ("1", "2", "3", "4", "5", "6")

  // Check data
  let body = body.at(key)
  for key in body.keys() {
    assert(spellcasting-recharge.contains(key), message: "Invalid key.")
  }

  // Process
  let spells = ()
  for (key, value) in body.pairs() {
    spells.push([Recharge #key: #array-of-spell(value)#linebreak()])
  }

  return [#spells.join(" ")#linebreak()]
}


// entrySpellcasting_level1to9
#let entry-spellcasting-level1to9(body) = {
  let spells = ()
  let keys = body.keys()
  for (name, value) in body {
    let iter-spells = emph(value.spells.join(", "))


    if name == "0" {
      // Cantrips
      spells.push([#transl("cantrips"): #iter-spells])
    } else {
      // Spells
      if keys.contains("lower") and keys.contains("slots") {
        panic("At the moment i have no idea on how this should be showd :(")
      } else if keys.contains("slots") {
        spells.push(
          [#transl("level", n: (name)) (#value.slots #transl("slot", t: slots)): #iter-spells],
        )
      } else {
        spells.push([#transl("level", n: (name)): #iter-spells])
      }
    }
  }

  return spells.join([#linebreak()])
}


#let process-spells(body) = {
  if not body.keys().contains("spellcasting") { return }
  if body.spellcasting == none { return }
  assert(type(body.spellcasting) == array, message: "Spellcasting can be only `array`.")

  let spellcasting = body.spellcasting


  let spells = ()
  for spell-block in spellcasting {

    let current-spell = ()
    let keys = spell-block.keys()

    assert(keys.contains("name") and keys.contains("type"), message: "`name` and `type` are required")

    // name, header
    current-spell.push([==== #spell-block.name ])
    if keys.contains("headerEntries") { current-spell.push([#spell-block.headerEntries.join(" ")#linebreak()#v(4pt)]) }else{ current-spell.push([#linebreak()])}

    // _arrayOfSpell
    if keys.contains("constant") { current-spell.push(show-base-array-of-spell("constant", spell-block.constant)) }
    if keys.contains("will") { current-spell.push(show-base-array-of-spell("will", spell-block.will)) }
    if keys.contains("ritual") { current-spell.push(show-base-array-of-spell("ritual", spell-block.ritual)) }

    // entrySpellcasting_frequency + recharge
    if keys.contains("rest") { current-spell.push(entry-spellcasting-frequency("rest", spell-block.rest)) }
    if keys.contains("restLong") { current-spell.push(entry-spellcasting-frequency("restLong", spell-block.restLong)) }
    if keys.contains("daily") { current-spell.push(entry-spellcasting-frequency("daily", spell-block.daily)) }
    if keys.contains("weekly") { current-spell.push(entry-spellcasting-frequency("weekly", spell-block.weekly)) }
    if keys.contains("monthly") { current-spell.push(entry-spellcasting-frequency("monthly", spell-block.monthly)) }
    if keys.contains("yearly") { current-spell.push(entry-spellcasting-frequency("yearly", spell-block.yearly)) }
    if keys.contains("charges") { current-spell.push(entry-spellcasting-frequency("charges", spell-block.charges)) }
    if keys.contains("recharge") { current-spell.push(entry-spellcasting-recharge("recharge", spell-block.recharge)) }
    if keys.contains("legendary") {
      current-spell.push(entry-spellcasting-frequency("legendary", spell-block.legendary))
    }

    // spells
    if keys.contains("spells") { current-spell.push(entry-spellcasting-level1to9(spell-block.spells)) }

    // current-spell.push([#v(-1em)])
    current-spell.push([#v(0pt)])
    current-spell = current-spell.join("")
    spells.push(current-spell)
  }

  return spells.join()
}
