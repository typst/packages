// Translations of every fixed text, one dictionary per language (`text.lang` code).
// To add a language, copy one of them, or pass it to the template with the `i18n` parameter.
#let i18n-default = (
  es: (
    // cover
    university: [UNIVERSIDAD DE SANTIAGO DE\ COMPOSTELA],
    school: [Escuela Técnica Superior de Ingeniería],
    degree: [Grado en Ingeniería Informática],
    author: [Autor/a:],
    tutors: [Tutores:],
    presented: [Trabajo de Fin de Grado presentado en la Escuela Técnica Superior de Ingeniería de la
      Universidad de Santiago de Compostela para la obtención del Grado en Ingeniería Informática],
    // certification page
    honorific: [D.],
    professor-of: [Profesor/a del],
    department: [Departamento de Electrónica y Computación],
    of-usc: [de la Universidad de Santiago de Compostela],
    conj: [, y ],
    report: [INFORMAN:],
    report-title: [Que la presente memoria, titulada],
    report-by: [presentada por],
    report-text: [para superar los créditos correspondientes al Trabajo de Fin de Grado de la titulación de
      Grado en Ingeniería Informática, se ha realizado bajo nuestra tutoría en el],
    report-end: [Y para que así conste a los efectos oportunos, expiden el presente informe en Santiago de
      Compostela, a],
    date-format: "[day padding:none] de [month-name] de [year]",
    // dates: names as written inside a sentence, used by `[month-name]` and `[weekday-name]`
    months: ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre",
      "noviembre", "diciembre"),
    weekdays: ("lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"),
    tutor: [Tutor/a,],
    cotutor: [Cotutor/a,],
    student: [Alumno/a,],
    // titles
    acknowledgements: [Agradecimientos],
    abstract: [Resumen],
    model: [Memoria tipo],
    contents: [Índice general],
    figures: [Índice de figuras],
    tables: [Índice de tablas],
    bibliography: [Bibliografía],
    // headings, captions and references
    chapter: [Capítulo],
    appendix: [Apéndice],
    section: [Sección],
    figure: [Figura],
    table: [Tabla],
    equation: [Ecuación],
    // CD cover
    tfg: [Trabajo de Fin de Grado],
    university-short: [Universidad de Santiago de Compostela],
    title: [Título:],
    cd-author: [Autor:],
    course: [Curso académico:],
    session: [Convocatoria:],
  ),
  gl: (
    // cover
    university: [UNIVERSIDADE DE SANTIAGO DE\ COMPOSTELA],
    school: [Escola Técnica Superior de Enxeñaría],
    degree: [Grao en Enxeñaría Informática],
    author: [Autor/a:],
    tutors: [Titores:],
    presented: [Traballo de Fin de Grao presentado na Escola Técnica Superior de Enxeñaría da Universidade
      de Santiago de Compostela para a obtención do Grao en Enxeñaría Informática],
    // certification page
    honorific: [D.],
    professor-of: [Profesor/a do],
    department: [Departamento de Electrónica e Computación],
    of-usc: [da Universidade de Santiago de Compostela],
    conj: [, e ],
    report: [INFORMAN:],
    report-title: [Que a presente memoria, titulada],
    report-by: [presentada por],
    report-text: [para superar os créditos correspondentes ao Traballo de Fin de Grao da titulación de
      Grao en Enxeñaría Informática, realizouse baixo nosa titoría no],
    report-end: [E para que así conste aos efectos oportunos, expiden o presente informe en Santiago de
      Compostela, a],
    date-format: "[day padding:none] de [month-name] de [year]",
    // dates: names as written inside a sentence, used by `[month-name]` and `[weekday-name]`
    months: ("xaneiro", "febreiro", "marzo", "abril", "maio", "xuño", "xullo", "agosto", "setembro", "outubro",
      "novembro", "decembro"),
    weekdays: ("luns", "martes", "mércores", "xoves", "venres", "sábado", "domingo"),
    tutor: [Titor/a,],
    cotutor: [Cotitor/a,],
    student: [Alumno/a,],
    // titles
    acknowledgements: [Agradecementos],
    abstract: [Resumo],
    model: [Memoria tipo],
    contents: [Índice xeral],
    figures: [Índice de figuras],
    tables: [Índice de cadros],
    bibliography: [Bibliografía],
    // headings, captions and references
    chapter: [Capítulo],
    appendix: [Apéndice],
    section: [Sección],
    figure: [Figura],
    table: [Cadro],
    equation: [Ecuación],
    // CD cover
    tfg: [Traballo de Fin de Grao],
    university-short: [Universidade de Santiago de Compostela],
    title: [Título:],
    cd-author: [Autor:],
    course: [Curso académico:],
    session: [Convocatoria:],
  ),
  en: (
    // cover
    university: [UNIVERSITY OF SANTIAGO DE\ COMPOSTELA],
    school: [Higher Technical School of Engineering],
    degree: [Bachelor's Degree in Computer Engineering],
    author: [Author:],
    tutors: [Supervisors:],
    presented: [Bachelor's Thesis submitted to the Higher Technical School of Engineering of the University
      of Santiago de Compostela for the Bachelor's Degree in Computer Engineering],
    // certification page
    honorific: none,
    professor-of: [Lecturer at the],
    department: [Department of Electronics and Computing],
    of-usc: [of the University of Santiago de Compostela],
    conj: [, and ],
    report: [CERTIFY:],
    report-title: [That this report, entitled],
    report-by: [submitted by],
    report-text: [to obtain the credits of the Bachelor's Thesis of the Bachelor's Degree in Computer
      Engineering, has been carried out under our supervision at the],
    report-end: [And for the record, we issue this report in Santiago de Compostela, on],
    date-format: "[month-name] [day padding:none], [year]",
    // dates: names as written inside a sentence, used by `[month-name]` and `[weekday-name]`
    months: ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
      "November", "December"),
    weekdays: ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),
    tutor: [Supervisor,],
    cotutor: [Co-supervisor,],
    student: [Student,],
    // titles
    acknowledgements: [Acknowledgements],
    abstract: [Abstract],
    model: [Report type],
    contents: [Contents],
    figures: [List of Figures],
    tables: [List of Tables],
    bibliography: [Bibliography],
    // headings, captions and references
    chapter: [Chapter],
    appendix: [Appendix],
    section: [Section],
    figure: [Figure],
    table: [Table],
    equation: [Equation],
    // CD cover
    tfg: [Bachelor's Thesis],
    university-short: [University of Santiago de Compostela],
    title: [Title:],
    cd-author: [Author:],
    course: [Academic year:],
    session: [Exam session:],
  ),
)

// Texts for `lang`: the defaults (English if the language is unknown) with the user's `i18n` on top
#let i18n-for(lang, i18n) = (:
  ..i18n-default.at(lang, default: i18n-default.en),
  ..i18n.at(lang, default: (:)),
)
