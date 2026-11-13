# pzai-expose-unofficial

This is an unofficial template for a PhD expose at the [ Promotionszentrum Angewandte Informatik (PZAI)](https://www.oth-regensburg.de/forschen/promotion/promotionszentren/pzai). 

LaTeX template is on [GitHub](https://github.com/th-nuernberg/pzai-expose) and [Overleaf](https://www.overleaf.com/project/66fbc1c1774e1bb09da12308)

The point of this expose is to demonstrate that you have a good understanding of what your thesis will be about and what the steps are to get there. Please discuss your exposé with your advisor to make sure all points are covered. It will be read by the PZAI Promotionsausschuss (dissertation committee) to estimate if your research proposal is in line with the overall research agenda of the PZAI, if depth in terms of computer science and/or math is sufficient, and if the balance of theoretical and experimental work is adequate.

Expect this document to be about 2-3 pages (depending on figures, tables, ...), excluding references.


## Usage

``` typst
#import "@preview/pzai-expose-unofficial:0.1.1": pzai-expose-unofficial, universities

#show: pzai-expose-unofficial.with(
  title: [A fancy and very good title],
  author: [Mulmus Autorus],
  email: "mulmus.autorus@uni.edu",
  paper: "a4",
  university: universities.HM,
)
```
