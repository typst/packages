#import "@preview/jilid:0.1.0": (
  appendices, frontmatter, jilid, signature, signatures,
)

#show: jilid.with(
  title: [Judul Dokumen],
  kind: [Jenis Dokumen],
  course: "Nama Mata Kuliah",
  lecturers: (name: "Nama Dosen", id: "10000000000000000"),
  students: (
    (name: "Nama Mahasiswa", id: "1000000001"),
  ),
  program: "Teknik Informatika",
  faculty: "Teknik",
  university: "Universitas Negeri",
  year: "2026",
  // logo: image("logo.png"),
  // cover-details: (([Mitra Kolaborator:], [Nama Mitra]),),
  // typography: (font-family: "Times New Roman"),
  bibliography: bibliography("refs.bib", style: "apa"),
)

// Front matter is placed before the table of contents.
#frontmatter(title: [Lembar Pengesahan])[
  #v(1cm)
  #signatures(
    header: [Kota, 1 Januari 2026 \ Mengetahui,],
    signature(
      role: [Koordinator],
      name: "Nama Koordinator, S.T., M.Kom.",
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

#frontmatter(title: [Kata Pengantar])[
  #lorem(40)
]

= Pendahuluan <bab-pendahuluan>

== Latar Belakang

#lorem(60)

#figure(
  rect(width: 6cm, height: 3cm, fill: luma(230)),
  caption: [Contoh gambar],
) <gambar-contoh>

Lihat @gambar-contoh dan @tabel-contoh.

#figure(
  table(
    columns: 2,
    [*Kolom A*], [*Kolom B*],
    [1], [2],
  ),
  caption: [Contoh tabel],
) <tabel-contoh>

== Rumusan Masalah

#lorem(40)

= Tinjauan Pustaka

Contoh sitasi @einstein1905 dan rujukan ke @bab-pendahuluan.

#figure(
  ```python
  def halo(nama):
      return f"Halo, {nama}!"
  ```,
  caption: [Contoh kode],
)

#lorem(80)

// Appendices are placed after the bibliography.
#appendices[
  = Dokumentasi Kegiatan

  #lorem(30)
]


#appendices[
  = Dokumentasi Kegiatan 2


  #lorem(20)
]
