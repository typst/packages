// arxiv
#let arxiv-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M14 9.8l3.5-4.1c.3-.4.4-.6.3-.9-.1-.3-.5-.6-.9-.6-.2 0-.4.1-.6.2L12.2 8 14 9.8zM7.5 20c-.4 0-.8-.3-1-.6-.1-.4 0-.9.3-1.2l3.3-4 .2.2-3.3 4c-.2.2-.3.6-.2.9.1.3.4.4.7.4.2 0 .4-.1.5-.2l6.9-6.4c.3-.3.4-.6.5-1s-.1-.7-.4-1l-.1-.1-8.5-8.1c-.2-.2-.4-.3-.6-.4-.3 0-.6.2-.7.5-.1.2-.1.4.2.8l5 6-.2.2-5-6c-.3-.5-.4-.7-.3-1.1.2-.4.5-.6 1-.6.3.1.6.2.8.5l8.5 8.1.1.1c.3.3.5.8.4 1.2 0 .5-.2.9-.6 1.2l-6.8 6.3c-.1.2-.4.3-.7.3z"/>  <path d="M18.9 20.2L12.1 12l-1.8-2.2-1.1 1c-.7.6-.7 1.7 0 2.3l8.7 8.4c.2.2.4.2.6.2.3 0 .6-.2.8-.5 0-.3-.1-.7-.4-1z"/></svg>```.text
#let arxiv-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(arxiv-svg.replace("currentColor", color.to-hex()))))
}

// binder
#let binder-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M14.1 10.6c-3 0-5.5 2.5-5.5 5.5s2.5 5.5 5.5 5.5 5.5-2.5 5.5-5.5-2.4-5.5-5.5-5.5zm0 2.3c1.8 0 3.2 1.4 3.2 3.2 0 1.8-1.4 3.2-3.2 3.2-1.8 0-3.2-1.4-3.2-3.2 0-1.8 1.5-3.2 3.2-3.2z"/>  <path d="M9.9 6.5c-3 0-5.5 2.5-5.5 5.5s2.5 5.5 5.5 5.5 5.5-2.5 5.5-5.5c-.1-3.1-2.5-5.5-5.5-5.5zm0 2.2c1.8 0 3.2 1.4 3.2 3.2 0 1.8-1.4 3.2-3.2 3.2-1.8 0-3.2-1.4-3.2-3.2-.1-1.7 1.4-3.2 3.2-3.2z"/>  <path d="M14.1 2.2c-3 0-5.5 2.5-5.5 5.5s2.5 5.5 5.5 5.5 5.5-2.5 5.5-5.5c0-3.1-2.4-5.5-5.5-5.5zm0 2.2c1.8 0 3.2 1.4 3.2 3.2 0 1.8-1.4 3.2-3.2 3.2-1.8 0-3.2-1.4-3.2-3.2 0-1.8 1.5-3.2 3.2-3.2z"/></svg>```.text
#let binder-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(binder-svg.replace("currentColor", color.to-hex()))))
}

// bluesky
#let bluesky-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M5.9 4.2C8.4 6 11 9.8 12 11.8c1-2 3.6-5.8 6.1-7.7 1.8-1.3 4.7-2.4 4.7.9 0 .7-.4 5.5-.6 6.3-.8 2.8-3.6 3.5-6.1 3 4.4.7 5.5 3.2 3.1 5.7-4.6 4.7-6.6-1.2-7.1-2.7-.1-.1-.1-.3-.1-.2 0-.1 0 0-.1.3-.5 1.5-2.5 7.4-7.1 2.7-2.4-2.5-1.3-4.9 3.1-5.7-2.5.4-5.3-.3-6.1-3-.2-.8-.6-5.7-.6-6.3 0-3.3 2.9-2.3 4.7-.9z"/></svg>```.text
#let bluesky-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(bluesky-svg.replace("currentColor", color.to-hex()))))
}

// cc-by
#let cc-by-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 2.2c2.7 0 5 .9 6.9 2.8 1.9 1.9 2.8 4.2 2.8 6.9s-.9 5-2.8 6.8c-2 1.9-4.3 2.9-7 2.9-2.6 0-4.9-1-6.9-2.9-1.8-1.7-2.8-4-2.8-6.7s1-5 2.9-6.9C7 3.2 9.3 2.2 12 2.2zM12 4c-2.2 0-4.1.8-5.6 2.3C4.8 8 4 9.9 4 12c0 2.2.8 4 2.4 5.6C8 19.2 9.8 20 12 20c2.2 0 4.1-.8 5.7-2.4 1.5-1.5 2.3-3.3 2.3-5.6 0-2.2-.8-4.1-2.3-5.7C16.1 4.8 14.2 4 12 4zm2.6 5.6v4h-1.1v4.7h-3v-4.7H9.4v-4c0-.2.1-.3.2-.4.1-.2.2-.2.4-.2h4c.2 0 .3.1.4.2.2.1.2.2.2.4zm-4-2.5c0-.9.5-1.4 1.4-1.4s1.4.5 1.4 1.4c0 .9-.5 1.4-1.4 1.4s-1.4-.5-1.4-1.4z"/></svg>```.text
#let cc-by-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(cc-by-svg.replace("currentColor", color.to-hex()))))
}

// cc-nc
#let cc-nc-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 2.2c2.7 0 5 .9 6.9 2.8 1.9 1.9 2.8 4.2 2.8 6.9s-.9 5-2.8 6.8c-2 1.9-4.3 2.9-7 2.9-2.6 0-4.9-1-6.9-2.9-1.9-1.9-2.9-4.2-2.9-6.9s1-5 2.9-6.9c2-1.7 4.3-2.7 7-2.7zM4.4 9.4C4.2 10.2 4 11 4 12c0 2.2.8 4 2.4 5.6C8 19.2 9.8 20 12 20c2.2 0 4.1-.8 5.7-2.4.6-.5 1-1.1 1.3-1.7l-3.7-1.6c-.1.6-.4 1.1-.9 1.5-.5.4-1.1.6-1.8.7V18h-1.1v-1.5c-1.1 0-2.1-.4-3-1.2l1.3-1.4c.6.6 1.4.9 2.2.9.3 0 .6-.1.9-.2.2-.2.4-.4.4-.7 0-.2-.1-.4-.3-.6l-.9-.4-1.1-.6-1.5-.7-5.1-2.2zM12 4c-2.2 0-4.1.8-5.6 2.3-.4.4-.7.9-1.1 1.3L9 9.3c.2-.5.5-.9 1-1.2.5-.3 1-.5 1.6-.5V6.1h1.1v1.5c.9 0 1.7.3 2.4.9l-1.3 1.3c-.5-.4-1.1-.6-1.7-.6-.3 0-.6.1-.8.2-.2.1-.3.3-.3.6 0 .1 0 .2.1.2l1.2.6.9.4 1.6.7 5 2.2c.2-.7.2-1.4.2-2.1 0-2.2-.8-4.1-2.3-5.7C16.1 4.8 14.2 4 12 4z"/></svg>```.text
#let cc-nc-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(cc-nc-svg.replace("currentColor", color.to-hex()))))
}

// cc-nd
#let cc-nd-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 2.2c2.7 0 5 .9 6.9 2.8 1.9 1.9 2.8 4.2 2.8 6.9s-.9 5-2.8 6.9c-2 1.9-4.3 2.9-7 2.9-2.6 0-4.9-1-6.9-2.9C3.2 17 2.2 14.7 2.2 12s1-5 2.9-6.9C7 3.2 9.3 2.2 12 2.2zM12 4c-2.2 0-4.1.8-5.6 2.4C4.8 8 4 9.9 4 12c0 2.2.8 4 2.4 5.6C8 19.2 9.8 20 12 20c2.2 0 4.1-.8 5.7-2.4 1.5-1.5 2.3-3.3 2.3-5.6 0-2.2-.8-4.1-2.3-5.6C16.1 4.8 14.2 4 12 4zm3.7 5.7v1.7H8.6V9.7h7.1zm0 3.1v1.7H8.6v-1.7h7.1z"/></svg>```.text
#let cc-nd-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(cc-nd-svg.replace("currentColor", color.to-hex()))))
}

// cc-sa
#let cc-sa-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 2.2c2.7 0 5 .9 6.9 2.8 1.9 1.9 2.8 4.2 2.8 6.9s-.9 5-2.8 6.9c-2 1.9-4.3 2.9-7 2.9-2.6 0-4.9-1-6.9-2.9C3.2 17 2.2 14.7 2.2 12s1-5 2.9-6.9C7 3.2 9.3 2.2 12 2.2zM12 4c-2.2 0-4.1.8-5.6 2.4C4.8 8 4 9.9 4 12c0 2.2.8 4 2.4 5.6C8 19.2 9.8 20 12 20c2.2 0 4.1-.8 5.7-2.4 1.5-1.5 2.3-3.3 2.3-5.6 0-2.2-.8-4.1-2.3-5.6C16.1 4.8 14.2 4 12 4zm-4.3 6.6c.2-1.2.7-2.1 1.4-2.8.8-.7 1.7-1 2.8-1 1.5 0 2.8.5 3.7 1.5.9 1 1.4 2.3 1.4 3.8s-.5 2.7-1.4 3.7c-.9 1-2.2 1.5-3.7 1.5-1.1 0-2.1-.3-2.9-1-.8-.7-1.3-1.6-1.4-2.8h2.5c.1 1.2.8 1.8 2.1 1.8.7 0 1.2-.3 1.7-.9.4-.6.6-1.4.6-2.4s-.2-1.8-.6-2.4c-.4-.5-.9-.8-1.7-.8-1.3 0-2 .6-2.2 1.7h.7l-1.9 1.9-1.9-1.9.8.1z"/></svg>```.text
#let cc-sa-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(cc-sa-svg.replace("currentColor", color.to-hex()))))
}

// cc-zero
#let cc-zero-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 6.4c-3.2 0-4 3-4 5.6 0 2.6.8 5.6 4 5.6s4-3 4-5.6c0-2.6-.8-5.6-4-5.6zm0 2.1h.4c.2.2.3.5.1.9l-2.1 3.9c-.1-.5-.1-1-.1-1.4 0-1 0-3.4 1.7-3.4zm1.6 1.8c.1.6.1 1.2.1 1.7 0 1.1-.1 3.5-1.7 3.5h-.4-.1-.1c-.4-.2-.6-.4-.3-.9l2.5-4.3z"/>  <path d="M12 2.2c-2.7 0-5 .9-6.8 2.8-1 1-1.7 2.1-2.2 3.3-.5 1.2-.8 2.4-.8 3.7 0 1.3.2 2.5.7 3.7.5 1.2 1.2 2.2 2.1 3.2.9.9 2 1.6 3.2 2.1 1.2.5 2.4.7 3.7.7 1.3 0 2.5-.3 3.7-.8 1.2-.5 2.3-1.2 3.2-2.2.9-.9 1.6-1.9 2.1-3.1.5-1.2.7-2.4.7-3.8 0-1.3-.2-2.6-.7-3.7-.3-1-1-2.1-1.9-3-2-1.9-4.3-2.9-7-2.9zM12 4c2.2 0 4.1.8 5.7 2.3.7.8 1.3 1.7 1.7 2.6.4 1 .6 2 .6 3.1 0 2.2-.8 4.1-2.3 5.6-.8.8-1.7 1.4-2.7 1.8-1 .4-2 .6-3 .6-1.1 0-2.1-.2-3-.6-1-.4-1.8-1-2.6-1.7C5.6 16.9 5 16 4.6 15c-.4-1-.6-2-.6-3 0-1.1.2-2.1.6-3 .4-1 1-1.9 1.8-2.6C7.9 4.8 9.8 4 12 4z"/></svg>```.text
#let cc-zero-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(cc-zero-svg.replace("currentColor", color.to-hex()))))
}

// cc
#let cc-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 2.2c2.7 0 5 1 7 2.9.9.9 1.6 2 2.1 3.1.5 1.2.7 2.4.7 3.8 0 1.3-.2 2.6-.7 3.8-.5 1.2-1.2 2.2-2.1 3.1-1 .9-2 1.7-3.2 2.2-1.2.5-2.5.7-3.7.7s-2.6-.3-3.8-.8c-1.2-.5-2.2-1.2-3.2-2.1s-1.6-2-2.1-3.2-.8-2.4-.8-3.7c0-1.3.2-2.5.7-3.7S4.2 6 5.1 5.1C7 3.2 9.3 2.2 12 2.2zM12 4c-2.2 0-4.1.8-5.6 2.3C5.6 7.1 5 8 4.6 9c-.4 1-.6 2-.6 3s.2 2.1.6 3c.4 1 1 1.8 1.8 2.6S8 19 9 19.4c1 .4 2 .6 3 .6s2.1-.2 3-.6c1-.4 1.9-1 2.7-1.8 1.5-1.5 2.3-3.3 2.3-5.6 0-1.1-.2-2.1-.6-3.1-.4-1-1-1.8-1.7-2.6C16.1 4.8 14.2 4 12 4zm-.1 6.4l-1.3.7c-.1-.3-.3-.5-.5-.6-.2-.1-.4-.2-.6-.2-.9 0-1.3.6-1.3 1.7 0 .5.1.9.3 1.3.2.3.5.5 1 .5.6 0 1-.3 1.2-.8l1.2.6c-.3.5-.6.9-1.1 1.1-.5.3-1 .4-1.5.4-.9 0-1.6-.3-2.1-.8-.5-.6-.8-1.3-.8-2.3 0-.9.3-1.7.8-2.2.6-.6 1.3-.8 2.1-.8 1.2 0 2.1.4 2.6 1.4zm5.6 0l-1.3.7c-.1-.3-.3-.5-.5-.6-.2-.1-.4-.2-.6-.2-.9 0-1.3.6-1.3 1.7 0 .5.1.9.3 1.3.2.3.5.5 1 .5.6 0 1-.3 1.2-.8l1.2.6c-.3.5-.6.9-1.1 1.1-.4.2-.9.3-1.4.3-.9 0-1.6-.3-2.1-.8s-.8-1.3-.8-2.2c0-.9.3-1.7.8-2.2.5-.5 1.2-.8 2-.8 1.2 0 2.1.4 2.6 1.4z"/></svg>```.text
#let cc-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(cc-svg.replace("currentColor", color.to-hex()))))
}

// curvenote
#let curvenote-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M21.8 17.3c0 2.5-1.9 4.4-4.4 4.4-2.4 0-4.4-1.9-4.4-4.4s1.9-4.4 4.4-4.4c2.3 0 4.4 2.1 4.4 4.4zM2.2 12.9H11v8.8c-4.8 0-8.8-3.9-8.8-8.8zm2.7-8.1C6.5 3.2 8.8 2.2 11 2.2V11H2.2c0-2.3 1-4.5 2.7-6.2zm14.2 3.6C17.5 10 15.2 11 13 11V2.2h8.8c0 2.3-1 4.6-2.7 6.2z"/></svg>```.text
#let curvenote-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(curvenote-svg.replace("currentColor", color.to-hex()))))
}

// discord
#let discord-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M19.7 4.9c-1.5-.7-3-1.1-4.6-1.4-.2.3-.5.8-.6 1.1-1.7-.2-3.4-.2-5.1 0-.2-.3-.3-.7-.5-1-1.6.2-3.1.8-4.6 1.3C1.4 9.2.6 13.4 1 17.6c1.7 1.3 3.6 2.2 5.6 2.9.5-.6.8-1.3 1.3-2-.7-.2-1.3-.6-2-.9.1-.1.3-.2.5-.3 3.6 1.7 7.7 1.7 11.3 0 .1.1.3.2.5.3-.6.3-1.3.7-2 .9.3.7.8 1.4 1.3 2 2.1-.6 3.9-1.6 5.6-2.9.4-4.8-.9-9-3.4-12.7zM8.3 15c-1.1 0-2-1-2-2.2s.9-2.2 2-2.2 2.1 1 2 2.2-.8 2.2-2 2.2zm7.4 0c-1.1 0-2-1-2-2.2s.9-2.2 2-2.2 2.1 1 2 2.2-.9 2.2-2 2.2z"/></svg>```.text
#let discord-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(discord-svg.replace("currentColor", color.to-hex()))))
}

// discourse
#let discourse-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12.1 2.2c-5.4 0-10 4.3-10 9.7v10h10c5.4 0 9.7-4.5 9.7-9.8s-4.4-9.9-9.7-9.9zM12 17.7c-.8 0-1.6-.2-2.4-.6L6 18l1-3.2c-.3-.9-.6-1.9-.6-2.8 0-3.1 2.5-5.7 5.7-5.7s5.7 2.5 5.7 5.7-2.7 5.7-5.8 5.7z"/></svg>```.text
#let discourse-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(discourse-svg.replace("currentColor", color.to-hex()))))
}

// email
#let email-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M21.8 18c0 1.1-.9 2-1.9 2H4.2c-1.1 0-1.9-.9-1.9-2V9.9c0-.5.3-.7.8-.4l7.8 4.7c.7.4 1.7.4 2.4 0L21 9.5c.4-.2.8-.1.8.4V18z"/>  <path d="M21.8 6c0-1.1-.9-2-1.9-2H4.2c-1.1 0-2 .9-2 2v.4c0 .5.3 1.1.8 1.3l8.5 5.1c.2.1.7.1.9 0l8.6-5c.4-.3.8-.9.8-1.3-.1-.1-.1-.5 0-.5z"/></svg>```.text
#let email-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(email-svg.replace("currentColor", color.to-hex()))))
}

// github
#let github-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M12 2.5c-5.4 0-9.8 4.4-9.8 9.7 0 4.3 2.8 8 6.7 9.2.5.1.7-.2.7-.5v-1.8c-2.4.5-3.1-.6-3.3-1.1-.1-.3-.6-1.1-1-1.4-.3-.2-.8-.6 0-.6s1.3.7 1.5 1c.9 1.5 2.3 1.1 2.8.8.1-.6.3-1.1.6-1.3-2.2-.2-4.4-1.1-4.4-4.8 0-1.1.4-1.9 1-2.6-.1-.2-.4-1.2.1-2.6 0 0 .8-.3 2.7 1 .8-.2 1.6-.3 2.4-.3.8 0 1.7.1 2.4.3 1.9-1.3 2.7-1 2.7-1 .5 1.3.2 2.3.1 2.6.6.7 1 1.5 1 2.6 0 3.7-2.3 4.6-4.4 4.8.4.3.7.9.7 1.8V21c0 .3.2.6.7.5 3.9-1.3 6.6-4.9 6.6-9.2 0-5.4-4.4-9.8-9.8-9.8z"/></svg>```.text
#let github-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(github-svg.replace("currentColor", color.to-hex()))))
}

// jupyter-book
#let jupyter-book-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M11.3 20.5c0-1.4-.8-2.1-2.4-2.1h-2c-1.2 0-2.2-.3-3-.9-.7-.6-1.3-1.5-1.6-2.6l1.1-.4c.4 1.3 1.5 2.1 3.3 2.1h2.2c1.5 0 2.6.6 3.1 1.8.5-1.2 1.6-1.8 3.1-1.8h2c1.9 0 3-.7 3.5-2.1l1.1.4c-.3 1.2-.9 2.1-1.6 2.6-.7.6-1.7.9-3 .9H15c-1.6 0-2.4.7-2.4 2.1M7.1 13.4c-.5 0-1-.1-1.5-.3-.4-.2-.8-.6-1.1-1-.3-.5-.4-1.1-.4-1.6h1.3c0 .7.2 1.1.4 1.4.3.3.8.5 1.2.5.3 0 .6-.1.9-.2.2-.2.4-.4.5-.7.1-.3.2-.6.2-1v-6l-1.2-.1v-.9h3.7v.8l-1.1.2v5.9c0 .5-.1 1-.3 1.5-.2.4-.6.8-1 1-.5.4-1 .5-1.6.5zm5-.2v-.8l1.1-.2V4.5l-1.1-.2v-.8h4.2c1 0 1.8.2 2.4.7.6.4.9 1.1.9 2 0 .4-.1.8-.4 1.2-.3.3-.7.6-1.1.8.4.1.7.2 1 .5.3.2.5.5.7.9.2.3.2.7.2 1.1 0 .9-.3 1.6-.9 2s-1.4.7-2.4.7l-4.6-.2zm2.4-1h2.2c.5 0 1-.1 1.4-.4.3-.3.5-.8.5-1.3 0-.3-.1-.7-.2-1-.1-.3-.3-.5-.6-.6-.3-.2-.6-.2-1-.2h-2.4l.1 3.5zm0-4.6h2.1c.4 0 .8-.1 1.1-.4.3-.3.5-.7.4-1.1 0-.4-.2-.9-.5-1.2-.4-.3-.9-.4-1.4-.4h-1.8l.1 3.1z"/></svg>```.text
#let jupyter-book-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(jupyter-book-svg.replace("currentColor", color.to-hex()))))
}

// jupyter-text
#let jupyter-text-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M2.9 12.5c0 .7-.1 1-.2 1.1-.2.1-.4.2-.6.2l.1.4c.3 0 .7-.1.9-.3.3-.3.4-.8.4-1.2V10h-.6v2.5zM7 12.2v.8h-.4v-.5c-.2.4-.6.6-1 .6-.5 0-1.1-.3-1.1-1.3V10H5v1.7c0 .6.2 1 .7 1 .4 0 .8-.3.8-.8V10H7v2.2zM8.1 11v-1h.5v.5c.2-.4.6-.6 1.1-.6.7 0 1.3.6 1.3 1.5 0 1.1-.7 1.6-1.4 1.6-.4 0-.7-.2-.9-.5v1.7h-.6V11zm.5.8v.2c0 .2.4.6.8.6.6 0 .9-.5.9-1.2 0-.6-.3-1.1-.9-1.1-.5 0-.8.4-.8.9v.6zM11.9 10l.7 1.8.2.6.2-.6.6-1.8h.6l-.8 2.2c-.4 1-.7 1.6-1 1.9-.2.2-.4.3-.7.4l-.1-.5c.2-.1.3-.1.5-.3s.4-.4.5-.6v-.2L11.3 10h.6zM15.7 9.1v.9h.8v.4h-.8V12c0 .4.1.6.4.6h.3v.4c-.2.1-.3.1-.5.1s-.5-.1-.6-.2c-.2-.2-.2-.5-.2-.8v-1.7h-.5V10h.5v-.7l.6-.2zM17.5 11.6c0 .5.4 1 .9 1h.2c.3 0 .6 0 .8-.2l.1.4c-.3.1-.7.2-1 .2-.8.1-1.4-.5-1.5-1.3v-.2c0-.9.5-1.6 1.4-1.6 1 0 1.2.9 1.2 1.4v.3h-2.1zm1.6-.4c.1-.4-.2-.8-.7-.9h-.1c-.5 0-.8.4-.8.9h1.6zM20.4 10.9V10h.5v.6c.1-.4.4-.6.8-.7h.2v.5h-.2c-.4 0-.7.3-.7.7V13h-.5l-.1-2.1zM20.2 1.7c0 .8-.5 1.4-1.3 1.5-.8 0-1.4-.5-1.5-1.3 0-.8.5-1.4 1.3-1.5.8-.1 1.5.5 1.5 1.3zM12 17.9c-3.7 0-7-1.3-8.7-3.3 1.8 4.8 7.1 7.3 11.9 5.5 2.5-.9 4.5-2.9 5.5-5.5-1.7 2-4.9 3.3-8.7 3.3zM12 5.1c3.7 0 7 1.3 8.7 3.3-1.8-4.8-7.1-7.3-11.9-5.5-2.5.9-4.5 2.9-5.5 5.5 1.7-2 5-3.3 8.7-3.3zM6.9 21.8c.1 1-.7 1.8-1.7 1.9S3.4 23 3.3 22c0-1 .7-1.8 1.7-1.9 1-.1 1.8.7 1.9 1.7zM3.7 4.6c-.6 0-1-.4-1-1s.4-1 1-1 1 .4 1 1c0 .5-.4 1-1 1z"/></svg>```.text
#let jupyter-text-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(jupyter-text-svg.replace("currentColor", color.to-hex()))))
}

// jupyter
#let jupyter-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M20.2 1.7c0 .8-.5 1.4-1.3 1.5-.8 0-1.4-.5-1.5-1.3 0-.8.5-1.4 1.3-1.5.8-.1 1.5.5 1.5 1.3zM12 17.9c-3.7 0-7-1.3-8.7-3.3 1.8 4.8 7.1 7.3 11.9 5.5 2.5-.9 4.5-2.9 5.5-5.5-1.7 2-4.9 3.3-8.7 3.3zM12 5.1c3.7 0 7 1.3 8.7 3.3-1.8-4.8-7.1-7.3-11.9-5.5-2.5.9-4.5 2.9-5.5 5.5 1.7-2 5-3.3 8.7-3.3zM6.9 21.8c.1 1-.7 1.8-1.7 1.9-1 .1-1.8-.7-1.9-1.7 0-1 .7-1.8 1.7-1.9 1-.1 1.8.7 1.9 1.7zM3.7 4.6c-.6 0-1-.4-1-1s.4-1 1-1 1 .4 1 1c0 .5-.4 1-1 1z"/></svg>```.text
#let jupyter-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(jupyter-svg.replace("currentColor", color.to-hex()))))
}

// linkedin
#let linkedin-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M6.8 8.5H2.9c-.2 0-.3.2-.3.3v12.6c0 .2.2.3.3.3h3.9c.2 0 .3-.2.3-.3V8.8c0-.2-.1-.3-.3-.3zm-2-6.3c-1.4 0-2.6 1.2-2.6 2.6s1.2 2.6 2.6 2.6 2.6-1.2 2.6-2.6-1.2-2.6-2.6-2.6zm11.9 6c-1.6 0-2.7.7-3.4 1.4v-.8c0-.2-.2-.3-.3-.3H9.2c-.2 0-.3.2-.3.3v12.6c0 .2.2.3.3.3h3.9c.2 0 .3-.2.3-.3v-6.3c0-2.1.6-2.9 2-2.9 1.6 0 1.7 1.3 1.7 3v6.1c0 .2.2.3.3.3h3.9c.2 0 .3-.2.3-.3v-6.9c.1-3.1-.5-6.2-4.9-6.2z"/></svg>```.text
#let linkedin-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(linkedin-svg.replace("currentColor", color.to-hex()))))
}

// mastodon
#let mastodon-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M21.1 8.7c0-4.2-2.8-5.5-2.8-5.5-1.4-.6-3.8-.9-6.3-.9s-4.9.3-6.3.9c0 0-2.8 1.2-2.8 5.5v3.4c.1 4.1.8 8.2 4.6 9.2 1.8.5 3.3.6 4.5.5 2.2-.1 3.5-.8 3.5-.8l-.1-1.6s-1.6.5-3.4.4c-1.8-.1-3.6-.2-3.9-2.3v-.6s1.7.4 3.9.5c1.3.1 2.6-.1 3.9-.2 2.4-.3 4.6-1.8 4.8-3.2.4-2.2.4-5.3.4-5.3zm-3.3 5.4h-2v-5c0-1-.4-1.6-1.3-1.6-1 0-1.5.6-1.5 1.9v2.7h-2V9.4c0-1.2-.5-1.9-1.5-1.9-.9 0-1.3.5-1.3 1.6v5h-2V9c0-1 .3-1.9.8-2.5.6-.6 1.3-.9 2.2-.9 1 0 1.8.4 2.3 1.2l.5.8.5-.8c.5-.8 1.3-1.2 2.4-1.2.9 0 1.6.3 2.2.9.5.6.8 1.4.8 2.5v5.1z"/></svg>```.text
#let mastodon-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(mastodon-svg.replace("currentColor", color.to-hex()))))
}

// myst
#let myst-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M5.7 13.4v-.9l1.1-.2V4.5l-1.1-.1v-.9h2.9l3.2 7.6L15 3.5h3v.9l-1.1.2v7.8l1.1.2v.9h-3.6v-.9l1.2-.2v-7l-3.2 7.7h-.9L8.1 5.3v7l1.2.2v.9H5.7zm5.6 7.1c0-1.4-.8-2.1-2.4-2.1h-2c-1.2 0-2.2-.3-3-.9-.7-.6-1.3-1.5-1.6-2.6l1.1-.4c.4 1.3 1.5 2.1 3.3 2.1h2.2c1.5 0 2.6.6 3.1 1.8.5-1.2 1.6-1.8 3.1-1.8h2c1.9 0 3-.7 3.5-2.1l1.1.4c-.3 1.2-.9 2.1-1.6 2.6-.7.6-1.7.9-3 .9H15c-1.6 0-2.4.7-2.4 2.1"/></svg>```.text
#let myst-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(myst-svg.replace("currentColor", color.to-hex()))))
}

// open-access
#let open-access-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M17.1 12.6h-2V7.5c0-1.7-1.4-3.1-3-3.1-.8 0-1.6.3-2.2.9-.6.5-.9 1.3-.9 2.2v.7H7v-.7c0-1.4.5-2.7 1.5-3.7s2.2-1.5 3.6-1.5 2.6.5 3.6 1.5 1.5 2.3 1.5 3.7v5.1z"/>  <path d="M12 21.8c-.8 0-1.6-.2-2.3-.5-.7-.3-1.4-.8-1.9-1.3-.6-.6-1-1.2-1.3-2-.3-.8-.5-1.6-.5-2.4s.2-1.6.5-2.4c.3-.7.7-1.4 1.3-2s1.2-1 1.9-1.3c.7-.3 1.5-.5 2.3-.5.8 0 1.6.2 2.3.5.7.3 1.4.8 1.9 1.3.6.6 1 1.2 1.3 2 .3.8.5 1.6.5 2.4s-.2 1.6-.5 2.4c-.3.7-.7 1.4-1.3 2-.6.6-1.2 1-1.9 1.3-.7.3-1.5.5-2.3.5zm0-10.3c-2.2 0-4 1.8-4 4.1s1.8 4.1 4 4.1 4-1.8 4-4.1-1.8-4.1-4-4.1z"/>  <circle cx="12" cy="15.6" r="1.7"/></svg>```.text
#let open-access-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(open-access-svg.replace("currentColor", color.to-hex()))))
}

// orcid
#let orcid-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M21.8 12c0 5.4-4.4 9.8-9.8 9.8S2.2 17.4 2.2 12 6.6 2.2 12 2.2s9.8 4.4 9.8 9.8zM8.2 5.8c-.4 0-.8.3-.8.8s.3.8.8.8.8-.4.8-.8-.3-.8-.8-.8zm2.3 9.6h1.2v-6h1.8c2.3 0 3.3 1.4 3.3 3s-1.5 3-3.3 3h-3v1.1H9V8.3H7.7v8.2h5.9c3.3 0 4.5-2.2 4.5-4.1s-1.2-4.1-4.3-4.1h-3.2l-.1 7.1z"/></svg>```.text
#let orcid-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(orcid-svg.replace("currentColor", color.to-hex()))))
}

// osi
#let osi-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M13.2 15.6c1.4-.5 2.1-1.6 2.1-3.3S13.8 8.9 12 8.9c-1.9 0-3.3 1.6-3.3 3.3 0 1.8.8 3 2.2 3.4l-2.3 5.9c-3.1-.8-6.3-4.6-6.3-9.3 0-5.5 4.3-10 9.7-10s9.8 4.5 9.8 10c0 4.7-3.1 8.5-6.3 9.3l-2.3-5.9z"/></svg>```.text
#let osi-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(osi-svg.replace("currentColor", color.to-hex()))))
}

// ror
#let ror-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M10 4.2L8.3 6.8 6.6 4.2H10zM17.1 4.2l-1.7 2.6-1.7-2.6h3.4zM6.6 19.8l1.7-2.6 1.7 2.6H6.6zM13.7 19.8l1.7-2.6 1.7 2.6h-3.4zM20.8 12.5c.6-.1 1.1-.4 1.4-.8.3-.4.5-.9.5-1.5 0-.5-.1-.9-.3-1.2-.2-.3-.4-.6-.7-.8-.3-.2-.6-.3-1-.4-.4-.1-.8-.1-1.2-.1h-3.3v2.6c0-.1-.1-.2-.1-.2-.2-.6-.6-1-1-1.4-.4-.4-.9-.7-1.5-.9-.6-.2-1.2-.3-1.9-.3s-1.3.1-1.9.3c-.5.1-1 .4-1.4.8-.3.4-.6.8-.9 1.3 0-.3-.1-.6-.2-.9-.2-.4-.4-.6-.7-.8-.3-.2-.6-.3-1-.4s-.8-.2-1.3-.2H1v8.5h1.9v-3.4h.9l1.8 3.4h2.3l-2.2-3.6c.6-.1 1.1-.4 1.4-.8v-.1.2c0 .7.1 1.3.3 1.8.2.6.6 1 1 1.4.4.4.9.7 1.5.9.6.2 1.2.3 1.9.3s1.3-.1 1.9-.3c.6-.2 1.1-.5 1.5-.9.4-.4.7-.9 1-1.4 0-.1.1-.2.1-.2V16H18v-3.4h.9l1.8 3.4H23l-2.2-3.5zM5.4 10.7c-.1.2-.2.3-.3.3-.2.1-.3.1-.5.1H2.9V9.2h1.7c.2 0 .3.1.5.1.1.1.3.2.3.3.1.1.1.3.1.5.1.3 0 .5-.1.6zm8.8 2.3c-.1.3-.3.6-.5.9-.2.2-.5.4-.8.6-.3.1-.7.2-1.1.2-.4 0-.8-.1-1.1-.2-.3-.1-.6-.3-.8-.6-.2-.2-.4-.5-.5-.9-.1-.3-.2-.7-.2-1.1 0-.4.1-.8.2-1.1s.3-.6.5-.9c.2-.2.5-.4.8-.6.3-.1.7-.2 1.1-.2.4 0 .8.1 1.1.2.3.1.6.3.8.6.2.2.4.5.5.9.1.3.2.7.2 1.1 0 .4 0 .7-.2 1.1zm6.4-2.3c-.1.1-.2.2-.4.3-.2.1-.3.1-.5.1H18V9.2h1.7c.2 0 .3.1.5.1.1.1.3.2.3.3.1.1.1.3.1.5.1.3.1.5 0 .6z"/></svg>```.text
#let ror-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(ror-svg.replace("currentColor", color.to-hex()))))
}

// slack
#let slack-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M6.3 14.6c0 1.1-.9 2-2 2s-2-.9-2-2 .9-2 2-2h2v2zm1.1 0c0-1.1.9-2 2-2s2 .9 2 2v5.1c0 1.1-.9 2-2 2s-2-.9-2-2v-5.1zm2-8.3c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2v2h-2zm0 1.1c1.1 0 2 .9 2 2s-.9 2-2 2H4.3c-1.1 0-2-.9-2-2s.9-2 2-2h5.1zm8.3 2c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2h-2v-2zm-1.1 0c0 1.1-.9 2-2 2s-2-.9-2-2V4.3c0-1.1.9-2 2-2s2 .9 2 2v5.1zm-2 8.3c1.1 0 2 .9 2 2s-.9 2-2 2-2-.9-2-2v-2h2zm0-1.1c-1.1 0-2-.9-2-2s.9-2 2-2h5.1c1.1 0 2 .9 2 2s-.9 2-2 2h-5.1z"/></svg>```.text
#let slack-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(slack-svg.replace("currentColor", color.to-hex()))))
}

// twitter
#let twitter-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M22.7 5.4c-.8.3-1.7.6-2.5.7.9-.5 1.6-1.4 1.9-2.4-.9.5-1.8.9-2.8 1.1-1.7-1.8-4.4-1.9-6.2-.2-1.1 1.1-1.6 2.7-1.3 4.2-3.5-.3-6.8-1.9-9-4.7-.4.7-.6 1.5-.6 2.2 0 1.5.7 2.8 1.9 3.6-.7 0-1.4-.2-2-.5v.1c0 2.1 1.5 3.9 3.5 4.3-.6.2-1.3.2-2 .1.6 1.8 2.2 3 4.1 3-1.6 1.2-3.5 1.9-5.4 1.9-.3 0-.7 0-1-.1 2 1.3 4.3 2 6.7 2 8.1 0 12.5-6.7 12.5-12.5v-.6c.8-.6 1.6-1.3 2.2-2.2"/></svg>```.text
#let twitter-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(twitter-svg.replace("currentColor", color.to-hex()))))
}

// website
#let website-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M11.9 21.6c-5.3 0-9.7-4.3-9.7-9.7 0-5.3 4.3-9.7 9.7-9.7h.1c2.6 0 5 1 6.8 2.8 1.8 1.8 2.8 4.2 2.8 6.8 0 2.6-1 5-2.8 6.9-1.8 1.9-4.2 2.9-6.9 2.9.1 0 .1 0 0 0zm0-18.2c-4.7 0-8.5 3.9-8.4 8.5 0 4.7 3.8 8.4 8.5 8.4 2.3 0 4.4-.9 6-2.5 1.6-1.6 2.5-3.7 2.5-6s-.9-4.4-2.5-6c-1.6-1.5-3.8-2.4-6.1-2.4zM11 21.2c-.5-.4-1-.9-1.4-1.4-.8-1-1.5-2.1-2-3.2-.8.3-1.7.8-2.4 1.3l-.5-.7c.8-.6 1.7-1.1 2.6-1.4-.4-1.1-.6-2.2-.6-3.4H2.9v-.8h3.8v-.5c.1-1.1.3-2.1.6-3-.9-.4-1.8-.9-2.6-1.5l.5-.6c.8.6 1.6 1 2.5 1.3C8.3 5.6 9.5 4 11 2.7l.5.6C10.1 4.5 9.1 6 8.4 7.6c1 .3 2.1.5 3.1.5V2.8h.8v5.3c1.1 0 2.1-.2 3.1-.5-.4-1-1-2-1.8-2.9-.4-.5-.9-.9-1.3-1.3l.5-.6c.5.4 1 .9 1.4 1.4.8 1 1.5 2 1.9 3.2 1-.4 1.9-.9 2.6-1.4l.5.7c-.8.6-1.7 1.1-2.7 1.4.4 1.1.6 2.2.6 3.4H21v.8h-3.8v.6c-.1.9-.3 1.9-.6 2.8.9.4 1.8.8 2.6 1.4l-.5.7c-.8-.5-1.6-1-2.4-1.3-.7 1.8-1.9 3.4-3.4 4.7l-.5-.6c1.4-1.2 2.5-2.7 3.1-4.3-1-.3-2.1-.5-3.2-.6V21h-.8v-5.3c-1.1 0-2.1.2-3.2.6.4 1.1 1 2.1 1.8 3 .4.5.9.9 1.3 1.3l-.4.6zm-3.5-8.9c0 1.1.2 2.1.5 3.1 1.1-.4 2.3-.6 3.4-.6v-2.5H7.5zm4.9 2.5c1.2 0 2.3.2 3.4.6.3-.8.4-1.7.5-2.5v-.6h-4v2.5zm0-3.3h4c0-1.1-.2-2.1-.6-3.1-1.1.4-2.3.6-3.4.6v2.5zm-4.9 0h4V9c-1.2 0-2.3-.2-3.4-.6-.3.8-.5 1.7-.5 2.6 0 .2 0 .3-.1.5z"/></svg>```.text
#let website-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(website-svg.replace("currentColor", color.to-hex()))))
}

// x
#let x-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M10.9 2.1c-3.5.4-6.6 2.7-8 5.9-.9 2.1-1.1 4.5-.4 6.7.8 2.8 2.9 5.1 5.6 6.3 2.1.9 4.5 1.1 6.7.4 3.3-1 6-3.7 6.8-7.1 1.3-5.3-2-10.8-7.3-12.1-1.2-.1-2.2-.2-3.4-.1zm.2 6.2c.8 1.1 1.6 2.1 1.6 2.1s.9-.9 1.9-2.1l1.9-2.1h1.1l-.2.2c-.1.1-1 1.1-1.9 2.1-.9 1-1.8 2-2 2.2l-.4.3 2.5 3.3c1.4 1.8 2.5 3.3 2.5 3.4 0 0-.8.1-1.8.1h-1.8l-1.7-2.3c-1.2-1.6-1.7-2.2-1.8-2.2 0 0-1 1-2.1 2.3l-2 2.2h-1s1.1-1.2 2.3-2.6c1.3-1.4 2.3-2.5 2.4-2.6 0 0-1-1.5-2.3-3.2C7 7.7 5.9 6.3 5.9 6.2h3.6l1.6 2.1z"/>  <path d="M7.5 7.1s1.7 2.3 3.7 5l3.6 4.9h.8c.5 0 .8 0 .8-.1 0 0-1.7-2.3-3.7-5L9.1 7h-.8c-.7 0-.8 0-.8.1z"/></svg>```.text
#let x-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(x-svg.replace("currentColor", color.to-hex()))))
}

// youtube
#let youtube-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">  <path d="M21.3 7.2c-.2-.8-.9-1.5-1.7-1.7-1.5-.4-7.6-.4-7.6-.4s-6.1 0-7.6.4c-.9.2-1.6.9-1.8 1.7-.4 1.5-.4 4.7-.4 4.7s0 3.2.4 4.7c.2.8.9 1.5 1.7 1.7 1.5.4 7.6.4 7.6.4s6.1 0 7.6-.4c.8-.2 1.5-.9 1.7-1.7.4-1.5.4-4.7.4-4.7s.1-3.2-.3-4.7zm-6.2 4.7L10 14.8V9l5.1 2.9z"/></svg>```.text
#let youtube-icon(color: black, height: 1.1em, baseline: 13.5%) = {
  box(height: height, baseline: baseline, image(bytes(youtube-svg.replace("currentColor", color.to-hex()))))
}