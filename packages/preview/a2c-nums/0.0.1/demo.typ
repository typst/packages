#import "@preview/a2c-nums:0.0.1": int-to-cn-num, int-to-cn-ancient-num, int-to-cn-simple-num, num-to-cn-currency

#set heading(numbering: "1.1")

= a2c-nums 示例

== int-to-cn-simple-num

#int-to-cn-simple-num(2024)

== int-to-cn-num 0-999

#{
  let i = 0;
  while i < 1000 {
    int-to-cn-num(i) + " "
    i += 1
  }
}

== others

#int-to-cn-num(2024)

#int-to-cn-num(987654321)

=== 一个0：

#int-to-cn-num(907654321)

#int-to-cn-num(907054321)

#int-to-cn-num(907050321)

#int-to-cn-num(907050301)

=== 两个0：

#int-to-cn-num(900654321)

#int-to-cn-num(980054321)

#int-to-cn-num(987004321)

#int-to-cn-num(987600321)

#int-to-cn-num(987650021)

#int-to-cn-num(987654001)

#int-to-cn-num(987654300)

=== 三个0：

#int-to-cn-num(900054321)

#int-to-cn-num(980004321)

#int-to-cn-num(987000321)

#int-to-cn-num(987600021)

#int-to-cn-num(987650001)

#int-to-cn-num(987654000)

=== 四个0：

#int-to-cn-num(900004321)

#int-to-cn-num(980000321)

#int-to-cn-num(987000021)

#int-to-cn-num(987600001)

#int-to-cn-num(987650000)

=== 五个0：

#int-to-cn-num(900000321)

#int-to-cn-num(980000021)

#int-to-cn-num(987000001)

#int-to-cn-num(987600000)

=== 六个0：

#int-to-cn-num(900000021)

#int-to-cn-num(980000001)

#int-to-cn-num(987000000)

=== 七个0：

#int-to-cn-num(900000001)

#int-to-cn-num(980000000)

=== 八个0：

#int-to-cn-num(900000000)

== int-to-cn-ancient-num

#int-to-cn-ancient-num(2024)

#{
  let i = 0;
  while i < 1000 {
    int-to-cn-ancient-num(i) + " "
    i += 1
  }
}

== num-to-cn-currency

#num-to-cn-currency(1234.56)

#num-to-cn-currency(0.5678)

#num-to-cn-currency(1203405602.5678)

#num-to-cn-currency(234)