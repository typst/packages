# minimalbc

This repository provides a Typst template for creating sleek and minimalist professional business cards. 

The function, **minimalbc**, allows you to customize the majority of the business card's elements. 

By default, the layout is horizontal. However, it can be easily switched to a vertical layout by passing the value true to the flip argument in the minimalbc function.

Here’s an example of how to use the minimalbc function:

```Typst

#import "@preview/minimalbc:0.1.0": minimalbc

#show: minimalbc.with(
    // possible geo_size options: eu, us, jp , cn
    geo_size: "eu",
    flip:true,
    company_name: "company name",
    name: "first and last name",
    role: "role",
    telephone_number: "+000 00 000000",
    email_address: "me@me.com",
    website: "example.com",
    company_logo: image("company_logo.png"),
    bg_color: "ffffff",
)


```

When compiled, this example produces a PDF file named 'your filename'.pdf (see example.pdf). 


Feel free to download and use this as a starting point for your own business cards.


