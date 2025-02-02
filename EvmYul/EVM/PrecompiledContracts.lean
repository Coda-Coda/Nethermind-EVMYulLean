import EvmYul.Maps.AccountMap
import EvmYul.UInt256
import EvmYul.State.Substate
import EvmYul.State.ExecutionEnv
import EvmYul.EVM.Exception
import EvmYul.Wheels

import EvmYul.EllipticCurves
import EvmYul.SHA256
import EvmYul.RIP160
import EvmYul.BN_ADD
import EvmYul.BN_MUL
import EvmYul.SNARKV
import EvmYul.BLAKE2_F
import EvmYul.PointEval

open EvmYul

def Ξ_ECREC
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let gᵣ : UInt256 := 3000

  if g < gᵣ then
    (∅, 0, A, .empty)
  else
    let d := I.inputData
    let h := d.readBytes 0 32
    let v := d.readBytes 32 32
    let r := d.readBytes 64 32
    let s := d.readBytes 96 32
    let v' : UInt256 := fromBytesBigEndian v.data.data
    let r' : UInt256 := fromBytesBigEndian r.data.data
    let s' : UInt256 := fromBytesBigEndian s.data.data
    let o :=
      if v' < 27 || 28 < v' || r' = 0 || r' >= secp256k1n || s' = 0 || s' >= secp256k1n then
        .empty
      else
        match ECDSARECOVER h (BE (v' - 27)) r s with
          | .ok s =>
              ByteArray.zeroes ⟨12⟩ ++ (KEC s).extract 12 32
          | .error e =>
            dbg_trace s!"Ξ_ECREC failed: {e}"
        .empty
    (σ, g - gᵣ, A, o)

def longInput := "Lean 4 is a reimplementation of the Lean theorem prover in Lean itself. The new compiler produces C code, and users can now implement efficient proof automation in Lean, compile it into efficient C code, and load it as a plugin. In Lean 4, users can access all internal data structures used to implement Lean by merely importing the Lean package."

-- Example taken from EllipticCurves.lean
private def ecrecOutput :=
  let (_, _, _, o) :=
    Ξ_ECREC
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := h ++ v ++ r ++ s
      }
  o
 where
  h :=
    UInt256.toByteArray 0x9a59efbc471b53491c8038fd5d5fe3be0a229873302bafba90c19fbe7d7c7f35
  v :=
    UInt256.toByteArray 0x1b
  r :=
    UInt256.toByteArray 0xd40b91381e1eeca34f4858a79ff4f3165066f93a76ba0f067848a962312f18ef
  s :=
    UInt256.toByteArray 0x0e86fce48de10c6b4e07b0a175877bc824bbf6d2089a50f3b11e24ad0d5c8173

private example :
  ecrecOutput
    =
  (ByteArray.ofBlob
    "0000000000000000000000000bed7abd61247635c1973eb38474a2516ed1d884"
  ).toOption
:=
  by native_decide

def Ξ_SHA256
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let gᵣ : UInt256 :=
    let l := I.inputData.size
    let rem := l % 32
    let divided := l / 32
    let ceil := if rem == 0 then divided else divided + 1
    60 + 12 * ceil

  if g < gᵣ then
    (∅, 0, A, .empty)
  else
    let o :=
      match SHA256 I.inputData with
        | .ok s => s
        | .error e =>
          dbg_trace s!"Ξ_SHA56 failed: {e}"
          .empty
    (σ, g - gᵣ, A, o)

private def shaOutput :=
  let (_, _, _, o) :=
    Ξ_SHA256
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := longInput.toUTF8
      }
  o
private example :
  EvmYul.toHex shaOutput
    =
  "4dbbf25c7844e6087e0a6948a71949c0ae2d46e75c16859457c430b8ce2d72ae"
:= by native_decide

def Ξ_RIP160
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let gᵣ : UInt256 :=
    let l := I.inputData.size
    let rem := l % 32
    let divided := l / 32
    let ceil := if rem == 0 then divided else divided + 1
    60 + 12 * ceil

  if g < gᵣ then
    (∅, 0, A, .empty)
  else
    let o :=
      match RIP160 I.inputData with
        | .ok s => s
        | .error e =>
          dbg_trace s!"Ξ_RIP160 failed: {e}"
          .empty
    (σ, g - gᵣ, A, o)

private def ripOutput :=
  let (_, _, _, o) :=
    Ξ_RIP160
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := longInput.toUTF8
      }
  o

private example :
  EvmYul.toHex ripOutput = "5cff4c1668e5542c74a609a3146427c28e51ff5a"
:= by native_decide


def Ξ_ID
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let gᵣ : UInt256 :=
    let l := I.inputData.size
    let rem := l % 32
    let divided := l / 32
    let ceil := if rem == 0 then divided else divided + 1
    15 + 3 * ceil

  if g < gᵣ then
    (∅, 0, A, .empty)
  else
    let o := I.inputData
    (σ, g - gᵣ, A, o)

private def idOutput :=
  let (_, _, _, o) :=
    Ξ_ID
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := longInput.toUTF8
      }
  o

private example :
  idOutput = longInput.toUTF8
:= by native_decide

def expModAux (m : ℕ) (a : ℕ) (c : ℕ) : ℕ → ℕ
  | 0 => a % m
  | n@(k + 1) =>
    if n % 2 == 1 then
      expModAux m (a * c % m) (c * c % m) (n / 2)
    else
      expModAux m (a % m)     (c * c % m) (n / 2)

def expMod (m : ℕ) (b : UInt256) (n : ℕ) : ℕ := expModAux m 1 b n

def Ξ_EXPMOD
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let d := I.inputData
  let l_B := d.readBytes 0 32 |>.data.data |> fromBytesBigEndian
  let l_E := d.readBytes 32 32 |>.data.data |> fromBytesBigEndian
  let l_M := d.readBytes 64 32 |>.data.data |> fromBytesBigEndian
  let B := d.readBytes 96 l_B |>.data.data |> fromBytesBigEndian
  let E := d.readBytes (96 + l_B) l_E |>.data.data |> fromBytesBigEndian
  let M := d.readBytes (96 + l_B + l_E) l_M |>.data.data |> fromBytesBigEndian

  let l_E' :=
    let E_firstWord := d.readBytes (96 + l_B) 32 |>.data.data |> fromBytesBigEndian
    if l_E ≤ 32 && E == 0 then
      0
    else
      if l_E ≤ 32 && E != 0 then
        Nat.log 2 E
      else
        if 32 < l_E && E_firstWord != 0 then
          8 * (l_E - 32) + (Nat.log 2 E_firstWord)
        else
          8 * (l_E - 32)

  let gᵣ :=
    let G_quaddivisor := 3
    let f x :=
      let rem := x % 8
      let divided := x / 8
      let ceil := if rem == 0 then divided else divided + 1
      ceil ^ 2

    max 200 (f (max l_M l_B) * max l_E' 1 / G_quaddivisor)

  let o : ByteArray := BE (expMod M B E)
  let o : ByteArray := ByteArray.zeroes ⟨l_M - o.size⟩ ++ o

  (σ, g - gᵣ, A, o)

private def expmodOutput :=
  let (_, _, _, o) :=
    Ξ_EXPMOD
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := l_B ++ l_E ++ l_M ++ B ++ E ++ M
      }
  o
 where
  l_B : ByteArray := UInt256.toByteArray 2
  l_E : ByteArray := UInt256.toByteArray 1
  l_M : ByteArray := UInt256.toByteArray 1
  B : ByteArray := ⟨#[1, 0]⟩ -- 2^8
  E : ByteArray := ⟨#[2]⟩
  M : ByteArray := ⟨#[100]⟩

private example :
  expmodOutput
    = ⟨#[65536 % 100]⟩ -- (2^8) ^ 2 % 10
:=
  by native_decide

def Ξ_BN_ADD
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let gᵣ : UInt256 := 150
  let d := I.inputData
  let x := (d.readBytes 0 32, d.readBytes 32 32)
  let y := (d.readBytes 64 32, d.readBytes 96 32)
  let o := BN_ADD x.1 x.2 y.1 y.2
  match o with
    | .ok o => (σ, g - gᵣ, A, o)
    | .error e =>
      dbg_trace s!"Ξ_BN_ADD failed: {e}"
      (σ, g - gᵣ, A, .empty)

private def bn_addOutput₀ :=
  let (_, _, _, o) :=
    Ξ_BN_ADD
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := x₁ ++ y₁ ++ x₂ ++ y₂
      }
  o
 where
  x₁ : ByteArray := UInt256.toByteArray 0
  y₁ : ByteArray := UInt256.toByteArray 0
  x₂ : ByteArray := UInt256.toByteArray 1
  y₂ : ByteArray := UInt256.toByteArray 2

private def bn_addOutput₁ :=
  let (_, _, _, o) :=
    Ξ_BN_ADD
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := bn_addOutput₀ ++ x ++ y
      }
  o
 where
  x : ByteArray := UInt256.toByteArray 1
  y : ByteArray := UInt256.toByteArray 2

def Ξ_BN_MUL
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let gᵣ : UInt256 := 6000
  let d := I.inputData
  let x := (d.readBytes 0 32, d.readBytes 32 32)
  let n := d.readBytes 64 32
  let o := BN_MUL x.1 x.2 n
  match o with
    | .ok o => (σ, g - gᵣ, A, o)
    | .error e =>
      dbg_trace s!"Ξ_BN_MUL failed: {e}"
      (σ, g - gᵣ, A, .empty)

private def bn_mulOutput :=
  let (_, _, _, o) :=
    Ξ_BN_MUL
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := x₁ ++ y₁ ++ n
      }
  o
 where
  x₁ : ByteArray := UInt256.toByteArray 1
  y₁ : ByteArray := UInt256.toByteArray 2
  n : ByteArray := UInt256.toByteArray 2

-- (0, 0) + (1, 2) + (1, 2) = 2 * (1, 2)
private example : bn_addOutput₁ = bn_mulOutput := by native_decide

def Ξ_SNARKV
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let d := I.inputData
  let k := d.size / 192
  let gᵣ : UInt256 := 34000 * k + 45000

  let o := SNARKV d
  match o with
    | .ok o => (σ, g - gᵣ, A, o)
    | .error e =>
      dbg_trace s!"Ξ_SNARKV failed: {e}"
      (∅, 0, A, .empty)

private def snarkvOutput :=
  let (_, _, _, o) :=
    Ξ_SNARKV
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := x ++ y ++ ByteArray.zeroes ⟨32 * 4⟩
      }
  o
 where
  x : ByteArray := UInt256.toByteArray 1
  y : ByteArray := UInt256.toByteArray 2

private example :
  snarkvOutput.size = 32 ∧ (fromBytesBigEndian snarkvOutput.data.data) ∈ [0, 1]
:= by native_decide

def Ξ_BLAKE2_F
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let d := I.inputData
  let k := d.size / 192
  let gᵣ : UInt256 := 34000 * k + 45000

  let o := BLAKE2_F d
  match o with
    | .ok o => (σ, g - gᵣ, A, o)
    | .error e =>
      dbg_trace s!"Ξ_BLAKE2_F failed: {e}"
      (∅, 0, A, .empty)

def blake2_fInput :=
  ByteArray.ofBlob "0000000048c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b61626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000001"
  |>.toOption.getD .empty

private def blake2_fOutput :=
  let (_, _, _, o) :=
    Ξ_BLAKE2_F
      default
      3000
      default
      { (default : ExecutionEnv) with
        inputData := blake2_fInput
      }
  o

-- Example taken from
-- https://eips.ethereum.org/EIPS/eip-152
private example :
  blake2_fOutput
    =
  (ByteArray.ofBlob "08c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d282e6ad7f520e511f6c3e2b8c68059b9442be0454267ce079217e1319cde05b").toOption
:= by native_decide

def Ξ_PointEval
  (σ : AccountMap)
  (g : UInt256)
  (A : Substate)
  (I : ExecutionEnv)
    :
  (AccountMap × UInt256 × Substate × ByteArray)
:=
  let d := I.inputData
  let gᵣ : UInt256 := 50000

  let o := PointEval d
  match o with
    | .ok o => (σ, g - gᵣ, A, o)
    | .error e =>
      dbg_trace s!"Ξ_PointEval failed: {e}"
      (∅, 0, A, .empty)
