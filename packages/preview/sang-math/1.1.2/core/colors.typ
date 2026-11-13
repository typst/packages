// ═══════════════════════════════════════════════════════════════
// CORE / COLORS.TYP — Bảng màu chuẩn cho sang-math
// ═══════════════════════════════════════════════════════════════
// Đặt tên màu theo ngữ nghĩa thay vì hardcode hex.
// Dùng nhất quán trong toàn bộ package.
// ───────────────────────────────────────────────────────────────

// ── Màu Hình Học Chuẩn ────────────────────────────────────────
#let sm-blue       = rgb("1976D2")   // Điểm, đường chính
#let sm-blue-light = rgb("BBDEFB")   // Tô màu mặt phẳng
#let sm-green      = rgb("388E3C")   // Điểm thứ hai, kết quả
#let sm-green-light= rgb("C8E6C9")   // Tô màu vùng xanh
#let sm-red        = rgb("E91E63")   // Đường nổi bật, nghiệm
#let sm-red-light  = rgb("FCE4EC")   // Tô màu vùng đỏ
#let sm-orange     = rgb("F57C00")   // Đường phụ, điểm trung
#let sm-purple     = rgb("7B1FA2")   // Đường conic đặc biệt
#let sm-gray       = rgb("757575")   // Nét đứt, đường khuất
#let sm-gray-light = rgb("EEEEEE")   // Nền, fill nhạt

// ── Màu Khối 3D ───────────────────────────────────────────────
#let sm-face-top   = rgb("E3F2FD")   // Mặt trên khối
#let sm-face-front = rgb("BBDEFB")   // Mặt trước khối
#let sm-face-side  = rgb("90CAF9")   // Mặt bên khối
#let sm-face-dark  = rgb("64B5F6")   // Mặt tối/khuất

// ── Màu Giải Tích ─────────────────────────────────────────────
#let sm-func-1     = rgb("1565C0")   // Đường đồ thị hàm 1
#let sm-func-2     = rgb("C62828")   // Đường đồ thị hàm 2
#let sm-func-3     = rgb("2E7D32")   // Đường đồ thị hàm 3
#let sm-tangent    = rgb("FF8F00")   // Tiếp tuyến
#let sm-area       = rgb("E8F5E9")   // Tô diện tích tích phân
#let sm-area-stroke= rgb("43A047")   // Viền diện tích

// ── Màu Trắc Nghiệm ───────────────────────────────────────────
#let sm-correct    = rgb("388E3C")   // Đáp án đúng
#let sm-wrong      = rgb("D32F2F")   // Đáp án sai
#let sm-highlight  = rgb("FFF9C4")   // Highlight câu hỏi

// ── Màu Xác Suất / Thống Kê ───────────────────────────────────
#let sm-event-a    = rgb("1565C0")   // Biến cố A
#let sm-event-b    = rgb("C62828")   // Biến cố B
#let sm-event-ab   = rgb("6A1B9A")   // Giao AB
#let sm-tree-node  = rgb("E3F2FD")   // Nút sơ đồ cây

// ── Shorthand Palette (dùng cho hàm nhận color param) ─────────
// Cho phép gọi: draw-helix(color: sm.red)
#let sm = (
  blue:        sm-blue,
  blue-light:  sm-blue-light,
  green:       sm-green,
  green-light: sm-green-light,
  red:         sm-red,
  red-light:   sm-red-light,
  orange:      sm-orange,
  purple:      sm-purple,
  gray:        sm-gray,
  gray-light:  sm-gray-light,
)
