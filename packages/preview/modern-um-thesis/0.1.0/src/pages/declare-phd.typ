/// Generate declaration page for PhD thesis
///
/// -> content
#let declare-phd(
  /// -> datetime
  date: none,
  /// Language of the thesis
  ///
  /// -> "en" | "zh" | "pt"
  lang: "en",
  /// Enable double-sided printing
  ///
  /// -> bool
  double-sided: false,
) = {
  pagebreak(
    weak: true,
    to: if double-sided { "odd" },
  )

  // if anonymous {
  //   return
  // }

  heading(level: 1, numbering: none)[
    #if lang == "en" {
      [Declaration]
    } else if lang == "zh" {
      [声明]
    } else if lang == "pt" {
      [Declaração]
    }]

  if lang == "en" {
    [
      I declare that the thesis here submitted is original except for the source materials
      explicitly acknowledged and that this thesis as a whole, or any part of this thesis
      has not been previously submitted for the same degree or for a different degree.\ \
      I also acknowledge that I have read and understood the Rules on Handling Student
      Academic Dishonesty and the Regulations of the Student Discipline of the
      University of Macau.
    ]
  } else if lang == "zh" {
    [
      本人所提交的論文，除了經清楚列明來源出處的資料外，其他內容均為原創；
      本論文的全部或部分未曾在同一學位或其他學位中提交過。\ \
      本人聲明已知悉及明白《澳門大學學生學術誠信處理規條》及《澳門大學學
      生紀律規章》。
    ]
  } else if lang == "pt" {
    [
      Declaro que a tese ora submetida é original, com excepção dos materiais
      bibliográficos citados, e que esta tese, na sua totalidade ou em parte, não foi
      submetida anteriormente para um grau idêntico ou diferente.\ \
      Declaro, igualmente, ter lido e compreendido as “Normas relativas à desonestidade
      académica dos estudantes da Universidade de Macau” e o “Regulamento
      disciplinar dos estudantes da Universidade de Macau”.
    ]
  }
}
