MODULE Cardane;
IMPORT In, Out;

CONST maxN = 8;
VAR
  m: ARRAY maxN, maxN OF CHAR; (** Ciphertext *)
  c: ARRAY maxN, maxN OF INTEGER; (** Constructor *)
  N: INTEGER;

PROCEDURE SetM(n: INTEGER; s: ARRAY OF CHAR);
VAR i, j, k: INTEGER;
BEGIN
  N := n;
  k := 0;
  FOR i := 0 TO N - 1 DO
    FOR j := 0 TO N - 1 DO
      m[i, j] := s[k];
      INC(k)
    END
  END
END SetM;

PROCEDURE MakeConstructor;
VAR i, j, k, halfN: INTEGER;
BEGIN
  halfN := N DIV 2;
  k := 1;
  FOR i := 0 TO halfN - 1 DO
    FOR j := 0 TO halfN - 1 DO
      c[i, j] := k;
      c[j, N - 1 - i] := k;
      c[N - 1 - i, N - 1 - j] := k;
      c[N - 1 - j, i] := k;
      INC(k)
    END
  END
END MakeConstructor;

PROCEDURE ShowConstructor;
VAR i, j: INTEGER;
BEGIN
  FOR i := 0 TO N - 1 DO
    FOR j := 0 TO N - 1 DO
      Out.Int(c[i, j], 2)
    END;
    Out.Ln
  END;
  Out.Ln
END ShowConstructor;

PROCEDURE ShowM;
VAR i, j: INTEGER;
BEGIN
  FOR i := 0 TO N - 1 DO
    FOR j := 0 TO N - 1 DO
      Out.Char(' ');
      Out.Char(m[i, j])
    END;
    Out.Ln
  END;
  Out.Ln
END ShowM;

PROCEDURE Power(a, x: INTEGER): INTEGER;
VAR y: INTEGER;
BEGIN
  y := 1;
  WHILE x # 0 DO
    y := y * a;
    DEC(x)
  END
RETURN y END Power;

(** x - what are we searching for, pos - where to start
    (1-dim coordinate). Returns also 1-dim coordinate. *)
PROCEDURE FindNext(x, pos: INTEGER): INTEGER;
BEGIN
  WHILE c[pos DIV N, pos MOD N] # x DO INC(pos) END
RETURN pos END FindNext;

(** x - what are we searching for, n = 0 means find first,
    n = 1 means find second etc.
    Returns 1-dim coordinate. *)
PROCEDURE SearchNth(x, n: INTEGER): INTEGER;
VAR pos: INTEGER;
BEGIN
  pos := -1;
  REPEAT
    pos := FindNext(x, pos + 1);
    DEC(n)
  UNTIL n = -1
RETURN pos END SearchNth;

PROCEDURE Sort(VAR a: ARRAY OF INTEGER; len: INTEGER);
VAR i, j, k, tmp: INTEGER;
BEGIN
  FOR i := 0 TO len - 2 DO
    k := i;
    FOR j := i + 1 TO len - 1 DO
      IF a[j] < a[k] THEN k := j END
    END;
    tmp := a[i]; a[i] := a[k]; a[k] := tmp
  END
END Sort;

(** Returns pos turned by 90 degrees turn times. *)
PROCEDURE Turn(pos, turn: INTEGER): INTEGER;
VAR x, y, newX: INTEGER;
BEGIN
  y := pos DIV N;
  x := pos MOD N;
  WHILE turn # 0 DO
    newX := y;
    y := N - 1 - x;
    x := newX;
    DEC(turn)
  END
RETURN y * N + x END Turn;

PROCEDURE PrintLetter(pos: INTEGER);
BEGIN
  Out.Char(m[pos DIV N, pos MOD N])
END PrintLetter;

PROCEDURE ApplyGrille(g: ARRAY OF INTEGER; len: INTEGER);
VAR i, turn: INTEGER;
BEGIN
  FOR turn := 0 TO 3 DO
    FOR i := 0 TO len - 1 DO
      PrintLetter(Turn(g[i], turn))
    END
  END;
  Out.Ln
END ApplyGrille;

PROCEDURE Generate;
VAR phase, lastPhase, p: INTEGER;
  searchCount: INTEGER; (* i.e. 4 *)
  search: INTEGER; (* Search for 1, 2, 3, ...maxSearch *)
  found: ARRAY 64 OF INTEGER;
BEGIN
  searchCount := N * N DIV 4;
  lastPhase := Power(4, searchCount) - 1;
  FOR phase := 0 TO lastPhase DO

    p := phase;
    FOR search := 1 TO searchCount DO
      found[search - 1] := SearchNth(search, p MOD 4);
      p := p DIV 4
    END;

    Sort(found, searchCount);

    ApplyGrille(found, searchCount)
  END
END Generate;

PROCEDURE Decipher(n: INTEGER; letters: ARRAY OF CHAR);
BEGIN
  SetM(n, letters);
  MakeConstructor;

  ShowM;
  ShowConstructor;

  Generate
END Decipher;

BEGIN
  Decipher(4, 'DKTĪRUKVLĀU_RAMS')
END Cardane.
