.PHONY : build
build :
	dune build -p luv

.PHONY : test
test :
	dune build test/tester.exe
	dune runtest -j 1 --no-buffer

.PHONY : test-examples
test-examples :
	dune exec example/delay/delay.exe
	dune exec example/http_get/http_get.exe -- google.com > /dev/null
	dune exec example/http_get_lwt/http_get_lwt.exe -- google.com > /dev/null
	dune exec example/http_get_repromise/http_get_repromise.exe -- google.com \
	  > /dev/null
	dune exec example/interop_repromise_lwt/interop_repromise_lwt.exe
	dune build example/tcp_echo_server/tcp_echo_server.exe

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

.PHONY : todos
todos :
	@grep -rn TODO src test Makefile README.md luv.opam \
	  | grep -v _build | grep -v src/vendor/libuv | grep -v src/vendor/gyp
