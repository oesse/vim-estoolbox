#!/usr/bin/env bash
usage() {
  echo "usage: $(basename $1) TARGET_FILE DIR" 
  echo "or:    $(basename $1) --help" 
  echo "Find javascript files in DIR importing TARGET_FILE."
  exit 0
}
error() {
  local exe=$(basename $1)
  echo "$exe: $2" 1>&2
  echo "Try '$exe --help' for more information." 1>&2
  exit 1
}

args=()
while [ $# -gt 0 ]; do
  case $1 in
    -h|--help)
      usage $0
      ;;
    -*)
      error $0 "invalid option '$1'"
      ;;
    *)
      args+=($1)
  esac
  shift
done
[[ ${#args[@]} != 2 ]] && error $0 "invalid number of arguments"
[[ ! -f ${args[0]} ]] && error $0 "invalid target file '${args[0]}'"
[[ ! -d ${args[1]} ]] && error $0 "invalid search directory '${args[1]}'"

target_file=${args[0]} 
search_directory=${args[1]}

if [[ ! -z "$(which rxg 2>/dev/null)" ]]; then
  search_cmd="$(which rg) --vimgrep --type js"
elif [[ ! -z "$(which ag 2>/dev/null)" ]]; then
  search_cmd="$(which ag) --vimgrep --js"
else
  search_cmd="grep --recursive --perl-regexp --with-filename --line-number --byte-offset --exclude-from=.gitignore"
fi

# === end validation === 

find_imports() {
  local target_file_name=${1##*/}
  local target_file_base=${target_file_name%.*}
  local pattern_find_imports="from '[^']*/$target_file_base'"
  if [[ "$target_file_base" == "index" ]]; then
    local dir_path=${1%/*}
    local dir_name=${dir_path##*/}
    pattern_find_imports="from '(\\.\\.?(/..)*')|([^']*/$dir_name')"
  fi
  local search_dir=$2
  $search_cmd "$pattern_find_imports" $search_dir 
}

mask_filename_and_import_ref() {
  sed -e 's/:\([0-9]*\):[^'"'"']*/:\1:/' | sed -e "s/'//g"
}

resolve_abs_path() {
  (cd "$(dirname "$1")" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}


resolve_path() {
  local filepath=$(echo "$1" | cut -d: -f1)
  local dirpath=$(dirname $filepath)
  local reference=$(echo "$1" | cut -d: -f3)

  if [[ $reference != .* ]]; then
    return
  fi
 
  local relpath=$(ls $dirpath/$reference{.js{,x},/index.{js,jsx}} 2> /dev/null)

  # styl, coffee other file that is not found here
  [[ -z "$relpath" ]] && return

  local abspath=$(resolve_abs_path "$relpath")
  echo $(echo "$1" | cut -d: -f1-2):${abspath#$(pwd)/}
}

filter_reference_to_target() {
  local target=$1
  grep '[^:]*:'"$target"'$'
}

remove_resolved_path() {
  cut -d: -f-2
}

# =============================================================================
export -f resolve_abs_path
export -f resolve_path
find_imports "$target_file" "$search_directory" \
  | mask_filename_and_import_ref \
  | xargs -P 0 -n 1 -I {} bash -c 'resolve_path {}' \
  | filter_reference_to_target "$target_file" \
  | remove_resolved_path

