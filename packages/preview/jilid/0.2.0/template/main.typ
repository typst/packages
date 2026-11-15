#import "@preview/jilid:0.2.0": (
  appendix, frontmatter, jilid, signature, signatures,
)

#show: jilid.with(
  title: [Judul Laporan],
  kind: [Laporan Kerja Praktik],
  course: "Nama Mata Kuliah",
  lecturers: (name: "Nama Dosen, S.Kom., M.Kom.", id: "10000000000000000"),
  students: (
    (name: "Nama Mahasiswa", id: "1000000001"),
  ),
  program: "Teknik Informatika",
  faculty: "Teknik",
  university: "Universitas Negeri",
  year: "2026",
  bibliography: bibliography("refs.bib", style: "apa"),
  // Hapus tanda // di depan baris yang ingin dipakai.
  // logo: image("logo.png"),
  // cover-details: (([Mitra], [Nama Mitra]),),
  // typography: (font-family: "Times New Roman"),
  // margin: "print",
  // numbering: (position: "top"),
)

// Halaman depan muncul sebelum daftar isi, sesuai urutan penulisannya.
#frontmatter(title: [Lembar Pengesahan])[
  #v(1cm)
  #signatures(
    header: [Kota, 1 Januari 2026 \ Mengetahui,],
    signature(
      role: [Dosen Pembimbing],
      name: "Nama Dosen, S.Kom., M.Kom.",
      id: "10000000000000000",
    ),
    signature(
      role: [Mahasiswa],
      name: "Nama Mahasiswa",
      id-label: "NIM",
      id: "1000000001",
    ),
  )
]

// Dengan `label`, halaman ini bisa dirujuk dengan @abstrak.
#frontmatter(title: [Abstrak], label: <abstrak>)[
  Tulis ringkasan laporan dalam satu paragraf: masalah, metode, hasil, dan
  kesimpulan. Abstrak biasanya berisi 150 sampai 250 kata.

  *Kata kunci:* kata kunci satu, kata kunci dua, kata kunci tiga
]

#frontmatter(title: [Kata Pengantar])[
  Tulis ucapan syukur dan terima kasih kepada pihak yang membantu penyusunan
  laporan ini.

  #align(right)[Kota, 1 Januari 2026 \ Penulis]
]

// Bab ditulis dengan `=`, subbab dengan `==` dan `===`.
= Pendahuluan <bab-pendahuluan>

== Latar Belakang

Jelaskan masalah yang mendorong laporan ini dan alasan masalah itu penting.
Ringkasan laporan ada pada @abstrak.

== Rumusan Masalah

+ Tulis pertanyaan pertama yang ingin dijawab.
+ Tulis pertanyaan kedua yang ingin dijawab.

== Tujuan

Tulis tujuan yang menjawab setiap rumusan masalah.

== Manfaat

Tulis manfaat laporan ini bagi pembaca, instansi, atau penulis.

= Tinjauan Pustaka

Rangkum teori dan penelitian sebelumnya yang menjadi dasar laporan. Sitasi
ditulis dengan `@`, misalnya @einstein1905.

Rumus diberi nomor otomatis, seperti @persamaan-energi.

$ E = m c^2 $ <persamaan-energi>

= Metodologi

Jelaskan langkah kerja, alat, dan data yang dipakai.

// Diagram alur dibuat dengan paket fletcher: https://typst.app/universe/package/fletcher
// Paket ini ikut terhapus jika gambar ini dihapus.
#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, edge, node
    diagram(
      node-stroke: 0.6pt,
      spacing: 1.2em,
      node((0, 0), [Studi Literatur]),
      edge("-|>"),
      node((1, 0), [Pengumpulan Data]),
      edge("-|>"),
      node((2, 0), [Analisis]),
      edge("-|>"),
      node((3, 0), [Kesimpulan]),
    )
  },
  caption: [Diagram alur penelitian],
) <gambar-alur>

Alur penelitian ada pada @gambar-alur.

= Hasil dan Pembahasan

Sajikan hasil dan jelaskan artinya. Tabel diberi judul di atasnya, seperti
@tabel-hasil.

#figure(
  table(
    columns: 3,
    [*No*], [*Pengujian*], [*Hasil*],
    [1], [Pengujian pertama], [Berhasil],
    [2], [Pengujian kedua], [Berhasil],
  ),
  caption: [Hasil pengujian],
) <tabel-hasil>

#figure(
  ```python
  def halo(nama):
      return f"Halo, {nama}!"
  ```,
  caption: [Contoh kode program],
)

= Penutup

== Kesimpulan

Tulis jawaban singkat untuk setiap rumusan masalah pada @bab-pendahuluan.

== Saran

Tulis saran untuk penelitian atau pekerjaan berikutnya. Data lengkap ada pada
@lampiran-data.

// Lampiran muncul setelah daftar pustaka dan diberi nomor sesuai urutannya.
#appendix(title: [Data Pengujian], label: <lampiran-data>)[
  Lampirkan data mentah, kuesioner, atau dokumen pendukung.
]

#appendix(title: [Dokumentasi Kegiatan])[
  #figure(
    rect(width: 6cm, height: 3cm, fill: luma(230)),
    caption: [Foto kegiatan],
  )
]
