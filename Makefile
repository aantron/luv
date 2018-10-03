.PHONY : build
build :
	dune build

.PHONY : test
test :
	dune build test/tester.exe
	dune runtest -j 1 --no-buffer

.PHONY : clean
clean :
	dune clean

# For debugging the libuv build, add V=1, i.e. V=1 BUILDTYPE=Release make ...
.PHONY : libuv
libuv : gyp-link
	(cd src/vendor/libuv \
	  && ./gyp_uv.py -f make \
	  && CFLAGS=-fPIC BUILDTYPE=Release make -C out libuv)

.PHONY : gyp-link
gyp-link :
	(cd src/vendor/libuv \
	  && ([ -L build/gyp ] \
	    || (mkdir -p build/ \
		  && ln -s ../../gyp build/gyp)))

.PHONY : clean-libuv
clean-libuv :
	(cd src/vendor/libuv \
	  && rm -r build out)

# TODO Handling the submodules

.PHONY : todos
todos :
	@grep -rn TODO . \
	  | grep -v _build | grep -v src/vendor/libuv | grep -v src/vendor/gyp

# TODO Build all the examples
# TODO In CI, run the examples
