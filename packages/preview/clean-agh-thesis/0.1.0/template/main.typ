#import "@preview/clean-agh-thesis:0.1.0": agh

#show: agh.with(
  titles: ("Klasyfikacja wybranych komórek szpiku kostnego na podstawie zdjęć rozmazów przy użyciu algorytmu opartego na splotowych sieciach neuronowych", "Classification of selected bone marrow cells from smear images using convolutional neural networks"),
  department: "Wydział Elektrotechniki, Automatyki, Informatyki i Inżynierii Biomedycznej",
  author: "Mateusz Woźniak",
  supervisor: "dr hab. inż. Tomasz Hachaj",
  course: "Informatyka i Systemy Inteligentne",
  acknowledgements: (
    "Dziękuję moim rodzicom, którzy zawsze wspierają mnie w moich decyzjach.",
    "Dziękuję moim kolegom i koleżankom, którzy pomogli mi w realizacji tego projektu.",
  ),
  masters: false,
  bibliography: bibliography("refs.bib", title: "Bibliografia"),
)

= Wstęp
== Wprowadzenie

Rozwój technologii informatycznych, w szczególności uczenia maszynowego, otwiera nowe możliwości w wielu dziedzinach nauki i przemysłu.
Jednym z obszarów życia, w którym te technologie mogą odnieść duży sukces, jest medycyna.
Zastosowanie komputerów do analizy danych medycznych może wpłynąć pozytywnie na proces leczenia wielu chorób.
Sztuczna inteligencja daje możliwość zautomatyzowania czasochłonnych zadań w diagnostyce i zaoszczędzenia wielu godzin pracy lekarza diagnosty.

Celem niniejszej pracy jest zastosowanie splotowych sieci neuronowych do klasyfikacji komórek szpiku kostnego na podstawie zdjęć rozmazów @dataset.
Wykorzystanie tej technologii może znacznie przyspieszyć i ułatwić proces diagnozy, co jest kluczowe dla skutecznego leczenia wielu chorób takich jak na przykład nowotwory krwi.

= Podstawy teoretyczne

Podstawowym elementem sieci neuronowych jest neuron, który jest elementem obliczeniowym, który przyjmuje sygnały wejściowe, przetwarza je i generuje sygnał wyjściowy.