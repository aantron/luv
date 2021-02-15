# Luv &nbsp;&nbsp; [![libuv][libuv-version]][libuv-releases] [![CI status][ci-img]][ci]

[libuv-releases]: https://github.com/libuv/libuv/releases
[libuv-version]: https://img.shields.io/badge/libuv-1.41.0-blue.svg
[ci]: https://github.com/aantron/luv/actions
[ci-img]: https://img.shields.io/github/workflow/status/aantron/luv/ci/master?label=ci

[**Luv**][luv] is an OCaml/ReasonML binding to [libuv][libuv], the
cross-platform C library that does asynchronous I/O in Node.js and runs Node's
main loop.

Here's an example, which retrieves the Google search page:

```ocaml
let () =
  Luv.DNS.getaddrinfo ~family:`INET ~node:"google.com" ~service:"80" ()
      begin fun result ->

    let address = (List.hd (Result.get_ok result)).addr in
    let socket = Luv.TCP.init () |> Result.get_ok in
    Luv.TCP.connect socket address begin fun _ ->

      Luv.Stream.write socket [Luv.Buffer.from_string "GET / HTTP/1.1\r\n\r\n"]
        (fun _ _ -> Luv.Stream.shutdown socket ignore);

      Luv.Stream.read_start socket (function
        | Error `EOF -> Luv.Handle.close socket ignore
        | Error _ -> exit 2
        | Ok response -> print_string (Luv.Buffer.to_string response))

    end
  end;

  ignore (Luv.Loop.run () : bool)
```

<br/>

libuv does more than just asynchronous I/O. It also supports
[multiprocessing][processes] and [multithreading][threads]. You can even [run
multiple async I/O loops, in different threads][loops]. libuv wraps a lot of
other functionality, and exposes a [comprehensive operating system API][api].

Indeed, Luv does not depend on [`Unix`][unix]. It is an alternative operating
system API. Nonetheless, Luv and `Unix` can coexist readily in one program.

Because libuv is a major component of Node.js, it is
[cross-platform][platforms] and [well-maintained][maintainers]. Luv, being a
fairly thin binding, inherits these properties.

<br/>

Luv takes care of the tricky parts of dealing with libuv from OCaml:

- **Memory management** &mdash; Luv keeps track of OCaml objects that have been
  passed to libuv, and are otherwise referenced only by C callbacks.
- **The OCaml runtime lock** &mdash; multithreaded Luv programs are safe.
- **API problems** &mdash; where libuv is forced to offer difficult APIs due to
  the limitations of C, Luv provides more natural APIs.
- **The build** &mdash; when Luv is installed, it builds libuv, so users don't
  have to figure out how to do it.
- **Linking** &mdash; a specific release of libuv is statically linked into
  your  program together with Luv, and there is no dependency on a system
  installation of libuv.

Basically, when wrapped in Luv, libuv looks like any normal OCaml library, with
the kind of usage functional programmers expect.

<br/>

One of the design goals of Luv is to be easy to integrate into larger libraries,
such as [Lwt][lwt]. To that end, Luv is...

- **Minimalist** &mdash; Luv only takes care of inherent libuv headaches, such
  as memory management, building as little else as possible over libuv.
- **Unopinionated** &mdash; Luv avoids committing to design decisions beyond
  those dictated by libuv and OCaml.
- **Maintainable** &mdash; Luv uses [Ctypes][ctypes] to minimize the amount of C
  code in this repo, and [vendors][vendor] libuv to avoid versioning issues.

Luv is [thoroughly tested][tests]. Apart from checking return values and I/O
effects, the test cases also check for memory leaks, invalid references, and
potential issues with multithreading.

<br/>

## Installing

```
opam install luv
```

If using esy, add

```
"dependencies": {
  "@opam/luv": "*"
}
```

<br/>

## Documentation

- [User guide][guide]
- [API reference][api]
- [Examples][examples] &mdash; explained in the [user guide][guide].
- [libuv manual][libuv-docs]

<br/>

## Experimenting

You can run any example by cloning the repo:

```
git clone https://github.com/aantron/luv.git --recursive
cd luv
opam install --deps-only .
```

*Note: the clone *has* to be recursive, because libuv is vendored using a git
module. Also, the examples require OCaml 4.08+.*

Then, to run, say, [`delay.ml`][delay.ml]...

```
dune exec example/delay.exe
```

The first time you do this, it will take a couple minutes, because Luv will
build libuv.

You can add your own experiments to the [`example/`][examples] directory. To run
them, add the module name to [`example/dune`][example/dune], and then run them
like any other example:

```
dune exec example/my_test.exe
```

Alternatively, you can try Luv in a REPL by installing [utop][utop]:

```
opam install --unset-root utop
dune utop
```

Once you get the REPL prompt, try running `Luv.Env.environ ();;`

<br/>

## Future

- [ ] A "post-compose" functor that applies a transformation to the whole API,
for globally converting callbacks to promises, changing the error handling
strategy, etc. Prototype was [here][postcompose].
- [ ] Integration with [Lwt][lwt]. There was an old [example][lwt-integration]
that used the early post-compose functor and a [Luv-based Lwt event
loop][lwt-loop].
- [ ] Luv could make multithreaded event-driven programming very easy by lazily
initializing a loop for each thread, and storing the reference to it in a TLS
key that Luv uses internally. This could be especially powerful once OCaml has a
genuine multicore runtime.
- [ ] [`let*` operators][let] for convenient chaining of callbacks.

<br/>

## License

Luv has several pieces, with slightly different permissive licenses:

- Luv itself is under the [MIT license][license].
- This repo links to libuv with a git submodule. However, a release archive will
  generally include the full libuv source. Portions of libuv are variously
  [licensed][libuv-license] under the MIT, 2-clause BSD, 3-clause BSD, and ISC
  licenses.
- The user guide is a very heavily reworked version of [uvbook][uvbook],
  originally by Nikhil Marathe, which was incorporated into the libuv docs as
  the [libuv user guide][libuv-guide], and made available under
  [CC BY 4.0][guide-license].

[luv]: https://github.com/aantron/luv
[libuv]: https://github.com/libuv/libuv
[platforms]: https://github.com/libuv/libuv/blob/master/SUPPORTED_PLATFORMS.md#readme
[maintainers]: https://github.com/libuv/libuv/blob/master/MAINTAINERS.md#readme
[ctypes]: https://github.com/ocamllabs/ocaml-ctypes#readme
[vendor]: https://github.com/aantron/luv/tree/master/src/c/vendor
[tests]: https://github.com/aantron/luv/tree/master/test
[guide]: https://aantron.github.io/luv/
[api]: https://aantron.github.io/luv/luv/index.html#api-reference
[examples]: https://github.com/aantron/luv/tree/master/example
[libuv-docs]: http://docs.libuv.org/en/v1.x/
[experiment]: https://aantron.github.io/luv/introduction.html
[lwt]: https://github.com/ocsigen/lwt#readme
[license]: https://github.com/aantron/luv/blob/master/LICENSE.md
[libuv-license]: https://github.com/libuv/libuv/blob/v1.x/LICENSE
[uvbook]: https://github.com/nikhilm/uvbook
[libuv-guide]: http://docs.libuv.org/en/v1.x/guide.html
[guide-license]: https://github.com/aantron/luv/blob/master/docs/LICENSE
[processes]: https://aantron.github.io/luv/processes.html
[threads]: https://aantron.github.io/luv/threads.html
[loops]: https://aantron.github.io/luv/threads.html#multiple-event-loops
[unix]: https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html
[delay.ml]: https://github.com/aantron/luv/blob/master/example/delay.ml
[example/dune]: https://github.com/aantron/luv/blob/master/example/dune
[utop]: https://github.com/ocaml-community/utop
[postcompose]: https://github.com/aantron/luv/blob/0eae7f30ef99157bda77c62e0cb82169410de583/src/promisify_signatures.ml
[lwt-integration]: https://github.com/aantron/luv/blob/0eae7f30ef99157bda77c62e0cb82169410de583/example/http_get_lwt/http_get_lwt.ml
[lwt-loop]: https://github.com/aantron/luv/blob/0eae7f30ef99157bda77c62e0cb82169410de583/src/lwt/luv_lwt.ml
[let]: https://github.com/aantron/luv/blob/0eae7f30ef99157bda77c62e0cb82169410de583/src/syntax/syntax.mli#L6-L15
