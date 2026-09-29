// ================================================================
// SANG-MATH v2.0 — Bộ macro Toán THPT chuẩn
// Entry point: #import "@local/sang-math:2.0.0": *
// hoặc:        #import "@preview/sang-math:2.0.0": *  (sau khi publish)
// ================================================================

// ── Core modules (v1) ────────────────────────────────────────────
#import "bbt.typ": *            // BBT, Bảng biến thiên, Bảng xét dấu
#import "sang-exam.typ": *      // Trắc nghiệm, Tự luận, q-wrap...
#import "exam-templates.typ": * // Preset giao diện đề thi đẹp
#import "book-templates.typ": * // Preset giao diện sách, SGK, chuyên đề
#import "math-sym.typ": *       // Ký hiệu toán tắt (vô cùng, tập hợp...)
#import "geometry.typ": *       // Hình học phẳng/không gian CeTZ (legacy v1)

// ── Core utilities (v2) ──────────────────────────────────────────
#import "core/math-utils.typ": *  // linspace, lerp, rotate-2d, vec-*
#import "core/colors.typ": *      // sm-blue, sm-red, sm-green... (palette chuẩn)

// ── Geometry 2D (v2) ─────────────────────────────────────────────
#import "geometry-2d/conics.typ": *  // draw-parabola, draw-ellipse, draw-hyperbola

// ── Geometry 3D (v2) ─────────────────────────────────────────────
#import "geometry-3d/curves-3d.typ": *   // draw-helix, draw-spring, helix-points
#import "geometry-3d/revolution.typ": *  // draw-cylinder, draw-cone, draw-sphere
