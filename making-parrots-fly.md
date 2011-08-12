Making Parrots Fly
------------------

**Update:** Just testing if updates work correctly...

Some preliminary information so you see where I'm coming from: I do C coding on
Windows, mostly for fun and using open source compilers - mainly MinGW and
sometimes Clang. However, a compiler is not enough, you need supporting tools
like debugger and build system, and for a long time I used MinGW together with
the Cygwin userland.

Some time ago, I switched to MSYS for various reasons (git, less bloat) and
recently tried to get Parrot to build.

Major fail.

The easy solution would probably have been to install Strawberry Perl, but this
would just pull in another version of both Perl and MinGW I do not really need
for anything but Parrot. Also, easy is no fun.

The problem:

The Parrot build process is tightly coupled with Perl, and Perl on MSYS is
special. For one, it's old (was 5.6.1 not long ago, now it's 5.8.8), and for
seconds, it's native to MSYS ans thus uses the UNIX-style virtual file system.
Parrot, however, is not native to MSYS (which is a good thing, really, as MSYS
has some rough edges, one of which is that it's strictly 32bit) and thus expects
Windows-style paths wherever absolute paths are needed. As Parrot hard-codes
absolute paths into the executable, the build fails.

Getting it to build took effort, partly because I don't know a lot about Parrot
and even less about its build process, and partly because automated build
systems suck.

  1. **You have a problem:** Compiling some code.
  2. **Solution:** Using an automated build system.
  3. **Now you have two problems.**

Anyway, back to Parrot, and what was necessary to get it to build: First, MSYS
Perl identifies as `msys-64int` (which means that it uses 64bit integers
internally, not that its compiled for 64bit architectures - remember, MSYS is
strictly 32bit), and the build system doesn't know how to deal with that.

So I fixed the code for OS detection and used a Windows environment variable to
get the architecture. However, this might blow up if you use mingw32 (the
default MinGW) on 64bit architectures instead of the mingw-w64 fork. (I'm on a
32bit computer, testing on 64bit computers with mingw32 and mingw-w64 both would
be appreciated.)

The hints file for MSYS contained nothing of value (it was last touched in 2007,
and it might not have worked with MSYS Perl even then), so I cobbled together
something from the Windows and Cygwin hints files, hardcoding my own paths, and
later added proper path translation, which can be done in Perl via

    $path = `cd '$path' && pwd -W`;
    chomp $path;

The Win32 package can't be installed using CPAN - it fails with *OS
unsupported*, so you need to fall back to the shell.

A similar fix has to be done for the script generating `config_lib.pir`, as it
doesn't reuse the `build_dir` as prefix for non-installed Parrots, but grabs the
current working directory instead.

I made Parrot on MSYS link dynamically, which means that the blib directory has
to be the same as the build directory so `libparrot.dll` can be found by
non-installed Parrots.

Finally, `Configure.pl` incorrectly detects `sys/utsname.h`, but adding it to
the list of headers explicitly probed for fixed that.

This was it. Parrot builds on MSYS.

I saw a lot of test failures and one threading test hangs (which I just skipped
as it is skipped on Windows as well) and needed to patch the testing script to
return non-UNIX filenames for temporary files so Parrot understands them.

What still needs to be done is testing the installation process, testing on
64bit architectures and investigating the remaining test failures. Some of the
tests probably can just be skipped if they are skipped on Windows (I didn't
verify, but I expect at least some of the failures are like that, same as the
threading test). There are probably also real problems which need to be dealt
with.
