#import "@preview/invoice-maker:1.0.0": *

#show: invoice.with(
  language: "en", // or "de"
  banner_image: image("banner.png"),
  invoice_id: "2024-03-10t172205",
  // // Uncomment this to create a cancellation invoice
  // cancellation_id: "2024-03-24t210835",
  issuing_date: "2024-03-10",
  delivery_date: "2024-02-29",
  due_date: "2024-03-20",
  biller: (
    name: "Gyro Gearloose",
    title: "Inventor",
    company: "Crazy Inventions Ltd.",
    vat_id: "DL1234567",
    iban: "DE89370400440532013000",
    address: (
      country: "Disneyland",
      city: "Duckburg",
      postal_code: "123456",
      street: "Inventor Drive 23",
    ),
  ),
  hourly_rate: 100, // For any items with `dur_min` but no `price`
  recipient: (
    name: "Scrooge McDuck",
    title: "Treasure Hunter",
    vat_id: "DL7654321",
    address: (
      country: "Disneyland",
      city: "Duckburg",
      postal_code: "123456",
      street: "Killmotor Hill 1",
    )
  ),
  items: (
    (
      // number: 3, // You can also specify a custom item number
      date: "2016-04-03",
      description: "Arc reactor",
      // dur_min: 0, Either specify `dur_min` or `quantity` & `price`
      quantity: 1,
      price: 13000,
    ),
    (
      date: "2016-04-05",
      description: "Flux capacitor",
      dur_min: 0,
      quantity: 1,
      price: 27000,
    ),
    (
      date: "2016-04-07",
      description: "Lightsaber",
      dur_min: 0,
      quantity: 2,
      price: 3600,
    ),
    (
      date: "2016-04-08",
      description: "Sonic screwdriver",
      dur_min: 0,
      quantity: 10,
      price: 800,
    ),
    (
      date: "2016-04-12",
      description: "Assembly",
      dur_min: 160,
      quantity: 1,
      price: 53.33,
     )
  ),
)
