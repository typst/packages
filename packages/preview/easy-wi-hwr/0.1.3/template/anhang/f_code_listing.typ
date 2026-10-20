// anhang/f_code_listing.typ — Beispiel: Code-Listing im Anhang
// Zeigt, wie Quellcode (z.B. Python, SQL) als Anhang eingebunden wird.

#figure(
  ```python
  import pandas as pd

  def analyse_umfrage(dateipfad: str) -> pd.DataFrame:
      """Liest Umfragedaten ein und berechnet Kennzahlen je Kategorie."""
      df = pd.read_csv(dateipfad, encoding="utf-8", sep=";")

      ergebnis = (
          df.groupby("kategorie")
          .agg(
              anzahl=("antwort", "count"),
              mittelwert=("bewertung", "mean"),
              std_abweichung=("bewertung", "std"),
          )
          .round(2)
          .sort_values("mittelwert", ascending=False)
      )
      return ergebnis

  if __name__ == "__main__":
      result = analyse_umfrage("daten/umfrage_2026.csv")
      print(result)
  ```,
  caption: [Python-Skript zur Auswertung der Umfragedaten (Kapitel 4).],
)

#v(1em)

#figure(
  ```sql
  -- Abfrage: Durchschnittliche Bewertung je Abteilung
  SELECT
      abteilung,
      COUNT(*)            AS anzahl_antworten,
      ROUND(AVG(bewertung), 2) AS avg_bewertung
  FROM umfrage_ergebnisse
  WHERE jahr = 2026
  GROUP BY abteilung
  ORDER BY avg_bewertung DESC;
  ```,
  caption: [SQL-Abfrage zur Aggregation der Umfrageergebnisse.],
)
