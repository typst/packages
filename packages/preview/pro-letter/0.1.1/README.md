# Business Letter Typst Template

This Typst template lets you create professional business letters effortlessly.

## Features

- **Flexible Styling**: Adjust fonts, sizes, and emphasis according to your preferences.
- **Customizable Sender and Recipient Details**: Easily configure names,
  addresses, and contact information.
- **Date and Subject Line**: Clearly define the date and subject of your letter.
- **Attachment Listings**: Describe any attachments that accompany your letter.
- **Notary Section**: Include an optional notary acknowledgment page.

## Usage

To use this template, import it and configure the parameters as shown:

```typst
#import "@preview/pro-letter:0.1.1": pro-letter

#show: pro-letter.with(
  sender: (
    name: "Alexandra Bloom",
    street: "123 Blueberry Lane",
    city: "Wonderland",
    state: "NA",
    zip: "56789",
    phone: "+1-555-987-6543",
    email: "alex@bloomworld.net",
  ),

  recipient: (
    company: "Fantasy Finance Faucets",
    attention: "Treasury Team",
    street: "456 Dreamscape Ave",
    city: "Fabletown",
    state: "IM",
    zip: "12345",
  ),

  date: "January 15, 2025",

  subject: "Account Closure Request",

  signer: "Alexandra Bloom",

  attachments: "Fae Council Closure Order.",
)

I am writing to formally request the closure of the enchanted vault at Fantasy
Finance Faucets held in my name, Alexandra Bloom.

Attached is the official Fae Council Closure Order for your verification and
records.

The account is identified by the vault number: *12345FAE*.

As the rightful owner, I _authorize the closure of the aforementioned vault_ and
_request that all enchanted funds be redirected to the Fae Council Reserve_.
Please find the necessary details for the transfer enclosed.

Thank you for your prompt attention to this magical matter.
```

## Parameters

### Address Information

Both `sender` and `recipient` parameters accept the following optional fields in
the form of a dictionary. Include only the fields necessary for your letter:

- **`name`**: Full name of the person.
- **`company`**: Company name.
- **`attention`**: Department or individual to address within the company.
- **`street`**: Street address.
- **`city`**: City.
- **`state`**: State or region.
- **`zip`**: ZIP or postal code.
- **`phone`**: Phone number.
- **`email`**: Email address.

### Letter Details

- **`date`**: The date of the letter. Optional; defaults to none.
- **`subject`**: The subject line of the letter. Optional; defaults to none.
- **`salutation`**: The greeting in the letter. Optional; defaults to "To whom
  it may concern,".
- **`closing`**: The closing line of the letter. Required; defaults to "Sincerely,".
- **`signer`**: The name of the person signing the letter. Required.

### Additional Features

- **`attachments`**: Description of any attachments accompanying the letter.
  Optional; defaults to none.
- **`notary-page`**: Boolean flag to include a notary public acknowledgment
  page. Defaults to false.

### Text and Style Settings

- **`font`**: The typeface to use for the letter. Defaults to "Libertinus Serif".
- **`size`**: Font size. Defaults to 11pt.
- **`weight`**: Font weight. Defaults to "light".
- **`strong-delta`**: Additional weight for bold text. Defaults to 300.
- **`lang`**: Language for the document. Defaults to "en".

### Page Settings

- **`paper`**: Paper size for the document. Defaults to "us-letter".
- **`margin`**: Margin size around the edges of the page. Defaults to "1in".

## License

This work is licensed under the MIT License.
