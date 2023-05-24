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
  echo "$s"
done
')"
  IFS=$'\n'
  included_programs=(python3 pip pip3 node pnpm npm npx yarn ghci uvicorn gvicorn go sudo gotest apk apt yum)
  included_programs+=($*)
  for program in $(printf "%s\n" $programs | sort -u); do
    if test -z "$program" || ! _containsElement "$program" "${included_programs[@]}"; then
      continue
    fi
    local target="$wrappers_dir/$program"
    {
    echo "#!/bin/sh"
    echo "# Remove wrappers from path to avoid collision of 'node'."

    # The shell quoting... I swear.
    echo "export PATH=\"\$(echo \"\$PATH\" | sed \"s|$wrappers_dir:||\")\""

    printf "%s\n" "
current_dir=\"\$PWD\"
target_dir=\"\${current_dir#$script_dir}\"
target_dir=\"\${target_dir#/}\"

# Quote args so spaces don't mess it up.
args_to_program=''
for arg in \"\$@\"; do
    args_to_program=\"\$args_to_program '\$arg'\"
done

if [ -n \"\$target_dir\" ]
then
    $run_in_container sh -c \"cd \$target_dir; $program \$args_to_program\"
else
    $run_in_container sh -c \"$program \$args_to_program\"
fi
"
    } > "$target"
    chmod +x "$target"
  done
  _mk_reloader "$wrappers_dir"
}

_mk_reloader() {
  printf "#!/bin/sh
rm -rf %s; direnv reload" "$1" >> "$1/reload"
  chmod u+x "$1/reload"
}

_containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

