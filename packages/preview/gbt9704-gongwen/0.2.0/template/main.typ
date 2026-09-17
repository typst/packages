// gbt9704-gongwen — 适配 GB/T 9704-2012 · 党政机关公文格式
// Quick start: typst init @preview/gbt9704-gongwen
// 快速开始：typst init @preview/gbt9704-gongwen

#import "@preview/gbt9704-gongwen:0.2.0": *

#show: gbt9704.with(
  redline: true,
  title-indent: true,
  // spacing-theme: "normal",   // "compact" | "normal" | "relaxed"
  // table-theme: "full-grid",  // "full-grid" | "three-line" | "single-line" | "plain"
  // table-align: "center",     // "center" | "left" | "right"
)

// Write your document content here ...
// 在此撰写公文内容 ...
