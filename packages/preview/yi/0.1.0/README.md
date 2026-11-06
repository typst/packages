一个灵活的工具来快速绘制周易中的卦象图（包括三爻卦和六爻卦），相比于直接输入字符，要更简单、更灵活、更美观。其只有一个函数`gua()`，可以将三位或六位的二进制数直接转化为卦象图，类似于字符直接插入文本中。

A flexible package to render and display [hexagram/I Ching](https://en.wikipedia.org/wiki/List_of_hexagrams_of_the_I_Ching) in Typst.

```typst
#import "@preview/yi:0.1.0"
#gua("110") + #gua("010") = #gua("010110") 水泽节
```

卦的二进制表示是自下而上的，0代表阴，1代表阳（非0）。
