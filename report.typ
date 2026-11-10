#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.7cm, right: 2.7cm),
  numbering: "1",
)
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt")
#set par(justify: true)
#set heading(numbering: "1.")

#align(center)[
  #text(16pt, weight: "bold")[Software Verification]

  #v(0.5cm)
  #text(20pt, weight: "bold")[Handout 2 — Verified Union-Find]

  #v(0.5cm)
  Nova School of Science and Technology — FCT NOVA

  #v(0.7cm)
  *Nome:* [Nome do estudante] \
  *Ano letivo:* 2026/2027
]

#v(1cm)
#outline(title: [Índice])
#pagebreak()

= Introdução

Apresentação breve do objetivo do trabalho: verificar formalmente uma implementação de Union-Find utilizando Why3.

= Data Type Implementation



= Union-Find Invariants

== Exercise 1 — `Valid` predicate

*Especificação:* a preencher.

*Justificação:* explicar o significado de cada invariante e por que razão caracteriza estados válidos de Union-Find.

= Verified Union-Find Operations

== Create operation

=== Exercise 2 — `create`

*Contrato:* a preencher.

*Justificação:* explicar como o estado inicial satisfaz o contrato e os invariantes.

== Find operation

=== Exercise 3 — `find_it`

*Contrato e loop invariants:* a preencher.

mostrar inicialização, preservação, terminação e relação com a post-condition.

=== Exercise 4 — `find`

*Implementação e contrato:* a preencher.

*Justificação:* explicar a recursividade, a terminação e a técnica de path compression.

== Union operation

=== Exercise 5 — `union` specification

*Contrato:* a preencher.

*Justificação:* explicar como os representantes mudam após a união dos grupos.

=== Exercise 6 — `union` branches

*Implementação:* a preencher.

*Justificação:* explicar a escolha do representante em cada ramo.

= Conclusões

Resumo do que foi verificado, dificuldades encontradas e eventuais questões por resolver.
