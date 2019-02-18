.PHONY : build
build :
	dune build src/vendor/libuv.a
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

.PHONY : todos
todos :
	@grep -rn TODO src test Makefile README.md luv.opam \
	  | grep -v _build | grep -v src/vendor/libuv | grep -v src/vendor/gyp
