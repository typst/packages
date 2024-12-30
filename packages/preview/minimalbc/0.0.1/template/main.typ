#import "@preview/minimalbc:0.0.1":minimalbc

#show: minimalbc.with(
    // possible geo_size options: eu, us, jp , cn
    geo_size: "eu",
    flip:false,
    company_name: "Company Name",
    name: "First and Last Name",
    role: "Role",
    telephone_number: "+000 00 000000",
    email_address: "me@me.com",
    website: "example.com",
    company_logo: image("company_logo.png"),
    bg_color: "ffffff",
)

