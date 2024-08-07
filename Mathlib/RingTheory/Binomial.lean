/-
Copyright (c) 2023 Scott Carnahan. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Carnahan
-/
import Mathlib.Algebra.Polynomial.Smeval
import Mathlib.GroupTheory.GroupAction.Ring
import Mathlib.RingTheory.Polynomial.Pochhammer

/-!
# Binomial rings

In this file we introduce the binomial property as a mixin, and define the `multichoose`
and `choose` functions generalizing binomial coefficients.

According to our main reference [elliott2006binomial] (which lists many equivalent conditions), a
binomial ring is a torsion-free commutative ring `R` such that for any `x ∈ R` and any `k ∈ ℕ`, the
product `x(x-1)⋯(x-k+1)` is divisible by `k!`. The torsion-free condition lets us divide by `k!`
unambiguously, so we get uniquely defined binomial coefficients.

The defining condition doesn't require commutativity or associativity, and we get a theory with
essentially the same power by replacing subtraction with addition. Thus, we consider any additive
commutative monoid with a notion of natural number exponents in which multiplication by positive
integers is injective, and demand that the evaluation of the ascending Pochhammer polynomial
`X(X+1)⋯(X+(k-1))` at any element is divisible by `k!`. The quotient is called `multichoose r k`,
because for `r` a natural number, it is the number of multisets of cardinality `k` taken from a type
of cardinality `n`.

## References

* [J. Elliott, *Binomial rings, integer-valued polynomials, and λ-rings*][elliott2006binomial]

## TODO

* Generalized versions of basic identities of Nat.choose.
Further results in Elliot's paper:
* A CommRing is binomial if and only if it admits a λ-ring structure with trivial Adams operations.
* The free commutative binomial ring on a set `X` is the ring of integer-valued polynomials in the
variables `X`.  (also, noncommutative version?)
* Given a commutative binomial ring `A` and an `A`-algebra `B` that is complete with respect to an
ideal `I`, formal exponentiation induces an `A`-module structure on the multiplicative subgroup
`1 + I`.

-/
section Multichoose

open Function Polynomial

/-- A binomial ring is a ring for which ascending Pochhammer evaluations are uniquely divisible by
suitable factorials. We define this notion for a additive commutative monoids with natural number
powers, but retain the ring name. We introduce `Ring.multichoose` as the uniquely defined
quotient. -/
class BinomialRing (R : Type*) [AddCommMonoid R] [Pow R ℕ] where
  /-- Scalar multiplication by positive integers is injective -/
  nsmul_right_injective (n : ℕ) (h : n ≠ 0) : Injective (n • · : R → R)
  /-- A multichoose function, giving the quotient of Pochhammer evaluations by factorials. -/
  multichoose : R → ℕ → R
  /-- The `n`th ascending Pochhammer polynomial evaluated at any element is divisible by n! -/
  factorial_nsmul_multichoose (r : R) (n : ℕ) :
    n.factorial • multichoose r n = (ascPochhammer ℕ n).smeval r

namespace Ring

variable {R : Type*} [AddCommMonoid R] [Pow R ℕ] [BinomialRing R]

theorem nsmul_right_injective (n : ℕ) (h : n ≠ 0) :
    Injective (n • · : R → R) := BinomialRing.nsmul_right_injective n h

/-- The multichoose function is the quotient of ascending Pochhammer evaluation by the corresponding
factorial. When applied to natural numbers, `multichoose k n` describes choosing a multiset of `n`
items from a type of size `k`, i.e., choosing with replacement. -/
def multichoose (r : R) (n : ℕ) : R := BinomialRing.multichoose r n

@[simp]
theorem multichoose_eq_multichoose (r : R) (n : ℕ) :
    BinomialRing.multichoose r n = multichoose r n := rfl

theorem factorial_nsmul_multichoose_eq_ascPochhammer (r : R) (n : ℕ) :
    n.factorial • multichoose r n = (ascPochhammer ℕ n).smeval r :=
  BinomialRing.factorial_nsmul_multichoose r n

@[simp]
theorem multichoose_zero_right' (r : R) : multichoose r 0 = r ^ 0 := by
  refine nsmul_right_injective (Nat.factorial 0) (Nat.factorial_ne_zero 0) ?_
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, ascPochhammer_zero, smeval_one, Nat.factorial]

theorem multichoose_zero_right [MulOneClass R] [NatPowAssoc R]
    (r : R) : multichoose r 0 = 1 := by
  rw [multichoose_zero_right', npow_zero]

@[simp]
theorem multichoose_one_right' (r : R) : multichoose r 1 = r ^ 1 := by
  refine nsmul_right_injective (Nat.factorial 1) (Nat.factorial_ne_zero 1) ?_
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, ascPochhammer_one, smeval_X, Nat.factorial_one,
    one_smul]

theorem multichoose_one_right [MulOneClass R] [NatPowAssoc R] (r : R) : multichoose r 1 = r := by
  rw [multichoose_one_right', npow_one]

variable {R : Type*} [NonAssocSemiring R] [Pow R ℕ] [NatPowAssoc R] [BinomialRing R]

@[simp]
theorem multichoose_zero_succ (k : ℕ) : multichoose (0 : R) (k + 1) = 0 := by
  refine nsmul_right_injective (Nat.factorial (k + 1)) (Nat.factorial_ne_zero (k + 1)) ?_
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, smul_zero, ascPochhammer_succ_left,
    smeval_X_mul, zero_mul]

theorem ascPochhammer_succ_succ (r : R) (k : ℕ) :
    smeval (ascPochhammer ℕ (k + 1)) (r + 1) = Nat.factorial (k + 1) • multichoose (r + 1) k +
    smeval (ascPochhammer ℕ (k + 1)) r := by
  nth_rw 1 [ascPochhammer_succ_right, ascPochhammer_succ_left, mul_comm (ascPochhammer ℕ k)]
  simp only [smeval_mul, smeval_comp ℕ _ _ r, smeval_add, smeval_X]
  rw [Nat.factorial, mul_smul, factorial_nsmul_multichoose_eq_ascPochhammer]
  simp only [smeval_one, npow_one, npow_zero, one_smul]
  rw [← C_eq_natCast, smeval_C, npow_zero, add_assoc, add_mul, add_comm 1, @nsmul_one, add_mul]
  rw [← @nsmul_eq_mul, @add_rotate', @succ_nsmul, add_assoc]
  simp_all only [Nat.cast_id, nsmul_eq_mul, one_mul]

theorem multichoose_succ_succ (r : R) (k : ℕ) :
    multichoose (r + 1) (k + 1) = multichoose r (k + 1) + multichoose (r + 1) k := by
  refine nsmul_right_injective (Nat.factorial (k + 1)) (Nat.factorial_ne_zero (k + 1)) ?_
  simp only [factorial_nsmul_multichoose_eq_ascPochhammer, smul_add]
  rw [add_comm (smeval (ascPochhammer ℕ (k+1)) r), ascPochhammer_succ_succ r k]

@[simp]
theorem multichoose_one (k : ℕ) : multichoose (1 : R) k = 1 := by
  induction k with
  | zero => exact multichoose_zero_right 1
  | succ n ih =>
    rw [show (1 : R) = 0 + 1 by exact (@zero_add R _ 1).symm, multichoose_succ_succ,
      multichoose_zero_succ, zero_add, zero_add, ih]

theorem multichoose_two (k : ℕ) : multichoose (2 : R) k = k + 1 := by
  induction k with
  | zero =>
    rw [multichoose_zero_right, Nat.cast_zero, zero_add]
  | succ n ih =>
    rw [one_add_one_eq_two.symm, multichoose_succ_succ, multichoose_one, one_add_one_eq_two, ih,
      Nat.cast_succ, add_comm]

end Ring

end Multichoose

section Pochhammer

namespace Polynomial

theorem ascPochhammer_smeval_cast (R : Type*) [Semiring R] {S : Type*} [NonAssocSemiring S]
    [Pow S ℕ] [Module R S] [IsScalarTower R S S] [NatPowAssoc S]
    (x : S) (n : ℕ) : (ascPochhammer R n).smeval x = (ascPochhammer ℕ n).smeval x := by
  induction' n with n hn
  · simp only [Nat.zero_eq, ascPochhammer_zero, smeval_one, one_smul]
  · simp only [ascPochhammer_succ_right, mul_add, smeval_add, smeval_mul_X, ← Nat.cast_comm]
    simp only [← C_eq_natCast, smeval_C_mul, hn, ← nsmul_eq_smul_cast R n]
    simp only [nsmul_eq_mul, Nat.cast_id]

variable {R S : Type*}

theorem ascPochhammer_smeval_eq_eval [Semiring R] (r : R) (n : ℕ) :
    (ascPochhammer ℕ n).smeval r = (ascPochhammer R n).eval r := by
  rw [eval_eq_smeval, ascPochhammer_smeval_cast R]

variable [NonAssocRing R] [Pow R ℕ] [NatPowAssoc R]

theorem descPochhammer_smeval_eq_ascPochhammer (r : R) (n : ℕ) :
    (descPochhammer ℤ n).smeval r = (ascPochhammer ℕ n).smeval (r - n + 1) := by
  induction n with
  | zero => simp only [descPochhammer_zero, ascPochhammer_zero, smeval_one, npow_zero]
  | succ n ih =>
    rw [Nat.cast_succ, sub_add, add_sub_cancel_right, descPochhammer_succ_right, smeval_mul, ih,
      ascPochhammer_succ_left, X_mul, smeval_mul_X, smeval_comp, smeval_sub, ← C_eq_natCast,
      smeval_add, smeval_one, smeval_C]
    simp only [smeval_X, npow_one, npow_zero, zsmul_one, Int.cast_natCast, one_smul]

theorem descPochhammer_smeval_eq_descFactorial (n k : ℕ) :
    (descPochhammer ℤ k).smeval (n : R) = n.descFactorial k := by
  induction k with
  | zero =>
    rw [descPochhammer_zero, Nat.descFactorial_zero, Nat.cast_one, smeval_one, npow_zero, one_smul]
  | succ k ih =>
    rw [descPochhammer_succ_right, Nat.descFactorial_succ, smeval_mul, ih, mul_comm, Nat.cast_mul,
      smeval_sub, smeval_X, smeval_natCast, npow_one, npow_zero, nsmul_one]
    by_cases h : n < k
    · simp only [Nat.descFactorial_eq_zero_iff_lt.mpr h, Nat.cast_zero, zero_mul]
    · rw [Nat.cast_sub <| not_lt.mp h]

theorem ascPochhammer_smeval_neg_eq_descPochhammer (r : R) (k : ℕ) :
    (ascPochhammer ℕ k).smeval (-r) = (-1)^k * (descPochhammer ℤ k).smeval r := by
  induction k with
  | zero => simp only [ascPochhammer_zero, descPochhammer_zero, smeval_one, npow_zero, one_mul]
  | succ k ih =>
    simp only [ascPochhammer_succ_right, smeval_mul, ih, descPochhammer_succ_right, sub_eq_add_neg]
    have h : (X + (k : ℕ[X])).smeval (-r) = - (X + (-k : ℤ[X])).smeval r := by
      simp only [smeval_add, smeval_X, npow_one, smeval_neg, smeval_natCast, npow_zero, nsmul_one]
      abel
    rw [h, ← neg_mul_comm, neg_mul_eq_neg_mul, ← mul_neg_one, ← neg_npow_assoc, npow_add, npow_one]

end Polynomial

end Pochhammer

section Basic_Instances

open Polynomial

instance Nat.instBinomialRing : BinomialRing ℕ where
  nsmul_right_injective n hn r s hrs := Nat.eq_of_mul_eq_mul_left (Nat.pos_of_ne_zero hn) hrs
  multichoose n k := Nat.choose (n + k - 1) k
  factorial_nsmul_multichoose r n := by
    rw [smul_eq_mul, ← Nat.descFactorial_eq_factorial_mul_choose,
      ← eval_eq_smeval r (ascPochhammer ℕ n), ascPochhammer_nat_eq_descFactorial]

/-- The multichoose function for integers. -/
def Int.multichoose (n : ℤ) (k : ℕ) : ℤ :=
  match n with
  | ofNat n => (Nat.choose (n + k - 1) k : ℤ)
  | negSucc n => (-1) ^ k * Nat.choose (n + 1) k

instance Int.instBinomialRing : BinomialRing ℤ where
  nsmul_right_injective n hn r s hrs := Int.eq_of_mul_eq_mul_left (Int.ofNat_ne_zero.mpr hn) hrs
  multichoose := Int.multichoose
  factorial_nsmul_multichoose r k := by
    rw [Int.multichoose, nsmul_eq_mul]
    cases r with
    | ofNat n =>
      simp only [multichoose, nsmul_eq_mul, Int.ofNat_eq_coe, Int.ofNat_mul_out]
      rw [← Nat.descFactorial_eq_factorial_mul_choose, smeval_at_natCast, ← eval_eq_smeval n,
        ascPochhammer_nat_eq_descFactorial]
    | negSucc n =>
      simp only [Int.multichoose, nsmul_eq_mul]
      rw [mul_comm, mul_assoc, ← Nat.cast_mul, mul_comm _ (k.factorial),
        ← Nat.descFactorial_eq_factorial_mul_choose, ← descPochhammer_smeval_eq_descFactorial,
        ← Int.neg_ofNat_succ, ascPochhammer_smeval_neg_eq_descPochhammer]

noncomputable instance {R : Type*} [AddCommMonoid R] [Module ℚ≥0 R] [Pow R ℕ] : BinomialRing R where
  nsmul_right_injective n hn r s hrs := by
    rw [← one_smul ℚ≥0 r, ← one_smul ℚ≥0 s, show 1 = (n : ℚ≥0)⁻¹ • (n : ℚ≥0) by simp_all]
    simp_all only [smul_assoc, ← nsmul_eq_smul_cast]
  multichoose r n := (n.factorial : ℚ≥0)⁻¹ • Polynomial.smeval (ascPochhammer ℕ n) r
  factorial_nsmul_multichoose r n := by
    simp only [← smul_assoc]
    field_simp

end Basic_Instances

section Neg

namespace Ring

open Polynomial

variable {R : Type*} [NonAssocRing R] [Pow R ℕ] [BinomialRing R]

@[simp]
theorem smeval_ascPochhammer_self_neg : ∀ n : ℕ,
    smeval (ascPochhammer ℕ n) (-n : ℤ) = (-1)^n * n.factorial
  | 0 => by
    rw [Nat.cast_zero, neg_zero, ascPochhammer_zero, Nat.factorial_zero, smeval_one, pow_zero,
      one_smul, pow_zero, Nat.cast_one, one_mul]
  | n + 1 => by
    rw [ascPochhammer_succ_left, smeval_X_mul, smeval_comp, smeval_add, smeval_X, smeval_one,
      pow_zero, pow_one, one_smul, Nat.cast_add, Nat.cast_one, neg_add_rev, neg_add_cancel_comm,
      smeval_ascPochhammer_self_neg n, ← mul_assoc, mul_comm _ ((-1) ^ n),
      show (-1 + -↑n = (-1 : ℤ) * (n + 1)) by omega, ← mul_assoc, pow_add, pow_one,
      Nat.factorial, Nat.cast_mul, ← mul_assoc, Nat.cast_succ]

@[simp]
theorem smeval_ascPochhammer_succ_neg (n : ℕ) :
    smeval (ascPochhammer ℕ (n + 1)) (-n : ℤ) = 0 := by
  rw [ascPochhammer_succ_right, smeval_mul, smeval_add, smeval_X, ← C_eq_natCast, smeval_C,
    pow_zero, pow_one, Nat.cast_id, nsmul_eq_mul, mul_one, add_left_neg, mul_zero]

theorem smeval_ascPochhammer_neg_add (n : ℕ) : ∀ k : ℕ,
    smeval (ascPochhammer ℕ (n + k + 1)) (-n : ℤ) = 0
  | 0 => by
    rw [add_zero, smeval_ascPochhammer_succ_neg]
  | k + 1 => by
    rw [ascPochhammer_succ_right, smeval_mul, ← add_assoc, smeval_ascPochhammer_neg_add n k,
      zero_mul]

@[simp]
theorem smeval_ascPochhammer_neg_of_lt {n k : ℕ} (h : n < k) :
    smeval (ascPochhammer ℕ k) (-n : ℤ) = 0 := by
  rw [show k = n + (k - n - 1) + 1 by omega, smeval_ascPochhammer_neg_add]

theorem smeval_ascPochhammer_nat_cast [NatPowAssoc R] (n k : ℕ) :
    smeval (ascPochhammer ℕ k) (n : R) = smeval (ascPochhammer ℕ k) n := by
  rw [smeval_at_natCast (ascPochhammer ℕ k) n]

theorem multichoose_neg_self (n : ℕ) : multichoose (-n : ℤ) n = (-1)^n := by
  apply nsmul_right_injective _ (Nat.factorial_ne_zero _)
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, smeval_ascPochhammer_self_neg, nsmul_eq_mul,
    Nat.cast_comm]

@[simp]
theorem multichoose_neg_succ (n : ℕ) : multichoose (-n : ℤ) (n + 1) = 0 := by
  apply nsmul_right_injective _ (Nat.factorial_ne_zero _)
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, smeval_ascPochhammer_succ_neg, smul_zero]

theorem multichoose_neg_add (n k : ℕ) : multichoose (-n : ℤ) (n + k + 1) = 0 := by
  refine nsmul_right_injective (Nat.factorial (n + k + 1)) (Nat.factorial_ne_zero (n + k + 1)) ?_
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, smeval_ascPochhammer_neg_add, smul_zero]

@[simp]
theorem multichoose_neg_of_lt (n k : ℕ) (h : n < k) : multichoose (-n : ℤ) k = 0 := by
  refine nsmul_right_injective (Nat.factorial k) (Nat.factorial_ne_zero k) ?_
  simp only
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, smeval_ascPochhammer_neg_of_lt h, smul_zero]

theorem multichoose_succ_neg_natCast [NatPowAssoc R] (n : ℕ) :
    multichoose (-n : R) (n + 1) = 0 := by
  refine nsmul_right_injective (Nat.factorial (n + 1)) (Nat.factorial_ne_zero (n + 1)) ?_
  simp only [smul_zero]
  rw [factorial_nsmul_multichoose_eq_ascPochhammer, smeval_neg_nat,
    smeval_ascPochhammer_succ_neg n, Int.cast_zero]

theorem smeval_ascPochhammer_int_ofNat [NatPowAssoc R] (r : R) : ∀ n : ℕ,
    smeval (ascPochhammer ℤ n) r = smeval (ascPochhammer ℕ n) r
  | 0 => by
    simp only [ascPochhammer_zero, smeval_one]
  | n + 1 => by
    simp only [ascPochhammer_succ_right, smeval_mul]
    rw [smeval_ascPochhammer_int_ofNat r n]
    simp only [smeval_add, smeval_X, ← C_eq_natCast, smeval_C, natCast_zsmul, nsmul_eq_mul,
      Nat.cast_id]

end Ring

end Neg

section Choose

namespace Ring

open Polynomial

variable {R : Type*}

/-- The binomial coefficient `choose r n` generalizes the natural number `choose` function,
  interpreted in terms of choosing without replacement. -/
def choose [AddCommGroupWithOne R] [Pow R ℕ] [BinomialRing R] (r : R) (n : ℕ): R :=
  multichoose (r - n + 1) n

variable [NonAssocRing R] [Pow R ℕ] [BinomialRing R]

theorem descPochhammer_eq_factorial_smul_choose [NatPowAssoc R] (r : R) (n : ℕ) :
    (descPochhammer ℤ n).smeval r = n.factorial • choose r n := by
  rw [choose, factorial_nsmul_multichoose_eq_ascPochhammer, descPochhammer_eq_ascPochhammer,
    smeval_comp, add_comm_sub, smeval_add, smeval_X, npow_one]
  have h : smeval (1 - n : Polynomial ℤ) r = 1 - n := by
    rw [← C_eq_natCast, ← C_1, ← C_sub, smeval_C]
    simp only [npow_zero, zsmul_one, Int.cast_sub, Int.cast_one, Int.cast_natCast]
  rw [h, ascPochhammer_smeval_cast, add_comm_sub]

theorem choose_natCast [NatPowAssoc R] (n k : ℕ) : choose (n : R) k = Nat.choose n k := by
  refine nsmul_right_injective (Nat.factorial k) (Nat.factorial_ne_zero k) ?_
  simp only
  rw [← descPochhammer_eq_factorial_smul_choose, nsmul_eq_mul, ← Nat.cast_mul,
    ← Nat.descFactorial_eq_factorial_mul_choose, ← descPochhammer_smeval_eq_descFactorial]

@[deprecated (since := "2024-04-17")]
alias choose_nat_cast := choose_natCast

end Ring

end Choose
