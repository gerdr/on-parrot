Rethinking M0
-------------

**DISCLAIMER:** This essay was written while *NOT* under influence of controlled
substances.

As I have recently mentioned on #parrot, I see problems with the current design
of the m0 instruction set. I propose a radically different approach, called m0+
for now.

However, not much thought has gone into integrating the existing infrastructure:
As it is presented here, an implementation would need a complete rewrite of all
Parrot internals. It should therefore not necessarily be considered a
(hitchhiker's) guide to the future, but rather serve as inspiration for a
redesign of m0.

m0+ is a more high-level, virtual instruction set. It's main design goals are
fast translation to various native or virtual low-level instruction sets (x86,
GNU lightning, Nanojit LIR) and, specifically, easy translation to LLVM IR.

It is a three-address code heavily inspired by LLVM IR, but different in certain
key points:

  - m0+ is not SSA
  - m0+ doesn't do aggregate or structural typing
  - m0+ register identifiers are purely numeric
  - m0+ assemblers need not do register allocation

m0+ is the user-facing frontend of the Parrot VM: Libraries are serialized to
m0+ bytecode, and this is what HLLs - including PIR and the hypothetical Parrot
systems language codenamed Mole - will compile to.

In addition to m0+, there will be another microcode-like instruction set,
tentatively called m0-. This is what gets actually run by the interpreter, but
is a purely internal implementation detail: Users should never get to see m0- -
even if something blows up, debugging would be done using m0+ (except when
debugging the m0- interpreter, obviously).

The key design goals for m0- are fast translation from m0+ (which will be done
when bytecode files are lodaded), ease of implementation and fast execution.

m0- will have a textual representation, but needs no bytecode format, only an
efficient in-memory representation. Instructions take a single, immediate
argument.

How would m0+ and m0- look like? Here are two examples for m0+:

    %0 = add int %1, 0xFF
    %42 = add float 0.15, [@foo : %10 * 4 -> f32]

The `%` sigil denotes a register, `@` a global, which is a constant expression
of pointer type; as with m0, m0+ recognizes the types int, float and pointer -
however, there is no native string type.

The `=` and the space after `add` are merely syntactic sugar - the statements
are equivalent to

    addint %0, %1, 0xFF
    addfloat %42, 0.15, [@foo : %10 * 4 -> f32]

m0+ supports an arbitrary number of registers: The interpreter allocates a new
register set of apropriate size for each m0+ chunk, where the size of the set is
one greater than the highest register number.

Arguments to an instruction can be a register, an int, float or pointer literal
(eg a global) or an address literal, denoted by square brackets.

An address literal takes a base address (a register or a pointer literal),
optionally followed after the `:` separator by a constant displacement (an int
literal) and an offset register, optionally scaled by a constant multiplier;
finally, the `->` separates the type of the addressed location.

The location must be typed so the implementation knows how to marshal from
memory to register: Registers have a single int or float type, but nevertheless
it must be possible to read/write arbitrary types from/to memory if we want to
interact with native code. It's also required for implementing 6model on top of
m0+.

The rather convoluted addressing scheme is there to allow for efficient
translation to native code. In particular, it makes use of x86 addressing modes:
On x86, such memory accesses can be implemented as a single `mov` instruction,
and a JIT compiler can thus generate such an instruction without an optimizer.

The bytecode format encodes each instruction as an 8bit value denoting the
opcode, an 8bit value denoting the argument types (register, immediate, symbolic
or memory), and three 16bit values denoting the arguments. A complete
instruction is thus encoded in 8 bytes.

If the argument has register type, it's just the register number. If it has
immediate type, it is an offset into the constant table, which is part of the
bytecode file. Pointer constants (ie names of global variables) result in
symbolic arguments, as the actual value of the expression can't be decided until
load time. Thus, bytecode files need a global table listing name and type of
global variables, and symbolic arguments are offsets into that table. If the
argument has memory type, it's an offset into the address table, which contains
the base register number, the displacement, the offset register number, the
multiplier and the type.

The m0- interpreter is a virtual machine with 6 general-purpose register and a
yet to be determined number of specialized registers like the instruction
pointer or the pointer to the active m0+ register set.

There are two registers for each of the m0+ types called `ia`, `ib`, `fa`, `fb`,
`pa`, `pb`. Instructions either operate within a pair of single type (eg `ia`
and `ib`) or the triple of same name (eg `ib`, `fb`, `pb`).

The single, immediate argument to the instruction is either a constant or a
register number. m0- does not parse address literals, and as m0- is generated at
load time, pointer constants are already resolved.

The values of the m0- registers need not be preserved from one m0+ instruction
to the next. However, a potential optimizing translator could very well keep
values across instructions.

The m0+ examples from above would expand to the follwing m0- instructions:

    %0 = add int %1, 0xFF
    get ia %1    ; load %1 into ia
    set ib 0xFF  ; set ib to 0xFF
    add ia       ; set ia to ia + ib
    put ia %0    ; store ia into %0

    %42 = add float 0.15, [@foo : %10 * 4 -> f32]
    set fa 0.15  ; set fa to 0.15
    set pb @foo  ; set pb to the address of the global @foo
    get ib %10   ; load %10 into ib
    offset pb 4  ; set pb to pb + ib * 4
    load f32 fb  ; convert value pointed to by pb from f32 to float,
                 ; put it into fb
    add fa       ; set fa to fa + fb
    put fa %42   ; store fa into %42

The in-memory representation of an m0- instruction ideally consists of the jump
label implementing the instruction and the immediate value. Thus, on 32bit
architectures (assuming a register size of 64bit, which is necessary for
double-precision floating point values and should thus be considered the
default), an m0- instruction takes 12 or 16 bytes (depending on alignment),
whereas on 64bit architectures, it would always take 16 bytes.

The m0+ runtime, including the m0- interpreter, will be written in Mole and
compiled to m0+ bytecode. This gets translated to LLVM IR, which in turn gets
compiled to optimized native code. This creates a compile-time (but not runtime)
dependency on LLVM. However, releases could get rid of the dependency by
including generated native code.

There are different strategies for JIT compilation using existing solutions: One
could compile the m0- instructions using a fast low-level code generator like
GNU lightning, or one could use a slightly more high-level compiler like libjit
or even LLVM to generate more optimized code from m0+.
