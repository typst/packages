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


#import "../../external.typ": transl
#import "../process/speed.typ": process-speed

#let render-speed(self, body) = {
  return [#text(fill: self.title.fill, weight: self.title.weight, transl("speed")): #process-speed(body)]
}
