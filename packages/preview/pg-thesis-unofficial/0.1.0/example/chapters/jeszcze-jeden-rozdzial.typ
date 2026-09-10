#import "@local/pg-thesis-unofficial:0.1.0": ang

= Super rozdział <chap:super>

Mam tu jeszcze raz tabelę #ang[table], tym razem to tabela @tab:interakcja. Poprzednią tabelą była @tab:font_size - @chap:wstep[zob. rozdz.]

#figure(
  [
    #set text(size: 8pt)
    #table(
      columns: (1fr, 1fr),
      align: (left, left),
      align(center)[*Wnioski z~hipotezy Turinga*], align(center)[*Wnioski zaproponowane przez~Wegnera i~Goldin*],

      [Wszystkie problemy _obliczalne_ można rozwiązać za~pomocą funkcji.],
      [Wszystkie problemy _algorytmiczne_ można rozwiązać za~pomocą funkcji.],

      [Wszystkie problemy _obliczalne_ można opisać algorytmem.],
      [Wszystkie problemy _oparte na~funkcjach_ można opisać algorytmem.],

      [Algorytmy są tym, co~mogą wykonywać _dowolne komputery_.],
      [Algorytmy są tym, co~mogły wykonywać _wczesne_ komputery.],

      [Maszyna Turinga jest ogólnym modelem _dowolnych_ komputerów.],
      [Maszyna Turinga jest ogólnym modelem _wczesnych_ komputerów.],

      [Maszyna Turinga potrafi zasymulować _dowolny_ komputer.],
      [Maszyna Turinga potrafi zasymulować _dowolne urządzenie_ realizujące algorytmiczne obliczenia.],

      align(center + horizon)[
        #set text(size: 18pt)
        :(
      ],
      [Maszyna Turinga nie~potrafi rozwiązać każdego problemu obliczeniowego ani wykonać wszystkich operacji, które realizują _współczesne systemy_.],
    )
  ],
  caption: [Możliwości obliczeniowe współczesnych systemów],
) <tab:interakcja>

I może jeszcze logo:

#figure(
  image(
    "../assets/images/logo_pg.jpg",
    width: 30%,
  ),
  caption: [Oto logo PG],
) <fig:PD>


