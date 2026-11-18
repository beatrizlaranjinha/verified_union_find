// Verified Union-Find — apresentação académica minimalista.
// Texto original preservado. Apenas os círculos dos esquemas usam rosa.

#set page(
  paper: "a4",
  margin: (top: 2.45cm, bottom: 2.35cm, left: 2.65cm, right: 2.65cm),
  fill: white,
  numbering: "1",
)
#set text(font: "New Computer Modern", size: 11pt, lang: "pt", fill: black)
#set par(justify: true, leading: 0.55em, spacing: 0.64em)
#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 15pt, weight: "bold", fill: black)
#show heading.where(level: 2): set text(size: 12.5pt, weight: "bold", fill: black)
#show heading.where(level: 3): set text(size: 11pt, weight: "bold", fill: black)
#show figure.caption: set text(size: 9pt, fill: black)
#show raw.where(block: true): set text(size: 8.5pt)

#align(center)[
  #v(0.9cm)
  #text(size: 11pt)[Software Verification]
  #v(0.38cm)
  #text(size: 19pt, weight: "bold")[Verified Union-Find]
  #v(0.24cm)
  #text(size: 10pt)[Handout 2]
  #v(0.9cm)
  Nova School of Science and Technology — FCT NOVA
  #v(0.35cm)
  *Nome:* [Nome do estudante] \
  *Ano letivo:* 2026/2027
]

#v(0.9cm)
#outline(title: [Índice])
#pagebreak()

// SVGs integrados: círculos em rosa, restante composição a preto e cinzento.
#let fig1 = bytes("<svg xmlns='http://www.w3.org/2000/svg' width='720' height='225' viewBox='0 0 720 225' role='img'><rect x='0' y='0' width='720' height='225' fill='#FFFFFF'/><defs><marker id='arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker><marker id='orange-arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker></defs><text x='360' y='22' text-anchor='middle' font-family='New Computer Modern,serif' font-size='17' font-weight='700' fill='#222222'>Exemplo: 0 -> 2 -> 4 (raiz)</text><line x1='129' y1='88' x2='326' y2='88' stroke='#555555' stroke-width='2.3'  marker-end='url(#arrow)'/><line x1='394' y1='88' x2='591' y2='88' stroke='#555555' stroke-width='2.3'  marker-end='url(#arrow)'/><circle cx='100' cy='88' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='100' y='94' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>0</text><circle cx='360' cy='88' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='360' y='94' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>2</text><circle cx='620' cy='88' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='620' y='94' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>4</text><path d='M614 61 C575 23 672 18 646 72' fill='none' stroke='#555555' stroke-width='2'/><path d='M639 64 L646 72 L651 60' fill='none' stroke='#555555' stroke-width='2'/><text x='230' y='75' text-anchor='middle' font-family='New Computer Modern,serif' font-size='13' font-weight='400' fill='#555555'>link[0] = 2</text><text x='490' y='75' text-anchor='middle' font-family='New Computer Modern,serif' font-size='13' font-weight='400' fill='#555555'>link[2] = 4</text><text x='620' y='131' text-anchor='middle' font-family='New Computer Modern,serif' font-size='13' font-weight='700' fill='#555555'>link[4] = 4</text><rect x='75' y='160' width='570' height='46' rx='9' fill='#FAFAFA' stroke='#EEEEEE'/><text x='360' y='188' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#222222'>rep(0) = rep(2) = rep(4) = 4   (modelo ghost)</text></svg>")
#let fig2 = bytes("<svg xmlns='http://www.w3.org/2000/svg' width='720' height='216' viewBox='0 0 720 216' role='img'><rect x='0' y='0' width='720' height='216' fill='#FFFFFF'/><defs><marker id='arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker><marker id='orange-arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker></defs><text x='360' y='22' text-anchor='middle' font-family='New Computer Modern,serif' font-size='17' font-weight='700' fill='#555555'>Exemplo de estado inconsistente (proibido)</text><circle cx='177' cy='102' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='177' y='108' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>2</text><circle cx='548' cy='102' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='548' y='108' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>4</text><path d='M168 76 C103 15 255 16 209 87' fill='none' stroke='#555555' stroke-width='2.4'/><path d='M201 77 L209 87 L212 74' fill='none' stroke='#555555' stroke-width='2'/><line x1='210' y1='103' x2='509' y2='103' stroke='#555555' stroke-width='2.3' stroke-dasharray='6 6' marker-end='url(#orange-arrow)'/><text x='176' y='159' text-anchor='middle' font-family='New Computer Modern,serif' font-size='16' font-weight='700' fill='#555555'>link[2] = 2</text><text x='548' y='159' text-anchor='middle' font-family='New Computer Modern,serif' font-size='16' font-weight='700' fill='#555555'>rep(2) = 4</text><text x='362' y='82' text-anchor='middle' font-family='New Computer Modern,serif' font-size='13' font-weight='400' fill='#555555'>ghost rep</text><text x='361' y='198' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='400' fill='#222222'>O algoritmo devolveria 2, mas o modelo exige 4.</text></svg>")
#let fig3 = bytes("<svg xmlns='http://www.w3.org/2000/svg' width='720' height='230' viewBox='0 0 720 230' role='img'><rect x='0' y='0' width='720' height='230' fill='#FFFFFF'/><defs><marker id='arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker><marker id='orange-arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker></defs><text x='345' y='22' text-anchor='middle' font-family='New Computer Modern,serif' font-size='17' font-weight='700' fill='#222222'>Crescimento de dst ao longo dos links</text><rect x='587' y='6' width='114' height='30' rx='10' fill='#FFFFFF' stroke='#555555'/><text x='644' y='26' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='700' fill='#555555'>maxd = 3</text><line x1='139' y1='102' x2='326' y2='102' stroke='#555555' stroke-width='2.3'  marker-end='url(#arrow)'/><line x1='394' y1='102' x2='581' y2='102' stroke='#555555' stroke-width='2.3'  marker-end='url(#arrow)'/><circle cx='110' cy='102' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='110' y='108' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>0</text><text x='110' y='157' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#555555'>dst(0) = 0</text><circle cx='360' cy='102' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='360' y='108' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>2</text><text x='360' y='157' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#555555'>dst(2) = 1</text><circle cx='610' cy='102' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='610' y='108' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>4</text><text x='610' y='157' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#555555'>dst(4) = 3</text><text x='360' y='205' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='400' fill='#222222'>0 &lt; 1 &lt; 3  e  cada distância é &lt;= maxd</text></svg>")
#let fig4 = bytes("<svg xmlns='http://www.w3.org/2000/svg' width='720' height='215' viewBox='0 0 720 215' role='img'><rect x='0' y='0' width='720' height='215' fill='#FFFFFF'/><defs><marker id='arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker><marker id='orange-arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker></defs><text x='360' y='22' text-anchor='middle' font-family='New Computer Modern,serif' font-size='17' font-weight='700' fill='#222222'>create(4): quatro classes independentes</text><circle cx='100' cy='82' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='100' y='88' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>0</text><text x='100' y='133' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='400' fill='#555555'>rep(0) = 0</text><circle cx='270' cy='82' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='270' y='88' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>1</text><text x='270' y='133' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='400' fill='#555555'>rep(1) = 1</text><circle cx='450' cy='82' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='450' y='88' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>2</text><text x='450' y='133' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='400' fill='#555555'>rep(2) = 2</text><circle cx='620' cy='82' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='620' y='88' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>3</text><text x='620' y='133' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='400' fill='#555555'>rep(3) = 3</text><rect x='38' y='160' width='644' height='43' rx='8' fill='#FAFAFA' stroke='#EEEEEE'/><text x='215' y='186' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#222222'>link = [0, 1, 2, 3]</text><text x='532' y='186' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#222222'>rank = [0, 0, 0, 0]</text></svg>")
#let fig5 = bytes("<svg xmlns='http://www.w3.org/2000/svg' width='720' height='252' viewBox='0 0 720 252' role='img'><rect x='0' y='0' width='720' height='252' fill='#FFFFFF'/><defs><marker id='arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker><marker id='orange-arrow' markerWidth='8' markerHeight='8' refX='6.8' refY='3.5' orient='auto'><path d='M0 0 L7 3.5 L0 7 Z' fill='#555555'/></marker></defs><text x='360' y='22' text-anchor='middle' font-family='New Computer Modern,serif' font-size='17' font-weight='700' fill='#222222'>find_it(0): a pesquisa começa em link[0]</text><line x1='166' y1='103' x2='316' y2='103' stroke='#555555' stroke-width='2.3'  marker-end='url(#arrow)'/><line x1='406' y1='103' x2='566' y2='103' stroke='#555555' stroke-width='2.3'  marker-end='url(#arrow)'/><circle cx='130' cy='103' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='130' y='109' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>0</text><circle cx='360' cy='103' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='360' y='109' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>2</text><circle cx='610' cy='103' r='26' fill='#F8E4ED' stroke='#BA7295' stroke-width='2'/><text x='610' y='109' font-size='19' text-anchor='middle' font-family='New Computer Modern,serif' font-weight='700' fill='#222222'>4</text><path d='M604 75 C557 27 680 29 640 91' fill='none' stroke='#555555' stroke-width='2'/><path d='M633 80 L640 91 L644 77' fill='none' stroke='#555555' stroke-width='2'/><text x='130' y='153' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#222222'>x = 0</text><text x='360' y='153' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#555555'>y inicial = 2</text><text x='610' y='153' text-anchor='middle' font-family='New Computer Modern,serif' font-size='15' font-weight='700' fill='#555555'>r = 4 (raiz)</text><rect x='42' y='187' width='635' height='47' rx='9' fill='#FAFAFA' stroke='#EEEEEE'/><text x='360' y='206' text-anchor='middle' font-family='New Computer Modern,serif' font-size='14' font-weight='700' fill='#222222'>y = link[0] = 2   ->   y = link[2] = 4</text><text x='360' y='223' text-anchor='middle' font-family='New Computer Modern,serif' font-size='12' font-weight='400' fill='#555555'>Como link[4] = 4, o while termina e devolve 4.</text></svg>")

= Introdução

wuauwuaaaaaa wua
= Data Type Implementation

A estrutura Union-Find representa os elementos do conjunto de índices de `0` a `size - 1`, usando principalmente dois arrays:

- `link`: indica para que elemento aponta cada posição, permitindo seguir o caminho até à raiz. A raiz aponta para si própria.
- `rank`: informação utilizada pela operação `union` para decidir como ligar duas árvores.

Os campos `ghost`,são usados na especificação e na demonstração das propriedades do algoritmo:

- `size`: número de elementos da estrutura;
- `rep`: função matemática que associa diretamente cada elemento ao representante da sua classe;
- `dst`: função que associa um valor a cada elemento, aumentando estritamente quando se segue um link que não aponta para o próprio elemento;
- `maxd`: limite superior para os valores de `dst` dos elementos válidos.

= Union-Find Invariants

== Exercise 1 — Type invariants (`Valid`)

O objetivo é definir as condições que caracterizam um estado válido da estrutura. Estas propriedades são expressas como *type invariants* do tipo `t`.

=== Especificação


```why3
invariant { 0 <= maxd }
invariant { length link = size /\ length rank = size }
invariant { forall x:int. 0 <= x < size ->
            0 <= link[x] < size }
invariant { forall x:int. 0 <= x < size ->
            0 <= rep x < size }
invariant { forall x:int. 0 <= x < size ->
            rep (rep x) = rep x }
invariant { forall x:int. 0 <= x < size ->
            (x = link[x] <-> x = rep x) }
invariant { forall x:int. 0 <= x < size ->
            x <> link[x] -> dst x < dst (link[x]) }
invariant { forall x:int. 0 <= x < size ->
            x <> link[x] -> rep x = rep (link[x]) }
invariant { forall x:int. 0 <= x < size ->
            dst x <= maxd }
```

=== Justificação

+ *Dimensões dos arrays:* `link` e `rank` têm ambos comprimento igual a `size`. Assim, cada elemento válido tem uma posição em ambos os arrays.
+ *Links válidos:* para cada índice `x` válido, `link[x]` também está no intervalo `0 <= link[x] < size`. Isto garante que seguir um link não provoca um acesso fora dos limites do array.
+ *Representantes válidos:* `rep x` pertence igualmente ao conjunto de índices válidos.
+ *Idempotência de `rep`:* `rep (rep x) = rep x`. O representante de uma raiz é a própria raiz.
+ *Caracterização de uma raiz:* `x = link[x] <-> x = rep x`. Um nó aponta para si próprio se e só se é o representante da respetiva classe.
+ *Crescimento de `dst`:* sempre que `x <> link[x]`, temos `dst x < dst (link[x])`. Ao seguir links não triviais, o valor de `dst` aumenta estritamente.
+ *Preservação do representante:* sempre que `x <> link[x]`, os elementos `x` e `link[x]` têm o mesmo representante. Portanto, percorrer um link não muda a classe de equivalência.
+ *Limite de `dst`:* para todos os elementos válidos, `dst x <= maxd`. Em conjunto com o crescimento estrito, esta propriedade permite obter uma medida decrescente para a terminação.

Como perceber o invariante 5:

#figure(
  image(fig2, format: "svg", width: 80%, alt: "Exemplo inválido: link de 2 aponta para 2, mas o ghost rep de 2 aponta para 4."),
  caption: [Contraexemplo que o invariante 5 impede: se `link[2] = 2`, o representante matemático de `2` também tem de ser `2`, e não `4`.],
)

Como perceber o invariante 6 e 8

#figure(
  image(fig3, format: "svg", width: 83%, alt: "Cadeia de nós 0, 2 e 4 com dst 0, 1 e 3, todos menores ou iguais a maxd."),
  caption: [Exemplo dos invariantes 6 e 8: seguindo os links, `dst` aumenta de 0 para 1 e depois 3, sem ultrapassar `maxd = 3`.],
)

O invariante adicional `0 <= maxd`, já incluído pelo professor, impõe que o limite superior utilizado em `dst` não seja negativo. Por si só, não demonstra a terminação, mas faz parte da especificação do estado válido.

=== Consistência do tipo

O construtor `by` disponibiliza uma testemunha de que existe uma estrutura que satisfaz os invariantes: uma Union-Find vazia, com `size = 0`, arrays vazios, `rep` igual à identidade, `dst` constante a zero e `maxd = 0`. As propriedades quantificadas sobre índices válidos são então verdadeiras, pois não existem índices no intervalo `0 <= x < 0`.

A obrigação `t'vc` associada ao `by` foi observada como demonstrada no Why3 IDE. Esta verificação não substitui as provas de preservação dos invariantes pelas operações.

= Verified Union-Find Operations

== Create operation

=== Exercise 2 — `create`

A função `create(n)` constrói uma estrutura com `n` elementos, inicialmente separados, ou seja, cada elemento é representante de si próprio. Não foi necessário alterar a implementação fornecida.

*Contrato proposto:*

```why3
let create (n: int) : (r: t)
  requires { n >= 0 }
  ensures  { r.size = n }
  ensures  { forall i:int. 0 <= i < n -> r.rep i = i }
```

A *precondition* `n >= 0` é necessária para criar arrays com um comprimento válido. A primeira *postcondition* estabelece que o número de elementos da estrutura é exatamente `n`. A segunda indica que, no estado inicial, todos os elementos pertencem a classes individuais, pois `rep i = i`.

=== Justificação da correção

O código inicializa `link` com `init n (fun i -> i)`, pelo que todos os índices apontam para si próprios, e cria `rank` com `n` entradas iguais a zero. Define ainda `rep` como a identidade, `dst` como a função constante zero e `maxd = 0`.

#figure(
  image(fig4, format: "svg", width: 85%, alt: "Quatro nós isolados 0, 1, 2 e 3; link de cada nó é ele próprio e rank todos zero."),
  caption: [Estado produzido por `create(4)`: cada elemento constitui uma classe isolada e é o seu próprio representante.],
)

Deste modo, `link` e `rank` têm o comprimento esperado, os links e representantes são válidos, cada elemento é a sua própria raiz e os invariantes relativos a links não triviais são satisfeitos de forma imediata. Como `dst i = 0` e `maxd = 0`, os limites das distâncias também se verificam. A construção satisfaz assim o contrato proposto e os *type invariants*.

*Estado da prova:* é necessário confirmar no Why3 IDE que a obrigação `create'vc` está demonstrada antes de declarar formalmente concluído o exercício.

== Find operation

=== Exercise 3 — `find_it`

A função iterativa `find_it(x, uf)` encontra o representante de `x` seguindo os links até alcançar um elemento que aponta para si próprio. A implementação fornecida começa com `y = uf.link[x]` e, enquanto `y <> uf.link[y]`, atualiza `y` para `uf.link[y]`.

#figure(
  image(fig5, format: "svg", width: 84%, alt: "Find iterativo parte de x igual a 0, y começa em 2, depois passa para 4, a raiz."),
  caption: [Execução de `find_it(0)`: a variável `y` inicia-se em `link[0] = 2`, segue para `4` e o ciclo termina quando `link[4] = 4`.],
)

*Contrato proposto:*

```why3
let find_it (x: int) (uf: t) : (r: int)
  requires { 0 <= x < uf.size }
  ensures  { r = uf.rep x }
  ensures  { uf.dst x <= uf.dst r }
```

A *precondition* exige que `x` seja um índice válido, porque a implementação consulta `uf.link[x]`. A primeira *postcondition* garante que o valor devolvido `r` é o representante de `x`. A segunda garante que o valor de `dst` da raiz não é inferior ao do elemento inicial, conforme exigido pelo enunciado.

=== Loop invariants e variant

Para verificar o ciclo `while`, foram propostas as seguintes anotações, sem alterar a sua implementação:

```why3
while y <> uf.link[y] do
  invariant { 0 <= y < uf.size }
  invariant { uf.rep y = uf.rep x }
  invariant { uf.dst x <= uf.dst y }
  variant   { uf.maxd - uf.dst y }
  y <- uf.link[y]
done;
```

O primeiro invariante garante que `y` se mantém dentro dos limites do array, tornando seguros os acessos a `uf.link[y]`. O segundo garante que `y` continua na classe de equivalência de `x`. O terceiro regista que a distância associada ao elemento atual nunca é inferior à distância inicial, propriedade necessária para a segunda *postcondition*.

=== Inicialização e preservação dos invariantes

*Inicialização.* Antes do ciclo, `y = uf.link[x]`. Como `x` é válido e o tipo garante que todos os links também são válidos, `y` é válido. O invariante 7 do tipo garante que `rep` não muda ao seguir um link não trivial; se `x` já for raiz, a igualdade é imediata. Assim, `uf.rep y = uf.rep x`. Pela propriedade de crescimento de `dst`, temos `uf.dst x <= uf.dst y`, com igualdade quando `x` já é raiz.

*Preservação.* Em cada iteração executamos `y <- uf.link[y]`. O novo `y` continua válido pelo invariante 2 do tipo, mantém o mesmo representante pelo invariante 7 e tem `dst` estritamente maior pelo invariante 6, porque a guarda do ciclo assegura `y <> uf.link[y]`. Consequentemente, os três invariantes do ciclo são preservados.

=== Terminação e postconditions

O *variant* `uf.maxd - uf.dst y` é um inteiro não negativo para qualquer `y` válido, devido ao invariante `dst y <= maxd`. Quando o corpo do ciclo é executado, `dst y` aumenta estritamente, pelo que o *variant* diminui estritamente. Como não pode continuar a diminuir indefinidamente, o ciclo termina.

Quando o ciclo termina, a guarda é falsa e temos `y = uf.link[y]`. Pelo invariante 5 do tipo, isto implica `y = uf.rep y`. Como o segundo invariante do ciclo garante `uf.rep y = uf.rep x`, concluímos `y = uf.rep x`. A função devolve `r = y`, obtendo-se a primeira *postcondition*. O terceiro invariante do ciclo implica diretamente `uf.dst x <= uf.dst r`, que é a segunda *postcondition*.

*Estado da prova:* é necessário confirmar no Why3 IDE as obrigações associadas a `find_it'vc`, incluindo a terminação do `while`, antes de declarar a função formalmente verificada.

=== Exercise 4 — `find`

A completar: implementação recursiva, *path compression*, contrato e prova de terminação.

== Union operation

=== Exercise 5 — `union` specification

A completar: especificação das alterações aos representantes após a união de duas classes.

=== Exercise 6 — `union` branches

A completar: valores `ghost` devolvidos nos diferentes ramos da função.

= Conclusões

A completar após a conclusão dos exercícios 4 a 6 e a verificação final de todas as obrigações de prova. Até esta fase, foram definidos os *type invariants* e propostas as especificações de `create` e `find_it`, incluindo uma justificação de correção e de terminação do ciclo. A confirmação das provas das operações deverá ser registada com base na sessão Why3.
