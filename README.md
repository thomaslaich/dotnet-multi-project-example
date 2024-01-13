# .NET nix template for very simple multi-project repo

Initialize your project by running:

```bash
$ nix flake init --template github:thomaslaich/dotnet-multi-project-example
```

If you don't have `nix` installed, run this first:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Tools used:

- [Nix](https://srid.ca/haskell-nix) + [Flakes](https://serokell.io/blog/practical-nix-flakes)
- [devenv](https://devenv.sh/) and [direnv](https://direnv.net/) for development shell
- [just](https://just.systems/) as a task runner; run `just` in devshell

## Develop

Simply run the following command from the root of the project:

```bash
$ nix develop --impure
```

This will install a .NET SDK in version 8 and all other required dependencies in a completely isolated way (they will not interfere
with any system installations of .NET SDK or any other software).

For even better ergonomics, install [direnv](https://direnv.net/) using your favourite package manager. After that, just `cd` into the directory.
(Note that you might have to run `direnv allow` inside the directory once.)

When using `vscode` or `emacs`, use the corresponding direnv extension:
- [direnv for VSCode](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv)
- [direnv for Rider](https://plugins.jetbrains.com/plugin/19275-better-direnv)
- [direnv for Emacs](https://melpa.org/#/direnv)

## Restore

To build the entire solution:

```bash
$ just restore
```

## Build

To build the entire solution:

```bash
$ just build
```

## Run the application

To run an application:

```bash
$ just run
```

Alternatively, you can run the application without cloning the repo:

```bash
$ nix run github:thomaslaich/dotnet-multi-project-example
```




