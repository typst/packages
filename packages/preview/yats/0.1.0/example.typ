#import "yats.typ": serialize,deserialize
#{
  let obj = (
    name : "0warning0error",
    age : 100,
    height : 1.8,
    birthday : datetime(year : 1998,month : 7,day:8),
    hobbies : ("jumping",("swiming","learning English,日本語"),regex("fund"),none,true,duration(),type(int),"思密达")
  )
  deserialize(serialize(obj))
}