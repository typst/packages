# a2c-nums

Convert Arabic numbers to Chinese characters.

## usage

```typst
#import "@preview/a2c-nums:0.0.1": int-to-cn-num, int-to-cn-ancient-num, int-to-cn-simple-num, num-to-cn-currency

#int-to-cn-num(1234567890)

#int-to-cn-ancient-num(1234567890)

#int-to-cn-simple-num(2024)

#num-to-cn-currency(1234567890.12)
```

## Functions

### int-to-cn-num

Convert an integer to Chinese number. ex: `#int-to-cn-num(123)` will be `一百二十三`

### int-to-cn-ancient-num

Convert an integer to ancient Chinese number. ex: `#int-to-cn-ancient-num(123)` will be `壹佰贰拾叁`

### int-to-cn-simple-num

Convert an integer to simpple Chinese number. ex: `#int-to-cn-simple-num(2024)` will be `二〇二四`

### num-to-cn-currency

Convert a number to Chinese currency. ex: `#int-to-cn-simple-num(1234.56)` will be `壹仟贰佰叁拾肆元伍角陆分`

### more details

Reference [demo.typ](demo.typ) for more details please.
