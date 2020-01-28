# Luv &nbsp;&nbsp; [![version 0.5.0][version]][releases] [![libuv 1.34.2][libuv-version]][libuv-releases] [![Travis status][travis-img]][travis]

[releases]: https://github.com/aantron/luv/releases
[version]: https://img.shields.io/badge/version-0.5.0~dev-blue.svg
[libuv-releases]: https://github.com/libuv/libuv/releases
[libuv-version]: https://img.shields.io/badge/libuv-1.34.2-blue.svg
[travis]: https://travis-ci.org/aantron/luv
[travis-img]: https://img.shields.io/travis/aantron/luv/master.svg?label=travis

[**Luv**][luv] is a binding from OCaml/ReasonML to [libuv][libuv], the C
library that does asynchronous I/O in Node.js.

```ocaml
let () =
  (* Create a 1-second timer. *)
  let timer = Luv.Timer.init () |> Stdlib.Result.get_ok in
  ignore @@ Luv.Timer.start timer 1000 (fun () ->
    print_endline "Hello, world!");

  (* Run the main loop. *)
  ignore @@ Luv.Loop.run ()
```

<br/>

Luv exposes a [comprehensive operating system API][api].

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

<br/>

## Documentation

- [User Guide][guide]
- [API reference][api]
- [Examples][examples] &mdash; explained in the User Guide.
- [libuv manual][libuv-docs]

<br/>

## Experimenting

The User Guide has [instructions][experiment] on how to clone the repo and
quickly write your own experiments, or how to run Luv in a REPL.

<br/>

## License

Luv has several pieces, with slightly different permissive licenses:

- Luv itself is under the [MIT license][license].
- This repo links to libuv with a git module. However, a release archive will
  generally include the full libuv source. Portions of libuv are variously
  [licensed][libuv-license] under the MIT, 2-clause BSD, 3-clause BSD, and ISC
  licenses.
- Similarly, this repo links to [gyp][gyp], which is part of the libuv build
  process, and is included in Luv release archives. gyp is
  [licensed][gyp-license] under the 3-clause BSD license.
- The User Guide is a very heavily reworked version of [uvbook][uvbook],
  originally by Nikhil Marathe, which was incorporated into the libuv docs as
  the [libuv User Guide][libuv-guide], and made available under
  [CC BY 4.0][guide-license].

[luv]: https://github.com/aantron/luv
[libuv]: https://libuv.org/
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
[gyp]: https://gyp.gsrc.io/
[license]: https://github.com/aantron/luv/blob/master/LICENSE.md
[libuv-license]: https://github.com/libuv/libuv/blob/v1.x/LICENSE
[gyp-license]: https://chromium.googlesource.com/external/gyp/+/refs/heads/master/LICENSE
[uvbook]: https://github.com/nikhilm/uvbook
[libuv-guide]: http://docs.libuv.org/en/v1.x/guide.html
[guide-license]: https://github.com/aantron/luv/blob/master/docs/LICENSE
