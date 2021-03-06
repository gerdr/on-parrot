Introducing M0-pm
-----------------

Two weeks ago, I put my money where my mouth is (figuratively speaking, of
course) and started implementing m0± at
[gerdr/m0-pm](https://github.com/gerdr/m0-pm).

I only had a vague idea of where I wanted to go, which resulted in a phase of
continuous rewrites, but I'm hopeful that the current design is good enough to
be the basis for incremental improvements.

If you take a look at the code, you'll see no references to m0+ and m0-;
instead, m0- instructions are called core ops and m0+ instructions just ops.
There's no deep reason behind that, I just had to go with names which are usable
as C identifiers and don't suck too much.

The first implementation used 64-bit words for everything, including pointers
(which needed to be zero-extended on 32-bit architectures). Also, each core op
took a single immediate argument, which was always loaded - regardless of
whether or not it was actually used.

Because of the low number of general-purpose registers on x86, this resulted in
a lot of register spilling. I changed the design so pointers and memory offsets
use their native representation, and core op arguments are only loaded on
demand.

This also meant that there wasn't really any reason to keep core ops fixed-sized
- they now have a variable number of immediate arguments.

As whiteknight remarked on #parrot, this makes analyzing core ops more involved,
but you aren't supposed to do that anyway: Core ops are the instruction set of
the interpreter runcore, and can be considered just another target instruction
set for code generation, same as the native instructions sets of architectures
with dedicated jit compilers.

And while we're talking about design decisions, some remarks on register
allocation: m0± doesn't have an allocator. M0+ registers are held in memory, and
each m0+ instruction taking register arguments expands to load and store m0-
instructions (modulo peephole optimizations if I get around to implementing an
optimizing translator).

This isn't really as bad as it sounds: The [current 'official' m0
spec](https://github.com/parrot/parrot/blob/m0-spec/docs/pdds/draft/pdd32_m0.pod)
specifies 256 vm registers. However, Itanium aside, no mainstream architecture
comes close to that number of general-purpose hardware registers; the situation
on x86 is especially bad because each 64 bit integer uses two hardware
registers, so you'll do a lot of marshalling to memory anyway.

Mapping often-used registers to hardware registers is a good idea, but can't
really be done in a target-agnostic way and is thus out of the scope of m0-.
Mind you, a dedicated native code generator can and should do such
optimizations.

Currently, m0-pm is still at a proof-of-concept stage, with lots of missing
features. There probably won't be a lot of progress during the following week as
I'm blocking on free time and too nice weather, and need to do a bit of deep
thinking: There are some design decisions to be made, in particular the
low-level calling convention and the bytecode format. I'm also thinking about
how code annotation should work, which is necessary so high-level compilers can
communicate with low-level code generators.

There's still a long way to go till I can take a shot at implementing high-level
subsystems like the CPS facilities, the garbage collector and the object system,
but even at this early stage, having an actual implementation provided some
important insights.
