.PHONY : build
build :
	dune build src/vendor/libuv.a
	dune build -p luv

.PHONY : test
test :
	dune build src/vendor/libuv.a
	dune build test/tester.exe
	dune runtest -j 1 --no-buffer --force

.PHONY : test-ci
test-ci :
	dune build src/vendor/libuv.a
	dune build @default test/tester.exe @runtest --no-buffer --force

.PHONY : test-examples
test-examples :
	dune build \
	  example/delay/delay.exe \
	  example/http_get/http_get.exe \
	  example/http_get_lwt/http_get_lwt.exe \
	  example/http_get_repromise/http_get_repromise.exe \
	  example/interop_repromise_lwt/interop_repromise_lwt.exe \
	  example/tcp_echo_server/tcp_echo_server.exe
	_build/default/example/delay/delay.exe
	_build/default/example/http_get/http_get.exe google.com > /dev/null
	_build/default/example/http_get_lwt/http_get_lwt.exe google.com > /dev/null
	_build/default/example/http_get_repromise/http_get_repromise.exe \
	  google.com > /dev/null
	_build/default/example/interop_repromise_lwt/interop_repromise_lwt.exe

.PHONY : test-installation
test-installation : clean
	opam pin add -y --no-action luv . --kind=path
	opam reinstall -y luv
	cd test/installation && dune exec ./user.exe
	opam remove -y luv

.PHONY : test-installation-ci
test-installation-ci :
	opam pin add -y --no-action luv . --kind=git
	opam install -y luv
	cd test/installation && dune exec ./user.exe
	opam remove -y luv
	opam pin remove -y luv

.PHONY : clean
clean :
	dune clean

.PHONY : todos
todos :
	@grep -rn TODO example src test .travis.yml Makefile README.md *.opam \
	  | grep -v 'src/vendor/[^/][^/]*/' | grep -v grep
