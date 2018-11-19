<h1 align="center">Luv</h1>
<br/>



**Luv** is an OCaml and Reason binding to [libuv][libuv].

```ocaml
let _ =
  let Ok timer = Luv.Timer.init () in
  Luv.Timer.start timer 1000 (fun () -> print_endline "Hello, world!");
  Luv.Loop.(run (default ()) Run_mode.default)

(* ocamlfind opt -linkpkg -package luv foo.ml *)
```

libuv is the native I/O library that Node.js is built on. libuv is similar in
scope and design to Lwt and Async: it binds system calls for file I/O, TCP
servers, DNS, etc. Like Lwt and Async, libuv is asynchronous, but its API uses
plain callbacks instead of promises.

Because libuv is critical to Node.js, it is very portable and very
well-maintained.

Luv inherits these properties. It exposes the libuv API in OCaml, taking care of
the tricky parts of interfacing with libuv, such as:

- **Memory management** &mdash; For example, Luv keeps track of the lifetimes of
  OCaml callbacks that have been passed to libuv, and are no longer referenced
  from the OCaml "world."
- **The runtime lock** &mdash; Multithreaded OCaml and libuv programs operate
  normally.
- **API problems** &mdash; Where libuv is forced to offer difficult APIs due to
  the limitations of C, libuv's implementation language, Luv provides slightly
  more user-friendly APIs, without loss of expressiveness. Otherwise, Luv
  translates the C APIs into OCaml as literally as possible, in order to keep
  the correspondence with libuv's docs obvious.

Luv is usable standalone, but its main goal is to be integrated as a back end
into other projects, such as Repromise and Lwt. So, apart from the above, Luv
aims to be...

- **Minimalist** &mdash; Luv only takes care of *inherent* libuv headaches, such
  as memory management, and adds no bloat.
- **Unopinionated** &mdash; Luv avoids committing to design decisions beyond
  those dictated by libuv and OCaml. This keeps it suitable for multiple
  projects that might want to integrate it. This is especially important, as two
  previously incompatible I/O libraries that integrate Luv become compatible by
  doing so.
- **Maintainable** &mdash; Luv uses [Ctypes][ctypes] to minimize the amount of C
  code, and [vendors][vendor] libuv to avoid versioning issues.

Luv is pretty [well-tested][tests]. Apart from code producing the right values
and I/O effects, the test cases also check for memory leaks, lost references,
and potential issues with multithreading support.



<br/>

## Status

Luv is an early alpha at this point. The binding covers the full libuv API
(with a few exceptions), but the library might not build in various
circumstances, lacks docs, etc. This will all be addressed in upcoming
development.



<br/>

## Trying

```
git clone --recurse-submodules https://github.com/aantron/luv.git
cd luv
opam install --unset-root alcotest ctypes dune result
make libuv
make test
```

You can install Luv in your opam switch, and use it in other projects:

```
cd luv
make libuv
opam pin add --kind path luv .
```

Luv probably only works on Linux at the moment. The code is actually highly
portable, but it is likely there are minor bugs and oversights, due to a lack of
testing on other platforms. This is to be fixed in the near future :)

Also, the build system will eventually build the vendored libuv automatically,
so you won't have to run a separate `make libuv` command.



<br/>

## Documentation

Proper docs for Luv haven't been started yet. However, one can get a listing of
the available OCaml modules by looking in [`luv.ml`][luv.ml]. The modules are
listed in the same order as [libuv's API docs][libuv-api] list features. The
general libuv docs can be found [here][libuv-docs].

We will eventually write and generate nice HTML docs for Luv itself, with plenty
of links back to libuv :)



<br/>

## Roadmap

- [ ] esy packaging and build.
- [ ] Proof-of-concept integration with Lwt and Repromise.
- [ ] Vendor correctly on macOS, Windows.
- [ ] Documentation, examples, CI; user-friendly repo.
- [ ] Look into using Luv for native Node.js modules.



[libuv]: https://github.com/libuv/libuv
[ctypes]: https://github.com/ocamllabs/ocaml-ctypes
[vendor]: https://github.com/aantron/luv/tree/master/src/vendor
[tests]: https://github.com/aantron/luv/tree/master/test
[luv.ml]: https://github.com/aantron/luv/blob/master/src/luv.ml
[libuv-api]: http://docs.libuv.org/en/v1.x/api.html
[libuv-docs]: http://docs.libuv.org/en/v1.x/
