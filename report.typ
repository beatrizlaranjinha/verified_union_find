// Report revised for grammar, consistency and page breaks. No code diff.
#set page(
  paper: "a4",
  margin: (top: 2.3cm, bottom: 2.1cm, left: 2.5cm, right: 2.5cm),
  numbering: "1",
)
#set text(font: "New Computer Modern", size: 10pt, lang: "en")
#set par(justify: true, leading: 0.54em)
#set heading(numbering: none)
#show heading.where(level: 1): set text(size: 12.4pt, weight: "bold")
#show heading.where(level: 2): set text(size: 11pt, weight: "bold")
#show raw: set text(size: 8.2pt)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: rgb("#FFF0F6"),
  stroke: rgb("#E8BDD2"),
  inset: 10pt,
  radius: 4pt,
  breakable: true,
)[#it]

#let node(n) = box(
  width: 26pt,
  height: 26pt,
  radius: 50%,
  fill: rgb("#FFF0F6"),
  stroke: 1pt + rgb("#E8BDD2"),
  inset: 0pt,
)[
  #align(center + horizon)[
    #text(size: 9pt, weight: "bold")[#n]
  ]
]

#align(center)[
  #text(size: 17pt, weight: "bold")[Verified Union-Find in Why3]
  #v(0.25em)
  Verificação de Software · NOVA FCT
  #v(0.15em)
  #text(size: 9.4pt)[Handout 2 · November 2026]
  #v(0.15em)
  #text(size: 9pt)[Beatriz Morais Laranjinha]
]
#v(0.6em)

= Introduction
<introduction>
The objective of this work was to formally specify and verify a *Union-Find* implementation in Why3. This report presents the annotations and design decisions introduced to justify the correctness of the implementation and its associated proofs.

= Exercise 1 — Type Invariants
<exercise-1-type-invariants>
The eight #emph[type invariants] from the assignment were implemented and can be divided into three groups according to their role in the verification process:
- #strong[Invariants 1–3] ensure valid array sizes and indices.
- #strong[Invariants 4, 5, and 7] ensure that the logical representatives are consistent with the concrete links.
- #strong[Invariants 6 and 8] provide the bounds and strict progress needed to prove termination of the `find` operations.

#strong[Preservation.] In `create`, each element is initialized as its own representative, with `link[i] = rep(i) = i` and `dst(i) = 0`. The `find_it` function only reads the arrays, leaving the invariants unchanged. In `find`, path compression updates a link to point directly to the root of the #emph[same equivalence class], preserving valid indices, representative consistency (because `root = rep(x)`) and the increasing `dst` property. Finally, `union` updates `link`, `rep`, `dst`, and `maxd` to ensure that the invariants remain valid after merging two classes. The correctness of `find` and `union` is discussed in the following sections.

= Exercise 2 — create
<exercise-2-create>

```why3
requires { n >= 0 }
ensures  { r.size = n }
ensures  { forall i:int. 0 <= i < n -> r.rep i = i }
```

The #emph[pre-condition] `n >= 0` ensures that the array size is non-negative. The #emph[post-conditions] follow from the assignments `size = n` and `rep = (fun i -> i)`, meaning that each element initially forms its own equivalence class.

All eight #emph[type invariants] are true after `create`.

Invariants 1–5 and 8 hold because the arrays have the correct size, every element is its own representative (`link[i] = rep(i) = i`), and all distances start at zero (`dst(i) = maxd = 0`).

Invariants 6 and 7 are also true. Both use an implication (`->`) that starts with the condition `i <> link[i]`. Since every element initially points to itself, this condition is always false. An implication with a false first condition is considered true, regardless of the second condition. Therefore, both invariants hold.

#pagebreak()

= Exercise 3 — find_it
<exercise-3-find_it>

```why3
invariant { 0 <= y < uf.size }
invariant { uf.rep y = uf.rep x }
invariant { uf.dst x <= uf.dst y }
variant   { uf.maxd - uf.dst y }
```

#strong[Initialization.] Before the first iteration, `y = uf.link[x]`. Type invariant 2 guarantees that `y` is a valid index.

If `x` is already a root, then `y = x`, so the other two loop invariants hold because both sides are equal. Otherwise, type invariant 7 guarantees that `x` and `y` have the same representative, while type invariant 6 guarantees that `dst(x) < dst(y)`. Therefore, all three loop invariants are initially true.

#strong[Preservation.] The loop executes only when `y != uf.link[y]`. Each iteration updates `y` to `uf.link[y]`.
Type invariant 2 guarantees that the new `y` remains a valid index. Type invariant 7 guarantees that following a link does not change the representative, so `rep(y) = rep(x)` remains true. Finally, type invariant 6 guarantees that `dst(y)` increases when following a link, preserving `dst(x) <= dst(y)`.

Therefore, all three loop invariants remain true after every iteration.

#strong[Termination.] The variant `uf.maxd - uf.dst y` is always non-negative because type invariant 8 guarantees that `dst(y) <= maxd`.

At each iteration, `dst(y)` strictly increases (type invariant 6), while `maxd` remains unchanged. Therefore, the variant strictly decreases.

// ______________
#let pink = rgb("#FFF0F6")
#let pink-border = rgb("#E8BDD2")
#let step(dst, variant) = stack(
  dir: ttb,
  spacing: 3pt,
  circle(
    radius: 19pt,
    fill: pink,
    stroke: (paint: pink-border, thickness: 1pt),
  )[
    #set align(center + horizon)
    #text(size: 9pt, weight: "bold")[#variant]
  ],
  align(center)[#text(size: 7pt)[dst = #dst]],
)

#align(center)[
  #text(size: 8pt)[`maxd = 5`]
  #v(5pt)
  #grid(
    columns: (auto, auto, auto, auto, auto),
    gutter: 10pt,
    align: center + horizon,
    step(1, 4),
    [→],
    step(3, 2),
    [→],
    step(5, 0),
  )
  #v(3pt)
  #text(size: 7.5pt)[Variant = `maxd - dst(y)`]
]
// ______________

Since a non-negative integer cannot decrease forever, the loop must terminate.

#strong[Post-conditions.] When the loop finishes, `y = uf.link[y]`, meaning that `y` points to itself. By type invariant 5, `y = rep(y)`.

Since the second loop invariant guarantees that `rep(y) = rep(x)`, we conclude that `y = rep(x)`. This proves the first `ensures`.

The third loop invariant guarantees that `dst(x) <= dst(y)` remains true throughout the loop. When the function returns `y`, this value becomes the result `r`. Therefore, `dst(x) <= dst(r)`, satisfying the second `ensures`.

= Exercise 4 — Recursive find
<exercise-4-find>

 This is `find` with the same contract as `find_it`, adding #emph[path compression]. After finding the root, the function updates the current element to point directly to it.

```why3
variant { uf.maxd - uf.dst x }
= if uf.link[x] = x then
    x
  else
    let y = uf.link[x] in
    assert { 0 <= y < uf.size };
    assert { uf.rep y = uf.rep x };
    assert { uf.dst x < uf.dst y };
    let root = find y uf in
    uf.link[x] <- root;
    root
```

#strong[Base case.] If `link[x] = x`, then `x` is already a root. By type invariant 5, `x = rep(x)`, so returning `x` satisfies the first `ensures`. The second `ensures` also holds because `dst(x) <= dst(x)` is always true.

#strong[Recursive step.] If `x` is not a root, we set `y = link[x]`. The three `assert` statements follow from type invariants 2, 7, and 6, ensuring that `y` is a valid index, has the same representative as `x`, and satisfies `dst(x) < dst(y)`.

Therefore, the recursive call `find y uf` satisfies its pre-condition and returns `root = rep(y) = rep(x)`, with `dst(y) <= dst(root)`.

#strong[Invariant Preservation.] After the recursive call, `link[x] <- root` makes `x` point directly to its representative without changing its equivalence class.

Since `root` is valid and `dst(x) < dst(y) <= dst(root)`, the new link preserves type invariants 2, 6, and 7.

Also, because `x` was not a root, type invariant 5 guarantees `x != root`, so path compression does not incorrectly make `x` a root. The remaining type invariants are unaffected.

#align(center)[
  #text(size: 8pt, weight: "bold")[Before]
  #v(3pt)
  #grid(
    columns: (auto, auto, auto, auto, auto),
    gutter: 7pt,
    align: center + horizon,
    node(0), [→], node(2), [→], node(4),
  )
  #v(7pt)
  #text(size: 8pt, weight: "bold")[After]
  #v(3pt)
  #grid(
    columns: (auto, auto, auto, auto, auto),
    gutter: 7pt,
    align: center + horizon,
    node(0), [→], node(4), [←], node(2),
  )
  #v(4pt)
  #text(size: 7.5pt)[Path compression preserves the representative.]
]

#strong[Termination.] The variant `uf.maxd - uf.dst x` is non-negative because type invariant 8 guarantees `dst(x) <= maxd`.

In each recursive call, the argument changes from `x` to `y`, where `dst(y) > dst(x)`. Since `maxd` does not change, the variant strictly decreases.

As it cannot decrease indefinitely while remaining non-negative, the recursion must terminate.

#strong[Post-conditions.] The recursive call gives `root = rep(x)`, proving the first `ensures`. Also, since `dst(x) < dst(y) <= dst(root)`, the second `ensures` holds. The function therefore returns the correct representative while preserving the structure's invariants.


= Exercise 5 — union
<exercise-5-union>


```why3
requires { 0 <= i < uf.size }
requires { 0 <= j < uf.size }

ensures {
  old_rep = old (uf.rep i) \/
  old_rep = old (uf.rep j)
}
ensures {
  forall w:int. 0 <= w < uf.size ->
    (old (uf.rep w) = old (uf.rep i) \/
     old (uf.rep w) = old (uf.rep j)) ->
    uf.rep w = old_rep
}
ensures {
  forall w:int. 0 <= w < uf.size ->
    (old (uf.rep w) <> old (uf.rep i) /\
     old (uf.rep w) <> old (uf.rep j)) ->
    uf.rep w = old (uf.rep w)
}
```

The first `ensures` guarantees that the chosen representative is one of the two original roots.

The second guarantees that every element belonging to either of the two classes has `old_rep` as its new representative.

The third guarantees that elements belonging to other classes keep their original representatives.

`old` is used to compare the state before and after the operation, since `union` modifies `rep`.

#strong[Preservation.] If `rep_i = rep_j`, both elements already belong to the same class, so no merge is needed. The calls to `find` may change the links through path compression, but they do not change the representatives. Therefore, the three post-conditions still hold.

When the roots are different, the function merges the two classes by selecting one representative. This guarantees that both classes share the same representative, while the other classes remain unchanged, satisfying the second and third `ensures`.

To preserve the distance invariants, the chosen root receives the value:

```why3
1 + max (uf.dst rep_i) (uf.dst rep_j)
```

This value is strictly greater than the previous distances of both roots, so the newly created link satisfies type invariant 6.

The function also increases `maxd` by one. Since the previous distances were bounded by the old `maxd`, the new distance cannot exceed the updated limit. Therefore, type invariant 8 remains true.

The updates to `link`, `rep`, `dst`, and `maxd` ensure that the structure remains valid after merging the classes.

#strong[Post-conditions.] Treturned `ghost` value is the chosen representative, satisfying the first `ensures`. Together with the updates to `rep`, the function also satisfies the remaining post-conditions.

= Exercise 6 — Return Values
<exercise-6-return>

The three temporary `ghost 0` values were replaced with the representative chosen in each branch of `union`.

#table(
  columns: (1.4fr, 1fr, 2fr),
  inset: 6pt,
  [*Condition*], [*Return value*], [*Reason*],
  [`rank[rep_i] > rank[rep_j]`],
  [`ghost rep_i`],
  [`rep_j` is linked to `rep_i`, so `rep_i` becomes the root.],
  [Different roots and `rank[rep_i] <= rank[rep_j]`],
  [`ghost rep_j`],
  [`rep_i` is linked to `rep_j`, so `rep_j` becomes the root.],
  [`rep_i = rep_j`],
  [`ghost rep_i`],
  [Both elements already have the same representative, so no union is needed.],
)

#strong[Correctness.] In each case, the returned value matches the representative selected by the operation.

Since `rep_i` and `rep_j` are the original roots obtained by `find`, the returned `old_rep` always satisfies the first `ensures` of Exercise 5.

Together with the updates to `rep`, this also guarantees that every element in the merged class has the chosen representative.


= Conclusion
<conclusion>
This work allowed us to formally verify the main Union-Find operations in Why3. By using contracts, invariants, and variants, we justified their correctness, termination, and preservation of the data structure's properties.
