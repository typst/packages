(ls).name 
| where (str ends-with ".pdf") 
| each {|el| if $el != "manual.pdf" { rm $el } }

rm template/project1.pdf
