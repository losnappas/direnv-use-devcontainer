use_devcontainer() {
  #TODO: should add all executables from paths that aren't "default".
  #e.g. I'd want all python package executables by default.
  # Running into issues when adding a lot of executables from /usr/bin, etc.
  # I think it's because it adds like "bash" and some of those bug out direnv.

  # check which programs exist in container
  # create executor wrapper
  # add executor wrappers to path
  local script_dir="$PWD"
  local devcontainer_dir="$script_dir/.devcontainer"
  local wrappers_dir="$devcontainer_dir/wrappers"
  local run_in_container="devcontainer exec --workspace-folder '$script_dir' --"

  if [ -d "$wrappers_dir" ]; then
    PATH_add "$wrappers_dir"
    return
  fi
  mkdir -p "$wrappers_dir"
  PATH_add "$wrappers_dir"

  # shellcheck disable=SC2016
  local programs="$(devcontainer exec --workspace-folder "$script_dir" sh -c '
IFS=":"
for dir in $PATH; do
  if [ -z "$dir" ] || [ ! -d "$dir" ]; then
    continue
  fi
  s="$(find "$dir" -maxdepth 1 -executable -exec basename "{}" \;)"
  echo -n "$s"
done
')"
  IFS=$'\n'
  included_programs=(python3 pip pip3 node pnpm npm yarn ghci uvicorn gvicorn go sudo gotest apk apt yum)
  included_programs+=($*)
  for program in $programs; do
    if ! _containsElement "$program" "${included_programs[@]}"; then
      continue
    fi
    local target="$wrappers_dir/$program"
    {
    echo "#!/bin/sh"
    echo "# Remove wrappers from path to avoid collision of 'node'."
    # Man, the shell quoting, I swear.
    echo "export PATH=\"\$(echo \"\$PATH\" | sed \"s|$wrappers_dir:||\")\""
    echo "$run_in_container" "\"$program\"" \"\$@\"
    } > "$target"
    chmod +x "$target"
  done
}

_containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

