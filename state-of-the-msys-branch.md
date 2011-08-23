State of the MSYS Branch
------------------------

My MSYS branch now properly differentiates between the MSYS and MINGW32 subsystems, but both options still have issues.

The MINGW32 build creates a native Windows binary, which doesn't play well with the virtual paths used by msys-perl. I'm getting around that by [monkey patching](https://github.com/gerdr/parrot/blob/gerdr/msys/lib/MSYS/MinGW.pm) the core modules `Cwd` and `File::Spec`.

That's clearly a hack, but there does not seem to be a silver bullet for this particular problem, and this approach has been [suggested previously](http://groups.google.com/group/msysgit/browse_thread/thread/87ea9c3125d0fb8e/99375e2b77bd46aa#anchor_01e5df4b6ff350e1) during a [related discussion](http://groups.google.com/group/msysgit/browse_thread/thread/87ea9c3125d0fb8e/99375e2b77bd46aa).

I did not yet fix the test regressions introduced by [commit ad25aa9](https://github.com/gerdr/parrot/commit/ad25aa96b975d06d9354da998c328666a20b7156) as I was busy setting up a vanilla MSYS environment for work on the MSYS subsystem (*had some issues compiling git, but got it to work eventually*).

The MSYS build currently compiles, but `make` fails due to path mismatches. Fixing these might call for introduction of a new platform built from the `win32` and `generic` ones. Alternatively, some new `#ifdef __MSYS__` blocks could probably be added to the `win32` code.
