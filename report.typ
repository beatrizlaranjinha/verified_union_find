// Relatório revisto, com foco nas decisões e nas provas (sem diff).
#set page(
  paper: "a4",
  margin: (top: 2.3cm, bottom: 2.1cm, left: 2.5cm, right: 2.5cm),
  numbering: "1",
)
#set text(font: "New Computer Modern", size: 10pt, lang: "pt")
#set par(justify: true, leading: 0.54em)
#set heading(numbering: none)
#show heading.where(level: 1): set text(size: 12.4pt, weight: "bold")
#show heading.where(level: 2): set text(size: 11pt, weight: "bold")
#show raw: set text(size: 8.2pt)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: luma(247),
  stroke: luma(225),
  inset: 8pt,
  radius: 2pt,
  breakable: true,
)[#it]

#align(center)[
  #text(size: 17pt, weight: "bold")[Verified Union-Find in Why3]
  #v(0.25em)
  Verificação de Software · NOVA FCT
  #v(0.15em)
  #text(size: 9.4pt)[Handout 2 · Novembro de 2026]
  #v(0.15em)
  #text(size: 9pt)[Beatriz Morais Laranjinha]
]
#v(0.6em)

= Introdução
<introdução>
The objective of this work was to formally specify and verify a *Union-Find* implementation in Why3. This report presents the annotations and design decisions introduced to justify the correctness of the implementation and its associated proofs.


= 1 — Type invariants
<exercise-1-type-invariants>
I implemented the eight #emph[type invariants] specified in the assignment. These can be divided into three groups based on their role in the proof:
- #strong[Invariants 1–3] ensure valid array sizes and indices.
- #strong[Invariants 4, 5, and 7] establish the relationship between the concrete links and the logical representatives.
- #strong[Invariants 6 and 8], together with `0 <= maxd`, provide the properties needed to prove the termination of the `find` operations.


#strong[Preservation.] In `create`, each element is initialized as its own representative, with `link[i] = rep(i) = i` and `dst(i) = 0`. The `find_it` function only reads the arrays, leaving the invariants unchanged. In `find`, path compression updates a link to point directly to the root of the #emph[same equivalence class], preserving valid indices, representative consistency, and the increasing `dst` property. Finally, `union` updates `link`, `rep`, `dst`, and `maxd` to ensure that the invariants remain valid after merging two classes. The correctness of `find` and `union` is discussed in the following sections.

= Exercise 2 — `create`
<exercise-2-create>

```why3
requires { n >= 0 }
ensures  { r.size = n }
ensures  { forall i:int. 0 <= i < n -> r.rep i = i }
```

The #emph[pre-condition] `n >= 0` ensures that the array size is non-negative. The #emph[post-conditions] follow from the assignments `size = n` and `rep = (fun i -> i)`, meaning that each element initially forms its own equivalence class.

All eight #emph[type invariants] are true after `create`.

Invariants 1–5 and 8 hold because the arrays have the correct size, every element is its own representative (`link[i] = rep(i) = i`), and all distances start at zero (`dst(i) = maxd = 0`).

Invariants 6 and 7 are also true homever both use an implication (`->`) that starts with the condition `i <> link[i]`. Since every element initially points to itself, this condition is always false. An implication with a false first condition is considered true, regardless of the second condition. Therefore, both invariants hold.

= Exercise 3 — `find_it`
<exercise-3-find_it>

```why3
invariant { 0 <= y < uf.size }
invariant { uf.rep y = uf.rep x }
invariant { uf.dst x <= uf.dst y }
variant   { uf.maxd - uf.dst y }
```


= Exercise 3 — `find_it`
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

For example, if `maxd = 5` and `dst(y)` increases from 1 to 3 and then to 5, the variant decreases from 4 to 2 and finally to 0.

Since a non-negative integer cannot decrease forever, the loop must terminate.

#strong[Post-conditions.] When the loop finishes, `y = uf.link[y]`, meaning that `y` points to itself. By type invariant 5, `y = rep(y)`.

Since the second loop invariant guarantees that `rep(y) = rep(x)`, we conclude that `y = rep(x)`. This proves the first `ensures`.

The third loop invariant, `dst(x) <= dst(y)`, directly proves the second `ensures`, since the function returns `y`.



= Exercise 4 — Recursive `find`
<exercise-4-find>

We implemented `find` with the same contract as `find_it`, but added #emph[path compression]. After finding the root, the function updates the current element to point directly to it.

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

#strong[Recursive step.] If `x` is not a root, we set `y = link[x]`. The three `assert` statements express properties guaranteed by type invariants 2, 7, and 6.

They guarantee that `y` is a valid index, belongs to the same class as `x`, and has a greater `dst` value. Therefore, the recursive call `find y uf` satisfies its pre-condition.

The recursive call returns `root = rep(y)`. Since `rep(y) = rep(x)`, we know that `root` is also the correct representative of `x`. Its contract also guarantees `dst(y) <= dst(root)`.

#strong[Preservation.] After finding the root, we execute `link[x] <- root`.

This does not change the equivalence class of `x`, since `root` was already its representative. The new link is valid because `root` is a valid index.

We also know that:

```text
dst(x) < dst(y) <= dst(root)
```

Therefore, `dst(x) < dst(root)`, meaning that the new link still satisfies type invariant 6.

Since `x` was not originally a root, and `root = rep(x)`, type invariant 5 also guarantees that `x != root`. Thus, path compression does not incorrectly turn `x` into a root.

The other elements keep the same representatives, so the relevant type invariants remain true after compression.

#strong[Termination.] The variant `uf.maxd - uf.dst x` is non-negative because type invariant 8 guarantees `dst(x) <= maxd`.

In each recursive call, the argument changes from `x` to `y`, where `dst(y) > dst(x)`. Since `maxd` does not change, the variant strictly decreases.

As it cannot decrease indefinitely while remaining non-negative, the recursion must terminate.

#strong[Post-conditions.] The recursive call gives `root = rep(x)`, proving the first `ensures`. Also, since `dst(x) < dst(y) <= dst(root)`, the second `ensures` holds. The function therefore returns the correct representative while preserving the structure's invariants.


#pagebreak()

= Exercise 5 — `union` Contract
<exercise-5-union>

We added two `requires` clauses to guarantee that `i` and `j` are valid indices, allowing us to call `find` on both elements.

We divided the post-conditions into three `ensures`:

```why3
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

We use `old` to compare the state before and after the operation, since `union` modifies `rep`.

#strong[Preservation.] If both elements already have the same root, the function does not modify the structure. Therefore, all three post-conditions are satisfied.

Otherwise, one root is linked to the other, depending on their `rank` values.

The statement `uf.rep <- pure { ... }` updates the logical representatives of the absorbed class to the chosen root, while leaving all other classes unchanged. This ensures that the second and third post-conditions hold.

To preserve the distance invariants, the chosen root receives the value:

```why3
1 + max (uf.dst rep_i) (uf.dst rep_j)
```

This value is strictly greater than the previous distances of both roots, so the newly created link satisfies type invariant 6.

The function also increases `maxd` by one. Since the previous distances were bounded by the old `maxd`, the new distance cannot exceed the updated limit. Therefore, type invariant 8 remains true.

The updates to `link`, `rep`, `dst`, and `maxd` ensure that the structure remains valid after merging the classes.


= Exercise 6 — Return Values
<exercise-6-return>

We replaced the three temporary `ghost 0` values with the representative chosen in each branch of `union`.

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

In this assignment, we completed the specification and verification annotations of a Union-Find implementation in Why3.

The #emph[type invariants] define valid states, the #emph[loop invariants] support the correctness proof of `find_it`, and the #emph[variants] establish termination. The function contracts describe the expected results of `create`, `find`, and `union`.

The main challenge was showing that operations such as #emph[path compression] and class merging preserve the invariants, rather than only returning the correct representative.
