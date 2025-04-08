/*
APA7 'ye göre 40 kelimeden az alıntılar satır içi, fazla alıntılar blok alıntı olarak verilmelidir.
*/
*Satır içi alıntı örneği:*
// Satır içi alıntı örneği.
#lorem(10) #quote[#lorem(20)] #lorem(10)

*Atıflı satır içi alıntı örneği:*
// Atıflı satır içi alıntı örneği.
#lorem(10) #quote(attribution: "John Doe")[#lorem(20)] #lorem(10)

*Bir akademik çalışmaya atıflı satır içi alıntı örneği:*
// Bir akademik çalışmaya atıflı satır içi alıntı örneği
#lorem(10) #quote(attribution: <tomul_etal_2021_RelativeEffectStudent>)[#lorem(20)] #lorem(10)

#v(0.5cm)

*Blok alıntı örneği:*
// Blok alıntı örneği.
#lorem(15) #quote(block: true)[#lorem(20)] #lorem(15)

*Birden çok paragraflı blok alıntı örneği:*
// Birden çok paragraflı blok alıntı örneği
Alıntıdan önceki paragraf. #lorem(15)
#quote(block: true)[
  Alıntının ilk paragrafı. #lorem(20)

  Alıntının ikinci paragrafı. #lorem(20)

  Alıntının üçüncü paragrafı. #lorem(20)
]
Alıntıdan sonraki paragraf. #lorem(15)

*Atıflı blok alıntı örneği:*
// Atıflı blok alıntı örneği
#lorem(20) #quote(block: true, attribution: "John Doe")[#lorem(20)] #lorem(20)

*Bir akademik çalışmaya atıflı blok alıntı örneği:*
// Bir akademik çalışmaya atıflı blok alıntı örneği
#lorem(20) #quote(block: true, attribution: <tomul_etal_2021_RelativeEffectStudent>)[#lorem(20)] #lorem(20)
