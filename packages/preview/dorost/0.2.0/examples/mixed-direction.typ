#import "@preview/dorost:0.2.0": document, ltr, rtl

#show: document.with(lang: "fa", direction: "rtl")

= متن ترکیبی و English

متن فارسی با شناسه #ltr[API.get(2)] و نشانی #ltr[https://example.com/a?b=2] در یک پاراگراف.

#rtl[English inside an explicit right-to-left span.]

کد: #raw("const total = 2026;") و ریاضی $x = 2$.
