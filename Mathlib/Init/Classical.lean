/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad, Mario Carneiro
-/
import Mathlib.Tactic.IrreducibleDef
import Mathlib.Mathport.Rename

/-!
# Note about `Mathlib/Init/`
The files in `Mathlib/Init` are leftovers from the port from Mathlib3.
(They contain content moved from lean3 itself that Mathlib needed but was not moved to lean4.)

We intend to move all the content of these files out into the main `Mathlib` directory structure.
Contributions assisting with this are appreciated.

`#align` statements without corresponding declarations
(i.e. because the declaration is in Batteries or Lean) can be left here.
These will be deleted soon so will not significantly delay deleting otherwise empty `Init` files.

### alignments from lean 3 `init.classical`
-/

namespace Classical

#align classical.inhabited_of_nonempty Classical.inhabited_of_nonempty
#align classical.inhabited_of_exists Classical.inhabited_of_exists

attribute [local instance] propDecidable
attribute [local instance] decidableInhabited

alias axiom_of_choice := axiomOfChoice -- TODO: fix in core
alias prop_complete := propComplete -- TODO: fix in core

@[elab_as_elim] theorem cases_true_false (p : Prop → Prop)
    (h1 : p True) (h2 : p False) (a : Prop) : p a :=
  Or.elim (prop_complete a) (fun ht : a = True ↦ ht.symm ▸ h1) fun hf : a = False ↦ hf.symm ▸ h2

theorem cases_on (a : Prop) {p : Prop → Prop} (h1 : p True) (h2 : p False) : p a :=
  @cases_true_false p h1 h2 a

theorem cases {p : Prop → Prop} (h1 : p True) (h2 : p False) (a) : p a := cases_on a h1 h2
#align classical.cases Classical.cases

alias by_cases := byCases
alias by_contradiction := byContradiction

theorem eq_false_or_eq_true (a : Prop) : a = False ∨ a = True := (prop_complete a).symm

end Classical
