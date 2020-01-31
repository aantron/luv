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
	opam remove -y luv

.PHONY : test-installation-ci
test-installation-ci :
	opam pin add -y --no-action luv . --kind=git
	opam install -y luv
	cd test/installation && dune exec ./user.exe
	opam remove -y luv
	opam pin remove -y luv

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
	cd $(DOCS) && ls *.html | xargs -L1 sed -i 's#_static/#static/#g'
	cd $(DOCS) && ls *.html | xargs -L1 sed -i 's#_sources/#sources/#g'
	cd $(DOCS) && git add -A && git commit --amend --no-edit --reset-author

.PHONY : publish-docs
publish-docs : stage-docs
	cd $(DOCS) && git push --force-with-lease

VERSION := $(shell git describe)
RELEASE := luv-$(VERSION)

.PHONY : release
release : clean
	rm -rf $(RELEASE) $(RELEASE).tar $(RELEASE).tar.gz _release
	mkdir $(RELEASE)
	cp -r dune-project LICENSE.md luv.opam README.md src $(RELEASE)
	rm -rf $(RELEASE)/src/c/vendor/gyp/test
	rm -rf $(RELEASE)/src/c/vendor/gyp/tools
	rm -rf $(RELEASE)/src/c/vendor/libuv/docs
	rm -rf $(RELEASE)/src/c/vendor/libuv/img
	sed -i "s/version: \"dev\"/version: \"$(VERSION)\"/" $(RELEASE)/luv.opam
	diff -u luv.opam $(RELEASE)/luv.opam || true
	tar cf $(RELEASE).tar $(RELEASE)
	ls -l $(RELEASE).tar
	gzip -9 $(RELEASE).tar
	ls -l $(RELEASE).tar.gz
	mkdir -p _release
	cp $(RELEASE).tar.gz _release
	(cd _release && tar xf $(RELEASE).tar.gz)
	opam pin add -y --no-action luv _release/$(RELEASE) --kind=path
	opam reinstall -y --verbose luv
	cd test/installation && dune exec ./user.exe
	opam remove -y luv
	opam pin remove -y luv
	md5sum $(RELEASE).tar.gz

.PHONY : clean
clean :
	dune clean
	rm -rf docs/_build luv-* *.tar *.tar.gz _release *.install echo-pipe
