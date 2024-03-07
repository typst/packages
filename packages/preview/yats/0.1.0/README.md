# Yats

serialize the Typst objects into bytes and deserialize the bytes into Typst objects

## Reason
I want to interactive between the wasm and typst. But I found that the input arguments and output argument are all bytes. It is not convenient for me to use WASM. So I designed the serialization protocol and implemented this serialization module for reference.

Although there have been some serialization APIs like cbor, yaml, json and others, this is a good learning material and a good example to show the abilities of Typst.

## Example

Have a look at the example [here](./example.typ).

## Usage

Simply import 2 functions : `serialize`, `deserialize`.

And enjoy it

```typ
#import "yats.typ": serialize,deserialize
#{
  let obj = (
    name : "0warning0error",
    age : 100,
    height : 1.8,
    birthday : datetime(year : 1998,month : 7,day:8)
  )
  deserialize(serialize(obj))
}
```

## Supported Types
- `none`
- `bool`
- `type` : type is a type
- `int`
- `float` : (implemented in string, for convenience) 
- `datetime` : only support `year`,`month`,`day` ; `hour`, `minute`,`second`; both combined.
- `duration`
- `bytes`
- `string`
- `regex` : (dealing with it is a little tricky)
- `array` : the element in it can be anything listed.
- `dictionary` : the value in it can be anything listed.

## `Yats` function

```typ
#let serialize(
  data : any
) = { .. }
```

**Arguments:**

- `data`: [`any`] &mdash; Any supported object .

**Return**

The serialized bytes.


```typ
#let deserialize(
  data : array
) = { .. }
```

**Arguments:**

- `data`: [`bytes`] &mdash; serialized objects represented by bytes  .

**Return**

binary array. (the first one is the object deserialized, the second one is the valid length of the bytes)


## Potential Problems and limitation

- Some problem can be caused by changes of `repr`. For example, the serialization of `regex` relies on the `repr` of `regex`. And there are no method to directly catch the inner `string`.

- Because of lack of time, only basic types are supported. But more types can be supported in Typst.


## License

This project is licensed under the Apache 2.0 License.