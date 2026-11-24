# thaibreak

Natural Thai word segmentation and typographic line breaking for [Typst](https://typst.app/), powered by [`kamthorn/thai-break`](https://github.com/kamthorn/thai-break) (Rust core with dictionary prefix trie).

## Features

- **Dictionary-based Word Segmentation:** Accurate Thai word boundaries using a curated dictionary trie. Avoids common machine-learning LSTM segmentation failures on technical terms and compound words.
- **Atomic Word Protection (`mode: "box"`):** Wraps words in atomic inline boxes to strictly prevent upstream line breakers from splitting Thai words or tone marks mid-word.
- **Zero-Width Space Mode (`mode: "zwsp"`):** Inserts Unicode zero-width space (`U+200B`) at word boundaries for lightweight line-breaking while preserving clean text.
- **WASM Minimal Protocol:** Zero external runtime dependencies; executes self-contained WebAssembly inside Typst compiler.

## Usage

### Simple Document Show Rule

```typ
#import "@preview/thaibreak:0.1.0": thai-break

#show: thai-break

บูรณาการมวลชนลงทุนล้ำสมัยต้นแบบ ทั้งนี้ของบูรณาการสำคัญข้อความ
พลเมืองจริยธรรมต้นแบบสำเร็จ กระแสโลกาภิวัฒน์หลากหลายนวัตกรรมนวัตกรรมบริหาร
```

### Options

```typ
#import "@preview/thaibreak:0.1.0": thai-break

// Mode "box" (default): wraps each Thai word in box()
#show: thai-break.with(mode: "box")

// Mode "zwsp": inserts zero-width space U+200B at word boundaries
#show: thai-break.with(mode: "zwsp")
```

### Direct Functions

```typ
#import "@preview/thaibreak:0.1.0": segment-words, break-lines

#let words = segment-words("ฉันรักภาษาไทย")
// => ("ฉัน", "รัก", "ภาษา", "ไทย")

#let broken = break-lines("ฉันรักภาษาไทย", marker: "|")
// => "ฉัน|รัก|ภาษา|ไทย"
```

## License

Apache-2.0
