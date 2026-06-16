:: copy full thesis
copy "..\thesis.pdf" "..\..\surfdrive-mirror\dissertation_NemoAndrea_full.pdf"
:: copy chapters (manual split point)
pdftk "..\thesis.pdf" cat 13-26   output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch1.pdf"
pdftk "..\thesis.pdf" cat 27-49   output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch2.pdf"
pdftk "..\thesis.pdf" cat 49-66   output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch3.pdf"
pdftk "..\thesis.pdf" cat 67-92   output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch4.pdf"
pdftk "..\thesis.pdf" cat 93-116  output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch5.pdf"
pdftk "..\thesis.pdf" cat 117-136 output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch6.pdf"
pdftk "..\thesis.pdf" cat 137-174 output "..\..\surfdrive-mirror\dissertation_NemoAndrea_ch7.pdf"
