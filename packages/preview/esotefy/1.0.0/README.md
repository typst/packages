# Esotefy

> A compilation of esoteric languages including for now brainfuck

# Examples

## In pure brainfuck

```typst
#import "@preview/esotefy:1.0.0": brainf;

#brainf("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.");
```

Into

![image](https://media.discordapp.net/attachments/751591144919662752/1176988035309633647/image.png?ex=6570de86&is=655e6986&hm=60e18ac7187c117ab08a95c323f5059424342dbb9d8da49600c82502b5d14e7f&=&format=webp&width=328&height=102)

## With inputs

```typst
#import "@preview/esotefy:1.0.0": brainf;

#brainf("++++++++++++++[->,.<]", inp: "Goodbye World!");
```

Into

![image](https://media.discordapp.net/attachments/751591144919662752/1176988280613515366/image.png?ex=6570dec1&is=655e69c1&hm=f9285649f3e5ab72749af5820972c52827c727f6c52351b63d0bbd2ba9afce87&=&format=webp&width=808&height=181)

# Links
I've based my implementation from theses documents: 
- [Wikipedia](https://en.wikipedia.org/wiki/Brainfuck)
- [Github](https://github.com/sunjay/brainfuck)
- [A compiler of Brainfuck in c](https://onestepcode.com/brainfuck-compiler-c/)