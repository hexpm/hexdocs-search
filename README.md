# Hexdocs Search

Hexdocs Search is part of the improvement of Hexdocs, that can be followed
[in its respective issue](https://github.com/hexpm/hexdocs/issues/49). Hexdocs
Search exists as a playground and a preview, in order to implement the desired
features, before being given to Hex.pm organization, or merged into Hexdocs main
repository.

As such, it can be easily run from any environment, while Gleam and the BEAM are
present. Installing Gleam can be done in two main ways, depending on your
environment. For development purpose, the project relies on
[`mise`](https://mise.jdx.dev/) to simplify installation of runtimes and
tooling.

## Installation with `mise`

Once `mise` is installed, you only need to install the runtime & compiler!

```sh
mise install
```

## Installation without `mise`

`mise` is a nice way to get tooling in an easy way, but installing it can be
cumbersome for some. As such, you can simply run the project with plain simple
installations of Erlang and Gleam.
[Gleam can be installed by following that guide](https://gleam.run/getting-started/installing/).
If you follow that guide, you should automatically get Erlang and the BEAM. If
you did not, take a look at
[Erlang Solutions distribution](https://www.erlang-solutions.com/downloads/).
Make sure to get Erlang 27, and Gleam 1.8.1.

## Getting started

Before getting started, check that runtime and compiler are installed.

```sh
erl -version
gleam --version
```

If everything run well, both commands should print their corresponding versions.
At that point, you need to launch the local web server.

```sh
gleam run -m lustre/dev start
```

The project should now be running at `http://localhost:1234`!
