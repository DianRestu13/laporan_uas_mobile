// conf.typ
#let project(
  title: "",
  semester: "",
  team_number: "",
  members: (),
  body
) = {
  // Setup Dokumen
  set document(author: members.map(m => m.name), title: title)
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    numbering: "1",
  )
  set text(font: "Times New Roman", size: 12pt, lang: "id")
  
  // Setup Heading (Bab & Sub-bab)
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    align(center)[
      #text(size: 14pt, weight: "bold")[BAB #counter(heading).display() \ #it.body]
    ]
    v(1em)
  }

  // Cover Page Logic ada di file terpisah (cover.typ) agar rapi, 
  // tapi kita panggil fungsi layout utamanya di sini.
  
  body
}