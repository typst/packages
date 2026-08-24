// =====================================================================
// bang-thong-ke.typ — BẢNG TẦN SỐ (THỐNG KÊ)
//
//   #import "bang-thong-ke.typ": *
//
// 4 loại bảng (bố cục NGANG — giá trị chạy theo cột, đúng kiểu SGK):
//   KHÔNG ghép nhóm, ĐƠN  -> bang-tan-so
//   KHÔNG ghép nhóm, ĐÔI  -> bang-tan-so-doi
//   CÓ  ghép nhóm,  ĐƠN   -> bang-ghep-nhom
//   CÓ  ghép nhóm,  ĐÔI   -> bang-ghep-nhom-doi
//
// "Biến đơn vị của giá trị dấu hiệu": tham số don-vi. Khi có, nhãn ô
// góc trên-trái hiện thành  «tên (đơn vị)», vd: Số tiền (nghìn đồng).
//
// Ghi chú chung:
//   gia-tri / tan-so : mảng nội dung hoặc số.
//   moc  : mảng mốc để TỰ tạo các khoảng ghép nhóm (n mốc -> n-1 khoảng).
//   nhom : thay cho moc nếu muốn tự truyền sẵn nội dung từng khoảng.
// =====================================================================

// Nhãn ô góc: gắn thêm (đơn vị) nếu có.
#let _nhan(ten, don-vi) = if don-vi == none { ten } else { [#ten] + [ (] + [#don-vi] + [)] }

// Một khoảng nửa mở/đóng, vd [35; 40). In-line, hợp gu SGK.
#let khoang(a, b, dong-trai: true, dong-phai: false) = {
  let tl = if dong-trai { "[" } else { "(" }
  let tr = if dong-phai { "]" } else { ")" }
  [#tl] + [#a] + [; ] + [#b] + [#tr]
}

// n mốc -> mảng n-1 khoảng [m0;m1), [m1;m2), ...
#let khoang-tu-moc(moc, dong-trai: true, dong-phai: false) = range(moc.len() - 1).map(
  i => khoang(moc.at(i), moc.at(i + 1), dong-trai: dong-trai, dong-phai: dong-phai),
)

// ------- LÕI DỰNG BẢNG -------
// nhan-gia-tri : nội dung ô góc trên-trái (nhãn hàng giá trị).
// gia-tri      : mảng nhãn các cột giá trị.
// hang         : mảng ((nhãn-hàng, mảng-số), ...) cho các dòng tần số.
#let _bang(
  nhan-gia-tri,
  gia-tri,
  hang,
  co-chu: 11pt,
  mau-vien: black,
  day-vien: 0.7pt,
  mau-tieu-de: none,   // tô nền cột nhãn (none = không tô)
  rong-nhan: auto,     // bề rộng cột nhãn bên trái
) = {
  let n = gia-tri.len()
  set text(size: co-chu)
  let o(x) = align(center + horizon, [#x])
  let nhan(x) = align(left + horizon, strong([#x]))

  let cells = ()
  // hàng tiêu đề: nhãn giá trị + các giá trị
  cells.push(if mau-tieu-de == none { nhan(nhan-gia-tri) } else {
    table.cell(fill: mau-tieu-de, nhan(nhan-gia-tri))
  })
  for v in gia-tri { cells.push(o(v)) }
  // các hàng tần số
  for hg in hang {
    let ten = hg.at(0)
    let mang = hg.at(1)
    cells.push(if mau-tieu-de == none { nhan(ten) } else {
      table.cell(fill: mau-tieu-de, nhan(ten))
    })
    for t in mang { cells.push(o(t)) }
  }

  table(
    columns: (rong-nhan,) + (auto,) * n,
    inset: (x: 8pt, y: 6pt),
    align: center + horizon,
    stroke: day-vien + mau-vien,
    ..cells,
  )
}

// ===================== KHÔNG GHÉP NHÓM =====================

// ĐƠN — một dòng tần số.
#let bang-tan-so(
  gia-tri: (),
  tan-so: (),
  ten-gia-tri: [Giá trị],
  ten-tan-so: [Tần số],
  don-vi: none,
  ..tuy-chon,
) = _bang(
  _nhan(ten-gia-tri, don-vi),
  gia-tri,
  ((ten-tan-so, tan-so),),
  ..tuy-chon,
)

// ĐÔI — hai dòng tần số (vd Nam / Nữ).
#let bang-tan-so-doi(
  gia-tri: (),
  tan-so-1: (),
  tan-so-2: (),
  ten-gia-tri: [Giá trị],
  ten-1: [Nhóm 1],
  ten-2: [Nhóm 2],
  don-vi: none,
  ..tuy-chon,
) = _bang(
  _nhan(ten-gia-tri, don-vi),
  gia-tri,
  ((ten-1, tan-so-1), (ten-2, tan-so-2)),
  ..tuy-chon,
)

// ======================= CÓ GHÉP NHÓM =======================

// ĐƠN — một dòng tần số. Truyền moc (mốc) hoặc nhom (khoảng sẵn).
#let bang-ghep-nhom(
  moc: none,
  nhom: none,
  tan-so: (),
  ten-nhom: [Nhóm],
  ten-tan-so: [Tần số],
  don-vi: none,
  dong-phai: false,   // khoảng cuối đóng phải?
  ..tuy-chon,
) = {
  let cac-khoang = if nhom != none { nhom } else { khoang-tu-moc(moc, dong-phai: dong-phai) }
  _bang(
    _nhan(ten-nhom, don-vi),
    cac-khoang,
    ((ten-tan-so, tan-so),),
    ..tuy-chon,
  )
}

// ĐÔI — hai dòng tần số trên cùng bộ khoảng.
#let bang-ghep-nhom-doi(
  moc: none,
  nhom: none,
  tan-so-1: (),
  tan-so-2: (),
  ten-nhom: [Nhóm],
  ten-1: [Nhóm 1],
  ten-2: [Nhóm 2],
  don-vi: none,
  dong-phai: false,
  ..tuy-chon,
) = {
  let cac-khoang = if nhom != none { nhom } else { khoang-tu-moc(moc, dong-phai: dong-phai) }
  _bang(
    _nhan(ten-nhom, don-vi),
    cac-khoang,
    ((ten-1, tan-so-1), (ten-2, tan-so-2)),
    ..tuy-chon,
  )
}
