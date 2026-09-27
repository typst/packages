// =====================================================================
// so-do-cay.typ — SƠ ĐỒ CÂY (bài toán xác suất, đếm...)
// Cây tổng quát, sâu tuỳ ý. Mỗi nút là ô bo tròn, cạnh có nhãn xác suất,
// nút lá có thể kèm ô KẾT QUẢ (cột phải cùng hàng).
//
//   #so-do-cay(
//     goc: $1$,
//     nhanh: (
//       nut($A$, xs: $1/6$, con: (
//         nut($B$, xs: $1/2$, kq: $A B: 1/12$),
//         nut($overline(B)$, xs: $1/2$, kq: $A overline(B): 1/12$),
//       )),
//       nut($overline(A)$, xs: $5/6$, con: (
//         nut($B$, xs: $1/3$, kq: $overline(A) B: 5/18$),
//         nut($overline(B)$, xs: $2/3$, kq: $overline(A) overline(B): 5/9$),
//       )),
//     ),
//   )
// =====================================================================
#import "ve.typ": *

// Một nút: ten (nội dung ô), xs (nhãn trên cạnh đi tới nút),
// kq (ô kết quả bên phải — thường dùng cho nút lá), con (mảng nút con),
// mau (màu nền ô; auto = theo cấp).
#let nut(ten, xs: none, kq: none, con: (), mau: auto) = (
  ten: ten, xs: xs, kq: kq, con: con, mau: mau,
)

// Ô chữ bo tròn đặt tâm tại P (toạ độ toán).
// Kích thước ô lấy theo max(khung, biên nét chữ): công thức trong dòng như
// $1/6$ bị Typst tính hụt chiều cao khung nên nếu chỉ đo khung thì phân số
// sẽ thò ra ngoài ô (xem `co-net` trong ve.typ).
#let o-bo-tron(ctx, P, nd, to: white, vien: auto, dem-x: 8pt, dem-y: 5pt, bk: 5pt, day: 0.8pt) = context {
  let s = measure(nd)
  let b = co-net(nd)
  let sw = calc.max(s.width, b.width)
  let sh = calc.max(s.height, b.height)
  let p = toa(ctx, P)
  let v = if vien == auto { to.darken(35%) } else { vien }
  place(
    dx: p.at(0) - sw / 2 - dem-x,
    dy: p.at(1) - sh / 2 - dem-y,
    rect(
      width: sw + 2 * dem-x, height: sh + 2 * dem-y,
      radius: bk, fill: to, stroke: day + v,
    ),
  )
  place(dx: p.at(0) - s.width / 2, dy: p.at(1) - s.height / 2, nd)
}

// ---------- duyệt cây (nội bộ) ----------
#let _la-so(n) = if n.con.len() == 0 { 1 } else { n.con.map(_la-so).sum() }
#let _sau-max(n) = if n.con.len() == 0 { 0 } else { 1 + calc.max(..n.con.map(_sau-max)) }

// Trả về (y: tung độ tâm, cuoi: y0 còn lại, nut/canh/kq: dữ liệu vẽ).
#let _duyet(n, sau, y0) = {
  if n.con.len() == 0 {
    (y: y0 - 0.5, cuoi: y0 - 1, nut: (), canh: (), kq: ())
  } else {
    let yc = y0
    let nuts = ()
    let canhs = ()
    let kqs = ()
    let ys = ()
    for c in n.con {
      let r = _duyet(c, sau + 1, yc)
      yc = r.cuoi
      ys.push(r.y)
      nuts += r.nut
      canhs += r.canh
      kqs += r.kq
      nuts.push((P: (sau + 1, r.y), nd: c.ten, sau: sau + 1, mau: c.mau))
      if c.kq != none { kqs.push((y: r.y, nd: c.kq)) }
    }
    let y = (ys.first() + ys.last()) / 2
    for (i, c) in n.con.enumerate() {
      canhs.push((A: (sau, y), B: (sau + 1, ys.at(i)), xs: c.xs))
    }
    (y: y, cuoi: yc, nut: nuts, canh: canhs, kq: kqs)
  }
}

#let so-do-cay(
  goc: $1$,
  nhanh: (),               // mảng nut(...) cấp 1
  w: 11.5cm,
  cao-hang: 1.5cm,         // khoảng cách dọc giữa hai lá kề nhau
  cach-kq: 0.55,           // cột kết quả cách cột lá (đơn vị cột)
  mau-cap: (rgb("#cfe9f5"), rgb("#dcd7f5"), rgb("#d5eed5"), rgb("#fdeacd")),
  mau-kq: rgb("#fdecec"), vien-kq: rgb("#e08a8a"),
  mau-canh: black, day-canh: 0.9pt,
  co-chu: 10pt,
  dem-x: 8pt, dem-y: 5pt,  // đệm trong của ô
  them: none,              // ctx => vẽ thêm
) = {
  let root = nut(goc, con: nhanh)
  let L = _la-so(root)
  let D = _sau-max(root)
  let r = _duyet(root, 0, L)
  let cac-nut = r.nut + ((P: (0, r.y), nd: root.ten, sau: 0, mau: root.mau),)
  let co-kq = r.kq.len() > 0
  let xkq = D + cach-kq
  let xmax = if co-kq { xkq + 1.0 } else { D + 0.55 }
  hinh(
    w: w, h: cao-hang * L,
    xmin: -0.55, xmax: xmax, ymin: 0, ymax: L,
    co-chu: co-chu,
    ctx => context {
      // cạnh + nhãn xác suất (đầu mút lùi vào theo bề rộng ô đã đo)
      for c in r.canh {
        let ncha = cac-nut.find(k => k.P == c.A)
        let ncon = cac-nut.find(k => k.P == c.B)
        let wa = if ncha != none { measure(ncha.nd).width / 2 + dem-x + 3pt } else { 0pt }
        let wb = if ncon != none { measure(ncon.nd).width / 2 + dem-x + 3pt } else { 0pt }
        let pa = toa-pt(ctx, c.A)
        let pb = toa-pt(ctx, c.B)
        let A2 = toa-nguoc(ctx, (pa.at(0) + wa.pt(), pa.at(1)))
        let B2 = toa-nguoc(ctx, (pb.at(0) - wb.pt(), pb.at(1)))
        mui-ten(ctx, A2, B2, mau: mau-canh, day: day-canh, kich: 6pt)
        if c.xs != none {
          nhan(
            ctx, trung-diem(A2, B2), c.xs,
            huong: "above", cach: 3pt, quay: goc-truc(ctx, A2, B2),
          )
        }
      }
      // các ô nút
      for k in cac-nut {
        let to = if k.mau == auto { mau-cap.at(calc.rem(k.sau, mau-cap.len())) } else { k.mau }
        o-bo-tron(ctx, k.P, k.nd, to: to, dem-x: dem-x, dem-y: dem-y)
      }
      // cột kết quả
      for q in r.kq {
        let s = measure(q.nd)
        let b = co-net(q.nd)
        let sw = calc.max(s.width, b.width)
        let sh = calc.max(s.height, b.height)
        let p = toa(ctx, (xkq, q.y))
        place(
          dx: p.at(0), dy: p.at(1) - sh / 2 - dem-y,
          rect(
            width: sw + 2.4 * dem-x, height: sh + 2 * dem-y,
            radius: 5pt, fill: mau-kq, stroke: 0.8pt + vien-kq,
          ),
        )
        place(dx: p.at(0) + 1.2 * dem-x, dy: p.at(1) - s.height / 2, q.nd)
      }
      if them != none { them(ctx) }
    },
  )
}
