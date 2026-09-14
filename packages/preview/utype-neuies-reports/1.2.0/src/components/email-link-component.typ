// E-Posta adreslerini tıklanabilir bağlantı haline getirmek için oluşturulmuş bir bileşen fonksiyonudur. [Create a clickable link component for email addresses.]\
// Örnek [Example]: [mailto:e-posta@mail.com]
#let email-link-component(email: none) = link("mailto:" + email, email)
