// Fonts
#let body = "Noto Sans"
#let serif = "Noto Serif"

#set page(margin: 1in)
#set text(font: body, size: 11pt, leading: 1.5em)
#set heading(font: serif, weight: "bold", fill: rgb("#2e604d"))

#show heading.where(level: 1): it => [
  #set text(size: 16pt)
  #it
  #rule(length: 100%)
]

#let header(content) = {
  place(top + center, [mantraOS Educational Kit])
}
#let footer(content) = {
  place(bottom + center, [🐉 Ahimsa: do no harm — github.com/kae3g/mantraOS — Page #counter(page)])
}

#page(header: header, footer: footer, body: it => it)
