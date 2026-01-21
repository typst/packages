#import "@preview/invoice-maker:1.1.0": *

#show: invoice.with(
  language: "en", // or "de"
  banner-image: image("banner.png"),
  invoice-id: "2024-03-10t172205",
  // // Uncomment this to create a cancellation invoice
  // cancellation-id: "2024-03-24t210835",
  issuing-date: "2024-03-10",
  delivery-date: "2024-02-29",
  due-date: "2024-03-20",
  biller: (
    name: "Gyro Gearloose",
    title: "Inventor",
    company: "Crazy Inventions Ltd.",
    vat-id: "DL1234567",
    iban: "DE89370400440532013000",
    address: (
      country: "Disneyland",
      city: "Duckburg",
      postal-code: "123456",
      street: "Inventor Drive 23",
    ),
  ),
  hourly-rate: 100, // For any items with `dur-min` but no `price`
  recipient: (
    name: "Scrooge McDuck",
    title: "Treasure Hunter",
    vat-id: "DL7654321",
    address: (
      country: "Disneyland",
      city: "Duckburg",
      postal-code: "123456",
      street: "Killmotor Hill 1",
    )
  ),
  items: (
    (
      // number: 3, // You can also specify a custom item number
      date: "2016-04-03",
      description: "Arc reactor",
      // dur-min: 0, Either specify `dur-min` or `quantity` & `price`
      quantity: 1,
      price: 13000,
    ),
    (
      date: "2016-04-05",
      description: "Flux capacitor",
      dur-min: 0,
      quantity: 1,
      price: 27000,
    ),
    (
      date: "2016-04-07",
      description: "Lightsaber",
      dur-min: 0,
      quantity: 2,
      price: 3600,
    ),
    (
      date: "2016-04-08",
      description: "Sonic screwdriver",
      dur-min: 0,
      quantity: 10,
      price: 800,
    ),
    (
      date: "2016-04-12",
      description: "Assembly",
      dur-min: 160,
      quantity: 1,
      price: 53.33,
     )
  ),
)
