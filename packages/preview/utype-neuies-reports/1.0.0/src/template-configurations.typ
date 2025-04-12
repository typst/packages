#import "/src/constants/drop-down-list-constants.typ": *
#import "/src/styles/common-document-style.typ": common-document-style
#import "/src/sections/01-front/inner-cover-page.typ": inner-cover-page
#import "/src/sections/thesis-front-section.typ": thesis-front-section
#import "/src/sections/thesis-main-section.typ": thesis-main-section
#import "/src/sections/thesis-back-section.typ": thesis-back-section
#import "/src/core/validation-manager/validation-manager.typ": validation-manager
#import "core/language-manager/language-manager.typ": init-language-manager

// Şablon ayarlarını giriniz. [Enter the template configurations.]\
/* __Resmî şablonlarda bulunan uyarılar: [Warnings in the official templates:]__\
  __Dikkat! [Attention!]__
  - Tezi yazmaya başlamadan önce Hazırlama Kılavuzu ve Şablon Kullanım Kılavuzu mutlaka okunmalıdır. [Before starting to write the thesis, the Preparation Guide and Template Usage Guide must be read.].\
  - İç kapaktaki gerekli bilgiler sayfa düzenini bozmadan ve bir sayfayı geçmeyecek biçimde yazılmalıdır. [The necessary information in the inside cover must be written in a way that does not disturb the page layout and does not pass a page.]\
  - YÖK tarafından yapılan son düzenlemede eski ve yeni Anabilim Dalı ve Bilim Dalı adlarında benzerlik olduğundan hata yapmamanız için öğrenci bilgi sisteminizde görünen Anabilim Dalını ve Bilim Dalını seçiniz. [Due to the similarity of the old and new Department of Science and New Department of Science names made by YÖK, please select the Department of Science and Science Department shown in your student information system.].\
  - Tez başlığı öğrenci bilgi sisteminde onaylanmış başlık ile aynı olmalıdır. [The thesis title must be the same as the approved title in the student information system.].\
  - Öğrenciye, danışmana ve ikinci danışmana ait ORCID numaralarını 1234-1234-1234-1234 düzeninde yazınız. [Write the ORCID numbers of the student, advisor and second advisor in the format 1234-1234-1234-1234.].\
  - ORIC numarası almak içim gerekli bilgilere web sayfamızdan ulaşabilirsiniz. https://www.erbakan.edu.tr/egitimbilimlerienstitusu/sayfa/10001 [You can access the necessary information from our web site to obtain the ORIC number. https://www.erbakan.edu.tr/egitimbilimlerienstitusu/sayfa/10001].\
  - İkinci danışman yok ise silinmelidir. [If there is no second advisor, it should be deleted.].\
  - Tez çalışması bir proje ile desteklenmiş ise yazılmalı, destek alınmamış ise silinmelidir. [If the thesis work is supported by a project, it should be written, if not, it should be deleted.].\
  - Birini kullanınız, diğerini siliniz. (ÖN SÖZ ya da TEŞEKKÜR) [Use one, delete the other. (PREFACE or ACKNOWLEDGMENT)].\
  - İçindekiler, hiçbir değişiklik yapılmaksızın tez metninde yer alan birinci, ikinci ve üçüncü düzey başlıkların tamamını içermeli, diğer başlıkları içermemelidir. [The table of contents must contain all the first, second and third level headings in the thesis text without any changes, and must not contain other headings.].\
  - Simgeler bulunmuyor ise bu sayfayı siliniz. [If there are no symbols, delete this page.].\
  - Kısaltmalar bulunmuyor ise bu sayfayı siliniz. [If there are no abbreviations, delete this page.].\
  - Özet metni ve anahtar kelimeler bir sayfayı aşmayacak şekilde 300-500 kelime içerecek şekilde yazılmalıdır. [The abstract text and keywords must be written in a way that does not exceed one page and contains 300-500 words.].\
  - Tez hazırlama kılavuzunda verilen açıklamaları dikkate alarak tezle ilgili en az üç, en fazla beş anahtar kelime yazılmalıdır. [According to the explanations given in the thesis preparation guide, at least three, but no more than five keywords related to the thesis should be written.].\
  - Birini kullanınız, diğerini siliniz (Sayıltılar ya da Varsayımlar). [Use one, delete the other. (Hypotheses or Assumptions)].\
  - Birini kullanınız, diğerini siliniz. (ALAN YAZIN ya da İLGİLİ ARAŞTIRMALAR)\
  - İkinci, üçüncü ve dördüncü düzey başlıklar örnek olarak verilmiştir. Bu başlıkları tez yazımına başlamadan önce siliniz. [The second, third and fourth level headings are given as examples. Delete these headings before starting to write the thesis.].\
  - Tablolarda mümkün olduğunca dikey çizgi kullanılmamalıdır. [Vertical lines should not be used in tables as much as possible.].\
  - Birini kullanınız, diğerlerini siliniz. (Araştırmanın Evreni ve Örneklemi ya da Araştırmanın Çalışma Grubu ya da Katılımcılar) [Use one, delete the others. (Research Population and Sample or Research Study Group or Participants)].\
  - Birini kullanınız, diğerini siliniz. Verilerin Çözümlenmesi ya da Verilerin Analizi)\
  - Tartışma, sonuç ve öneriler ayrı ayrı alt başlıklar altında verilebileceği gibi ana başlık altında ayrım yapılmadan da yazılabilir. [Discussion, conclusion and recommendations can be written separately under sub-headings or can be written without making a distinction under the main heading.].\
  - Genişletilmiş Türkçe Özet, yabancı dilde öğretim yapılan ve yabancı diller anabilim dalına bağlı programlarda, sadece yabancı dilde yazılması kabul edilmiş tezler için yazılacak olup, Türkçe yazılan tezlerde bu bölümü siliniz. [The extended Turkish abstract is written for the thesis written in foreign languages only in programs where foreign languages are taught and in foreign language departments, and is written in Turkish in the thesis written in Turkish. Delete this section in the thesis written in Turkish.].\
  - İş paketi sayısı, iş paketi tanımları ve tablodaki iş paketlerinin süreleri örnek olarak verilmiş olup, çalışmanıza uygun iş paketi adları ve süreleri yazılmalıdır. [The number of work packages, work package definitions and the durations of the work packages are given as examples, and the work package names and durations should be written according to your work.].\
  - Dönem projesinin hazırlanması teze benzemekle birlikte, ele alınan konunun gerekleri doğrultusunda Bölüm 1, 2, 3, 4 ve 5’ten hangilerini içereceği ve bunların içeriği danışmanın yapacağı yönlendirmeye göre belirlenir. [Although the preparation of the term project resembles the thesis, the contents of Sections 1, 2, 3, 4 and 5 are determined according to the requirements of the topic to be dealt with and the guidance to be made by the advisor.].
*/
#let template-configurations(
  // Raporun dilini seçiniz. [Select the language of the report.]
  language: LANGUAGES.TR-TR,
  // Ana Bilim Dalını seçiniz. [Select the department.]
  department: DEPARTMENTS.__DEPARTMENT-PLACE-HOLDER,
  // Bilim Dalını seçiniz. [Select the program.]
  program: PROGRAMS.__PROGRAM-PLACE-HOLDER,
  // Raporun türünü seçiniz. [Select the report type.]
  report-type: REPORT-TYPES.MASTER-THESIS-PROPOSAL,
  // Tez önerisi ya da tezin teslim edildiği tarih. Varsayılan olarak bugünün tarihidir. Elle bir tarih girmek için "datetime(day: 20, month: 3, year: 2025)" yapınız. [The date of the thesis proposal or the date of the thesis delivery. The default is today's date. To enter a date manually, do "datetime(day: 20, month: 3, year: 2025)".]
  date: datetime.today(),
  // Raporun Türkçe ve İngilizce başlığı (başlık ve hepsi büyük harf biçiminde). [The Turkish and English title of the report (titlecase and uppercase).]
  report-title: (
    tur: (
      title-case: "Report Title",
      upper-case: "REPORT TITLE",
    ),
    eng: (
      title-case: "Report English Title",
      upper-case: "REPORT ENGLISH TITLE",
    ),
  ),
  // Yazarın (Öğrencinin) adı, soyadı ve ORCID numarası. [The author's (student's) name, lastname and ORCID number.]
  author: (
    first-name: "Student's Firstname",
    last-name: "LASTNAME",
    orcid: "1234-1234-1234-1234",
  ),
  // Danışmanın adı, soyadı ve ORCID numarası. [The advisor's name, lastname and ORCID number.]
  advisor: (
    academic-member-title: ACADEMIC-MEMBER-TITLES.__ACADEMIC-MEMBER-TITLE-PLACE-HOLDER,
    first-name: "Advisor's Firstname",
    last-name: "LASTNAME",
    orcid: "1234-1234-1234-1234",
  ),
  // İkinci danışmanın adı, soyadı ve ORCID numarası. İkinci danışman yoksa "second-advisor: none" yapınız. [The second advisor's name, lastname and ORCID number. If there is no second advisor, do "second-advisor: none".]
  second-advisor: (
    academic-member-title: ACADEMIC-MEMBER-TITLES.__ACADEMIC-MEMBER-TITLE-PLACE-HOLDER,
    first-name: "Second Advisor's Firstname",
    last-name: "LASTNAME",
    orcid: "1234-1234-1234-1234",
  ),
  // Tez çalışmasını destekleyen kuruluşun adı ve projenin numarası. Tez çalışmasını destekleyen herhangi bir kuruluş yoksa "thesis-study-funding-organization: none" yapınız. [The name and project number of the organization supporting the thesis study. If there is no organization supporting the thesis study, do "thesis-study-funding-organization: none".]
  thesis-study-funding-organization: (
    name: "Name of the Funding Organization Supporting the Thesis Study",
    project-no: "Project No",
  ),
  // Tez çalışmasının orijinallik bilgisi. Örneğin Turnitin yazılımında tezin 78 sayfası taratıldı ve benzerlik oranı %17 ise "included-page-count: 78" ve "similarity-score: 17" şeklindedir. [The originality information of the thesis study. For example, if the thesis has 78 pages scanned in the Turnitin software and the similarity score is %17, it is "included-page-count: 78" and "similarity-score: 17".]
  thesis-originalty: (
    included-page-count: 1,
    similarity-score: 0,
  ),
  // Raporun Türkçe ve İngilizce anahtar kelimeleri. Anahtar kelimelerin ilk harfi büyük diğer harfleri küçük olmalıdır. En az 3 adet ve en fazla 5 adet olmalıdır. [The Turkish and English keywords of the report. The first letter of the keywords must be uppercase and the other letters must be lowercase. There must be at least 3 and at most 5 keywords.]
  keywords: (
    tur: (
      "Anahtar kelime 1",
      "Anahtar kelime 2",
      "Anahtar kelime 3",
      "Anahtar kelime 4",
      "Anahtar kelime 5",
    ),
    eng: (
      "Keyword 1",
      "Keyword 2",
      "Keyword 3",
      "Keyword 4",
      "Keyword 5",
    ),
  ),
  // Tablo figürleri listesinin raporda yer almasını istiyorsanız "show-list-of-table-figures: true", istemiyorsanız "show-list-of-table-figures: false" yapınız. [If you want the list of table figures to be included in the report, do “show-list-of-table-figures: true”, if not, do “show-list-of-table-figures: false”.]
  show-list-of-table-figures: true,
  // Şekil figürleri listesinin raporda yer almasını istiyorsanız "show-list-of-image-figures: true", istemiyorsanız "show-list-of-image-figures: false" yapınız. [If you want the list of image figures to be included in the report, do show-list-of-image-figures: true”, if not, do show-list-of-image-figures: false”.]
  show-list-of-image-figures: true,
  // Matematiksel Denklemler listesinin raporda yer almasını istiyorsanız "show-list-of-math-equations: true", istemiyorsanız "show-list-of-math-equations: false" yapınız. [If you want the list of equations to be included in the report, do "show-list-of-math-equations: true", if not, do "show-list-of-math-equations: false".]
  show-list-of-math-equations: true,
  // Kod figürleri listesinin raporda yer almasını istiyorsanız "show-list-of-code-figures: true", istemiyorsanız "show-list-of-code-figures: false" yapınız. [If you want the list of code figures to be included in the report, do "show-list-of-code-figures: true", if not, do "show-list-of-code-figures: false".]
  show-list-of-code-figures: true,
  // Raporda simgeler kullandıysanız "Simgeler" başlığındaki içeriğin rapora dahil edilmesi için "have-symbols: true" yapınız. Ancak, tez önerisi ise "true" ya da "false" olsa bile "Simgeler ve Kısaltmalar" başlığındaki içerik rapora dahil edilmeyecektir. [To include the content of the "Symbols" heading in the report, do "have-symbols: true". However, if the thesis proposal is "true" or "false", the content of the "Symbols and Abbreviations" heading will not be included in the report.]
  have-symbols: true,
  // Raporda kısaltmalar kullandıysanız "Kısaltmalar" başlığındaki içeriğin rapora dahil edilmesi için "have-symbols: true" yapınız. Ancak, tez önerisi ise "true" ya da "false" olsa bile "Simgeler ve Kısaltmalar" başlığındaki içerik rapora dahil edilmeyecektir. [To include the content of the "Abbreviations" heading in the report, do "have-abbreviations: true". However, if the thesis proposal is "true" or "false", the content of the "Symbols and Abbreviations" heading will not be included in the report.]
  have-abbreviations: true,
  // Dönem projesinde "Giriş" başlığının teze dahil edilmesi için "have-introduction-in-term-project: true" yapınız. [To include the "Introduction" heading in the term project, do "have-introduction-in-term-project: true".]
  have-introduction-in-term-project: true,
  // Dönem projesinde "Alan Yazın (İlgili Araştırmalar)" başlığının teze dahil edilmesi için "have-literature-review-in-term-project: true" yapınız. [To include the "Literature Review" heading in the term project, do "have-literature-review-in-term-project: true".]
  have-literature-review-in-term-project: true,
  // Dönem projesinde "Yöntem" başlığının teze dahil edilmesi için "have-methodology-in-term-project: true" yapınız. [To include the "Methodology" heading in the term project, do "have-methodology-in-term-project: true".]
  have-methodology-in-term-project: true,
  // Dönem projesinde "Bulgular" başlığının teze dahil edilmesi için "have-findings-in-term-project: true" yapınız. [To include the "Findings" heading in the term project, do "have-findings-in-term-project: true".]
  have-findings-in-term-project: true,
  // Dönem projesinde "Tartışma, Sonuç ve Öneriler" başlığının teze dahil edilmesi için "have-discussion-conclusion-and-suggestions-in-term-project: true" yapınız. [To include the "Discussion, Conclusion and Suggestions" heading in the term project, do "have-discussion-conclusion-and-suggestions-in-term-project: true".]
  have-discussion-conclusion-and-suggestions-in-term-project: true,
  // Tartışma, Sonuç ve Öneriler bölümünü alt başlıklara ayırarak yazmak istiyorsanız "show-separate-sub-headings-in-discussion-conclusion-and-suggestions: true", alt başlıklar olmadan ana başlık altında yazmak istiyorsanız "show-separate-sub-headings-in-discussion-conclusion-and-suggestions: false" yapınız. [To write the Discussion, Conclusion and Suggestions section in subheadings, do "show-separate-sub-headings-in-discussion-conclusion-and-suggestions: true". To write the section in the main heading without subheadings, do "show-separate-sub-headings-in-discussion-conclusion-and-suggestions: false".]
  show-separated-sub-headings-in-discussion-conclusion-and-suggestions: true,
  // Tez Önerisinde yer alan "Çalışma Takvimi" sayfasındaki "Çalışma Paketleri" kısmını doldurmak için her bir iş paketinizin açıklamasını ve hangi aylarda yapılacağını belirtiniz. Yüksek Lisans Tez Önerisi ise 12 aylık bir süre, Doktora Tez Önerisi ise 16 aylık bir süre için doldurulmalıdır. Yalnızca "report-type: REPORT-TYPES.MASTER-THESIS-PROPOSAL" ya da report-type: REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL" olduğunda raporda gözükecektir. [To fill in the "Work Packages" section of the "Work Schedule" page of the thesis proposal, specify the description of each work package and when it will be done. The Master's thesis proposal is for 12 months and the doctoral thesis proposal is for 16 months. It will only appear in the report when report-type: REPORT-TYPES.MASTER-THESIS-PROPOSAL or report-type: REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL.]
  work-packages: (
    (
      // İş paketinin açıklaması. [The description of the work package.]
      description: "Description 1",
      // İş paketinin yapılacağı aylar. [The months when the work package will be done.]
      months: (1, 2),
    ),
    (
      description: "Description 2",
      months: (2, 3, 4, 5),
    ),
    (
      description: "Description 3",
      months: (5, 6, 7),
    ),
    (
      description: "Description 4",
      months: (7, 8, 9),
    ),
    (
      description: "Description 5",
      months: (9, 10, 11, 12),
    ),
  ),
  // Dönem Projesinin sonunda yer alan "Öz Geçmiş" sayfasında yer alan bilgilerdir. Yalnızca "report-type: REPORT-TYPES.TERM-PROJECT" olduğunda gözükecektir, diğer durumlarda doldurulmasına gerek yoktur. [Information in the "Curriculum Vitae" page at the end of the term project. It will only appear when report-type: REPORT-TYPES.TERM-PROJECT, otherwise it does not need to be filled.]
  curriculum-vitae-info: (
    birthplace: "Konya",
    birthday: datetime.today(),
    address: "Adress",
    marital-status: "Single/Married",
    phone-number: "+90 555 55 55",
    email: "email@mail.com",
    high-school: (
      name: "High School Name",
      program: "Mathematics-Science",
      place: "Konya",
      start-year: 2025,
    ),
    undergraduate: (
      name: "Undergraduate - University Name",
      program: "Elementary School Teacher",
      place: "Konya",
      start-year: 2029,
    ),
    masters-degree: (
      name: "Master's Degree - University Name",
      program: "Mathematics Education",
      place: "Konya",
      start-year: 2032,
    ),
    skills: (
      "Skill 1",
      "Skill 2",
    ),
    // İş deneyimlerinizi geçmişten günümüze doğru sırayla giriniz. Otomatik olarak sıralanıyor ancak kod ile çıktı arasındaki uyumu sağlayarak daha okunur bir kod yazabilirsiniz. [Enter your work experiences in order from the past to the present. It is automatically sorted, but you can write more readable code by ensuring the consistency between the code and the output.]
    work-experiences: (
      (
        start-date: datetime(day: 1, month: 3, year: 2030),
        end-date: datetime(day: 1, month: 6, year: 2033),
        title: "Title/Job",
        organization-name: "Organization Name that you worked",
        place: "Konya",
      ),
      (
        start-date: datetime(day: 1, month: 7, year: 2033),
        end-date: datetime(day: 1, month: 3, year: 2037),
        title: "Title/Job",
        organization-name: "Organization Name that you worked",
        place: "Konya",
      ),
    ),
    // Hakkınızda bilgi alabilecekleri önerebileceğiniz şahısların bilgilerini giriniz. [Enter the information of the people who can provide information about you.]
    get-info-from-recommended-peoples: (
      (
        title: ACADEMIC-MEMBER-TITLES.__ACADEMIC-MEMBER-TITLE-PLACE-HOLDER,
        first-name: "Firstname",
        last-name: "LASTNAME",
        orcid: "1234-1234-1234-1234",
        email: "email@mail.com",
      ),
      (
        title: ACADEMIC-MEMBER-TITLES.__ACADEMIC-MEMBER-TITLE-PLACE-HOLDER,
        first-name: "Firstname",
        last-name: "LASTNAME",
        orcid: "1234-1234-1234-1234",
        email: "email@mail.com",
      ),
    ),
  ),
  body,
) = {
  /* ---- Doğrulama İşlemlerini Başlat [Initialize Validation Process] ---- */
  validation-manager(
    language: language,
    department: department,
    program: program,
    report-type: report-type,
    date: date,
    report-title: report-title,
    author: author,
    advisor: advisor,
    second-advisor: second-advisor,
    thesis-study-funding-organization: thesis-study-funding-organization,
    thesis-originalty: thesis-originalty,
    keywords: keywords,
    show-list-of-table-figures: show-list-of-table-figures,
    show-list-of-image-figures: show-list-of-image-figures,
    show-list-of-math-equations: show-list-of-math-equations,
    show-list-of-code-figures: show-list-of-code-figures,
    have-symbols: have-symbols,
    have-abbreviations: have-abbreviations,
    have-introduction-in-term-project: have-introduction-in-term-project,
    have-literature-review-in-term-project: have-literature-review-in-term-project,
    have-methodology-in-term-project: have-methodology-in-term-project,
    have-findings-in-term-project: have-findings-in-term-project,
    have-discussion-conclusion-and-suggestions-in-term-project: have-discussion-conclusion-and-suggestions-in-term-project,
    show-separated-sub-headings-in-discussion-conclusion-and-suggestions: show-separated-sub-headings-in-discussion-conclusion-and-suggestions,
    work-packages: work-packages,
    curriculum-vitae-info: curriculum-vitae-info,
  )

  /* ---- Dil Yöneticisini Başlat [Initialize the Language Manager] ---- */
  init-language-manager(default-language: language.language-code)

  /* ---- Ortak Döküman Stili [Common Document Style] ---- */
  show: common-document-style.with(
    language: language,
    report-title: report-title,
    author: author,
    keywords: keywords,
  )

  /* --- BAŞLIK SAYFASI [TITLE PAGE] --- */
  inner-cover-page(
    language: language,
    department: department,
    program: program,
    report-type: report-type,
    date: date,
    report-title: report-title,
    author: author,
    advisor: advisor,
    second-advisor: second-advisor,
    thesis-study-funding-organization: thesis-study-funding-organization,
  )

  /* ---- TEZİN ÖN KISMI [FRONT SECTION OF THESIS] ---- */
  thesis-front-section(
    department: department,
    program: program,
    report-type: report-type,
    date: date,
    report-title: report-title,
    author: author,
    advisor: advisor,
    thesis-originalty: thesis-originalty,
    keywords: keywords,
    show-list-of-table-figures: show-list-of-table-figures,
    show-list-of-image-figures: show-list-of-image-figures,
    show-list-of-math-equations: show-list-of-math-equations,
    show-list-of-code-figures: show-list-of-code-figures,
    have-symbols: have-symbols,
    have-abbreviations: have-abbreviations,
  )

  /* ---- TEZİN ANA KISMI [MAIN SECTION OF THESIS] ---- */
  thesis-main-section(
    report-type: report-type,
    have-introduction-in-term-project: have-introduction-in-term-project,
    have-literature-review-in-term-project: have-literature-review-in-term-project,
    have-methodology-in-term-project: have-methodology-in-term-project,
    have-findings-in-term-project: have-findings-in-term-project,
    have-discussion-conclusion-and-suggestions-in-term-project: have-discussion-conclusion-and-suggestions-in-term-project,
    show-separated-sub-headings-in-discussion-conclusion-and-suggestions: show-separated-sub-headings-in-discussion-conclusion-and-suggestions,
  )

  /* ---- TEZİN ARKA KISMI [BACK SECTION OF THESIS] ---- */
  thesis-back-section(
    language: language,
    department: department,
    program: program,
    report-type: report-type,
    report-title: report-title,
    author: author,
    work-packages: work-packages,
    curriculum-vitae-info: curriculum-vitae-info,
  )

  // Gövdeyi pasif hale getir. [Disable the body.]
  //body
}
