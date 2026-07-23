// ================================================================
// CONICTYPST — Bộ macro Toán THPT chuẩn
// ================================================================

// ── Core modules ─────────────────────────────────────────────────
#import "bbt.typ": *         // BBT, Bảng biến thiên, Bảng xét dấu
#import "sang-exam.typ": *   // Trắc nghiệm, Tự luận, q-wrap...
#import "math-sym.typ": *    // Ký hiệu toán tắt (vô cùng, tập hợp...)
#import "geometry.typ": *    // Hình học phẳng/không gian CeTZ
#import "print-layouts.typ": * // Layout 70/30, nháp đảo bên khi in hai mặt

// ── Additional modules ───────────────────────────────────────────
#import "sang-book.typ" as book     // Chuyên đề, Sách (smartbox, theorem...)
#import "sang-beamer.typ" as beamer // Beamer presentation (slide, make-questions)
