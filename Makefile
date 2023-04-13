.PHONY : build
build :
	dune build -p luv

.PHONY : test
test :
	dune runtest --no-buffer --force

.PHONY : examples
examples :
	dune build \
	  example/hello_world.exe \
	  example/delay.exe \
	  example/print_using_file.exe \
	  example/print_using_pipe.exe \
	  example/print_using_tty.exe \
	  example/idle.exe \
	  example/cat.exe \
	  example/onchange.exe \
	  example/tcp_echo_server.exe \
	  example/tcp_hello_world.exe \
	  example/udp_echo_server.exe \
	  example/udp_hello_world.exe \
	  example/host.exe \
	  example/http_get.exe \
	  example/readme.exe \
	  example/ifconfig.exe \
	  example/threads.exe \
	  example/thread_pool.exe \
	  example/mutex.exe \
	  example/progress.exe \
	  example/spawn.exe \
	  example/stdout.exe \
	  example/pipe.exe \
	  example/pipe_echo_server.exe \
	  example/pipe_hello_world.exe \
	  example/send_signal.exe \
	  example/sigint.exe
	_build/default/example/hello_world.exe
	_build/default/example/delay.exe
	_build/default/example/print_using_file.exe
	_build/default/example/print_using_pipe.exe
	bash -c "[ A$$TRAVIS == Atrue ]" || \
	  _build/default/example/print_using_tty.exe
	_build/default/example/idle.exe
	_build/default/example/cat.exe LICENSE.md
	(_build/default/example/onchange.exe false LICENSE.md || true) & \
	  (sleep 1; touch LICENSE.md)
	_build/default/example/tcp_echo_server.exe & \
	  (_build/default/example/tcp_hello_world.exe; \
	   sleep 1; killall tcp_echo_server.exe)
	_build/default/example/udp_echo_server.exe & \
	  (_build/default/example/udp_hello_world.exe; \
	   sleep 1; killall udp_echo_server.exe)
	_build/default/example/host.exe localhost
	_build/default/example/http_get.exe google.com /
	_build/default/example/readme.exe || true
	_build/default/example/ifconfig.exe
	_build/default/example/threads.exe
	_build/default/example/thread_pool.exe
	_build/default/example/mutex.exe
	_build/default/example/progress.exe
	_build/default/example/spawn.exe
	_build/default/example/stdout.exe
	_build/default/example/pipe.exe
	rm -f echo-pipe
	_build/default/example/pipe_echo_server.exe & \
	  (_build/default/example/pipe_hello_world.exe; \
	   sleep 1; killall pipe_echo_server.exe)
	_build/default/example/send_signal.exe
	bash -c "[ A$$TRAVIS == Atrue ]" || _build/default/example/sigint.exe

.PHONY : test-installation
test-installation : clean
	opam pin add -y --no-action luv . --kind=path
	opam reinstall -y luv
	cd test/installation && dune exec ./user.exe
	cd test/headers && dune exec ./headers.exe
	opam remove -y luv

.PHONY : test-installation-ci
test-installation-ci :
	opam pin add -y --no-action luv . --kind=git
	opam install -y luv
	cd test/installation && dune exec ./user.exe
	cd test/headers && dune exec ./headers.exe
	opam remove -y luv
	opam pin remove -y luv

LATEST_TAG := \
  git for-each-ref refs/tags \
    --sort=-taggerdate --format='%(refname:short)' --count=1

.PHONY : upgrade-libuv
upgrade-libuv :
	# (cd src/c/vendor/libuv && git fetch)
	# (cd src/c/vendor/libuv && git checkout `$(LATEST_TAG)`)
	make clean
	make eject-build
	ocaml src/gen/headers.ml
	(make && make test) || true
	@echo
	@echo "Sanity check:"
	@echo
	@(cd src/c/vendor/libuv && git log --pretty=oneline -n 5)
	@echo
	@git status
	@echo
	@echo "To get the tests to pass, edit at least test/version.ml. Then, fix"
	@echo "any other errors, review the changelog, and expose any new features."
	@echo "For examples, see commits around earlier libuv version upgrades."
	@echo "Suggestions for review:"
	@echo
	@echo "  make view-libuv-changelog"
	@echo "  git diff"
	@echo

.PHONY : view-libuv-changelog
view-libuv-changelog :
	(cd src/c/vendor/libuv && git show `$(LATEST_TAG)`)

AUTOGEN_OUTPUT := src/c/vendor/configure
AUTOGEN_SCRATCH := libuv-scratch

.PHONY : eject-build
eject-build :
	rm -rf $(AUTOGEN_SCRATCH)
	cp -r src/c/vendor/libuv $(AUTOGEN_SCRATCH)
	(cd $(AUTOGEN_SCRATCH) && ./autogen.sh)
	rm -rf $(AUTOGEN_OUTPUT)
	mkdir -p $(AUTOGEN_OUTPUT)
	mkdir -p $(AUTOGEN_OUTPUT)/m4
	(diff -qr src/c/vendor/libuv $(AUTOGEN_SCRATCH) || true) \
	  | sed 's#^Only in ##' \
	  | sed 's#: #/#' \
	  | sed 's#^$(AUTOGEN_SCRATCH)/##' \
	  | xargs -I FILE cp -r $(AUTOGEN_SCRATCH)/FILE $(AUTOGEN_OUTPUT)/FILE
	rm -rf $(AUTOGEN_SCRATCH)
	(cd $(AUTOGEN_OUTPUT) && rm -rf aclocal.m4 autom4te.cache m4)
	(cd src/c/vendor/libuv && git rev-parse HEAD) \
	  > $(AUTOGEN_OUTPUT)/commit-hash

.PHONY : check-ejected-build
check-ejected-build :
	@((cd src/c/vendor/libuv && git rev-parse HEAD) \
	  | diff $(AUTOGEN_OUTPUT)/commit-hash -) || \
	  (echo; \
       echo The vendored configure script is out of sync with libuv. Run; \
	   echo; \
	   echo "  make eject-build"; \
	   echo; \
	   echo and commit the changes to $(AUTOGEN_OUTPUT).; \
	   echo; \
	   false)

.PHONY : install-autotools
install-autotools :
	sudo apt install automake libtool

.PHONY : docs
docs : api-docs luvbook

.PHONY : api-docs
api-docs :
	dune build @doc -p luv

.PHONY : luvbook
luvbook :
	sphinx-build -b html docs docs/_build

.PHONY : watch-api-docs
watch-api-docs : api-docs
	inotifywait -mr -e modify --format '%f' src \
	  | xargs -L1 -I X make api-docs

.PHONY : watch-luvbook
watch-luvbook : luvbook
	inotifywait -mr -e modify docs/conf.py docs/*.rst example \
	  | xargs -L1 -I X make luvbook

.PHONY : install-sphinx
install-sphinx :
	sudo apt install python3-pip
	pip3 install -U sphinx

# make watch-api-docs &
# make watch-luvbook &
# open _build/default/_doc/_html/index.html
# open docs/_build/index.html

DOCS := ../gh-pages

.PHONY : stage-docs
stage-docs : api-docs luvbook
	[ -d $(DOCS) ] || git clone git@github.com:aantron/luv.git $(DOCS)
	cd $(DOCS) && git checkout gh-pages
	rm -rf $(DOCS)/*
	cp -r _build/default/_doc/_html/* $(DOCS)
	cp -r docs/_build/* $(DOCS)
	cd $(DOCS) && mv _static static
	cd $(DOCS) && mv _sources sources
	cd $(DOCS) && mv _odoc_support odoc_support
	cd $(DOCS) && ls *.html | xargs -L1 sed -i 's#_static/#static/#g'
	cd $(DOCS) && ls *.html | xargs -L1 sed -i 's#_sources/#sources/#g'
	cd $(DOCS) && find -name '*.html' | xargs -L1 sed -i 's#_odoc_support/#odoc_support/#g'
	cd $(DOCS) && git add -A && git commit --amend --no-edit --reset-author

.PHONY : publish-docs
publish-docs : stage-docs
	cd $(DOCS) && git push --force-with-lease

VERSION := $(shell git describe --abbrev=0)
RELEASE := luv-$(VERSION)

.PHONY : release
release : check-ejected-build clean
	rm -rf $(RELEASE) $(RELEASE).tar $(RELEASE).tar.gz _release
	mkdir $(RELEASE)
	cp -r dune-project LICENSE.md luv.opam luv_unix.opam README.md src $(RELEASE)
	rm -rf $(RELEASE)/src/c/vendor/libuv/docs
	rm -rf $(RELEASE)/src/c/vendor/libuv/img
	rm -rf $(RELEASE)/src/c/vendor/libuv/test
	rm -rf $(RELEASE)/src/c/vendor/libuv/tools
	rm -rf $(RELEASE)/src/c/vendor/libuv/m4
	rm -rf $(RELEASE)/src/gen
	tar cf $(RELEASE).tar $(RELEASE)
	ls -l $(RELEASE).tar
	gzip -9 $(RELEASE).tar
	mkdir -p _release
	cp $(RELEASE).tar.gz _release
	(cd _release && tar xf $(RELEASE).tar.gz)
	opam pin add -y --no-action luv _release/$(RELEASE) --kind=path
	opam reinstall -y --verbose luv
	cd test/installation && dune exec ./user.exe --root .
	opam remove -y luv
	opam pin remove -y luv
	md5sum $(RELEASE).tar.gz
	ls -l $(RELEASE).tar.gz

.PHONY : clean
clean :
	dune clean
	rm -rf _build docs/_build luv-* *.tar *.tar.gz _release *.install echo-pipe
