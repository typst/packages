// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `speed` data entries are as follows:
//
// dict:
//    > `walk`: _speedVal
//    > `burrow`: _speedVal
//    > `climb`: _speedVal
//    > `fly`: _speedVal
//    > `canHover`: _speedVal
//    > `swim`: _speedVal
//    > dict
//        > `from`: array
//            > _speedMode
//        > `amount`: int
//        > `note`: string
//    > `alternate`: dict
//      > `walk`: array: _speedVal
//      > `burrow`: array: _speedVal
//      > `climb`: array: _speedVal
//      > `fly`: array: _speedVal
//      > `canHover`: array: _speedVal
//      > `swim`: array: _speedVal

// _speedVal
// dict:
//    > number: int - required
//    > condition: string - required
// int


// _speedMode
// enum:string : "walk", "burrow", "climb", "fly", "swim"

#import "../../external.typ": transl, get

// // speedVal
// 1. dict:
//      number: int
//      condition: str
// 2. int
#let process-speed-val(body) = {
  let name = body.at(0)
  let speedVal = body.at(1)

  let speed = []
  let condition = []

  if type(speedVal) == int {
    speed = speedVal
  } else if speedVal.keys().contains("number") {
    speed = speedVal.number

    if speedVal.keys().contains("condition") {
      condition = speedVal.condition
    }
  } else {
    Panic("Current `speedVal` not supported.")
  }

  if name == "walk" {
    if condition != [] {
      return [#speed ft. #condition]
    }
    return [#speed ft.#condition]
  }
  if condition != [] {
    return get.text([#transl("stype", stype: name, mode: str) #speed ft. #condition])
  }
  return get.text([#transl("stype", stype: name, mode: str) #speed ft.#condition])
}

// Looks like it has:
// 1. dict
//      <name>: speedVal
// 2. dict
//      <name>: array: speedVal
#let process-speed(body) = {
  if not body.keys().contains("speed") { return }
  if body.speed == none { return }

  if type(body.speed) == dictionary {
    let body = body
    if body.speed.keys().contains("canHover") {
      body.speed.remove("canHover")
    }
    return (body.speed.pairs().map(pair => (process-speed-val(pair)))).join(", ")
  } else {
    panic("Speed can be eithe dict: speedVal, or array(dict(number:int, condition: str")
  }
}


// "speed": {
// 		"walk": 40,
// 		"burrow": 20,
// 		"climb": 30
// 	},
//
// 	"speed": {
// 	"walk": 30,
// 	"fly": {
// 		"number": 30,
// 		"condition": "(hover)"
// 	},
// 	"canHover": true
// },
// "speed": {
// 	"walk": {
// 		"number": 40,
// 		"condition": "(wolf form only)"
// 	},
// 	"burrow": {
// 		"number": 5,
// 		"condition": "(fox form only)"
// 	},
// 	"climb": {
// 		"number": 30,
// 		"condition": "(goat form only)"
// 	},
// 	"fly": {
// 		"number": 60,
// 		"condition": "(owl form only)"
// 	}
// },
