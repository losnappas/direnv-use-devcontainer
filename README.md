# direnv-use-devcontainer

A "use devcontainer" directive for direnv.

## Installation

1. Have `direnv` and `devcontainer` programs installed (`npm i -g @devcontainers/cli`)
1. Download (or clone) the use_devcontainer.sh in `~/.config/direnv/lib/use_devcontainer.sh`
1. Optional: add `.devcontainer/wrappers` to your global gitignore (I do this)

   The script creates wrappers for container executables and puts them in the wrappers folder.

## Usage

1. Have a git repo
1. Have a `.devcontainer/devcontainer.json` *in the root of the repo you're working in* (the script is using git to find the workspace root)
1. `echo "use devcontainer" >> .envrc` (or `"use devcontainer program1 program2 ..."`)
1. `direnv allow`
1. You should now be able to run some programs inside the container. See caveats

### Caveats

Not all executables from the container will be available by default. The script has a list of default ones, here's an excerpt:

```
included_programs=(python3 pip pip3 node pnpm npm yarn ...)
```

Not everything is included because:

1. It causes direnv to glitch out? Seems to hang for me
1. Programs like `cd` don't even make sense

If you find useful programs to include in the defaults, then please make a PR!
