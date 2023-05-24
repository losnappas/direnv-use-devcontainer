# direnv-use-devcontainer

A "use devcontainer" directive for direnv.

## Installation

1. Have `direnv` and `devcontainer` programs installed (`npm i -g @devcontainers/cli`)
1. Download (or clone) the use_devcontainer.sh in `~/.config/direnv/lib/use_devcontainer.sh`
1. Optional: add `.devcontainer/wrappers` to your global gitignore (I do this)

   The script creates wrappers for container executables and puts them in the wrappers folder.

## Usage

1. Have a `.devcontainer/devcontainer.json`
1. `echo "use devcontainer" >> .envrc` (or `"use devcontainer program1 program2 ..."`) on the same directory level as the `.devcontainer`
1. `direnv allow`
1. You should now be able to run some programs inside the container. See caveats

### Caveats

#### Not all executables

Not all executables from the container will be available by default. The script has a list of default ones, here's an excerpt:

```
included_programs=(python3 pip pip3 node pnpm npm yarn ...)
```

Not everything is included because:

1. It causes direnv to glitch out? Seems to hang for me
1. Programs like `cd` don't even make sense

If you find useful programs to include in the defaults, then please make a PR!

#### No refresh

I was too lazy to figure out automatic reloads for the env. You can delete the `.devcontainer/wrappers` folder and run `direnv reload` to do that.

```
$ rm -rf .devcontainer/wrappers; direnv reload
$ # There is now a reloader script included in the wrappers dir, so you can just call:
$ reloader # same as the rm -rf, though caution is always warranted
```

### Scripts

#### `on_host`

Runs things outside of the container. E.g. if you want to run host system `apt`, you can do `on_host apt --help`. It can be useful at times, e.g. you want to `npm install` on host but container doesn't have `npm`.
