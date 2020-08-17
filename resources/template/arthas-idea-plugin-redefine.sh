#!/usr/bin/env bash

# Usage: banner_simple "my title"
banner_simple() {
  local msg="* $* *"
  local edge=$(echo "$msg" | sed 's/./*/g')
  echo "$edge"
  echo "$(tput bold)$msg$(tput sgr0)"
  echo "$edge"
  echo
}
# Usage exit shell with err_code
# $1 : err_code
# $2 : err_msg
exit_on_err() {
  [[ ! -z "${2}" ]] && banner_simple $(echo $(tput setaf 1)${2} $(tput sgr0)) 1>&2
  exit ${1}
}

createFile() {
  if [ ! -f $1 ]; then
    mkdir -p "$(dirname "$1")" && touch $1 >/dev/null 2>&1 && echo "File $1 created." || return 1
  fi
}

installArthas() {
  if [ ! -d "$HOME/opt/arthas" ]; then
    banner_simple "artjas idea plugin make dir $HOME/opt/arthas"
    mkdir -p $HOME/opt/arthas || return 1
  fi
  # download arthas
  if [ ! -f "$HOME/opt/arthas/as.sh" ]; then
    banner_simple "arthas idea plugin download arthas as.sh"
    curl -sLk https://arthas.aliyun.com/as.sh --connect-timeout 60 -o $HOME/opt/arthas/as.sh || return 1
    chmod +x $HOME/opt/arthas/as.sh || return 1
  fi
}
# xxxClassBase64Str|xxxClassPath,xxxClass2Base64Str|xxxClass2Path
decodebase64CLassFile() {
  bash64FileAndPathList=$arthasIdeaPluginBase64AndPathCommand
  commaArraybash64FilePath=(${bash64FileAndPathList//\,/ })
  for i in "${!commaArraybash64FilePath[@]}"; do
    verticalArraySingleBash64FileAndPath=(${commaArraybash64FilePath[i]//\|/ })
    createFile ${verticalArraySingleBash64FileAndPath[1]}
    echo ${verticalArraySingleBash64FileAndPath[0]} | base64 --decode >${verticalArraySingleBash64FileAndPath[1]} || return 1
    echo "base64Class decode to path ${verticalArraySingleBash64FileAndPath[1]}"
  done
}

# Usage: doStartedefine
doStartedefine() {
  echo $(tput bold)"arthas start commnad ：$HOME/opt/arthas/as.sh --select ${arthasIdeaPluginApplicationName}  -c \"${arthasIdeaPluginRedefineCommand}\"  >/tmp/redefine.out"$(tput sgr0)
  $HOME/opt/arthas/as.sh --select ${arthasIdeaPluginApplicationName} -c "${arthasIdeaPluginRedefineCommand}" >/tmp/redefine.out
}

redefineResult() {
  cat /tmp/redefine.out
  redefineResult=$(cat /tmp/redefine.out | grep "redefine success")
  if [ -z "$redefineResult" ]; then
    banner_simple $(echo $(tput setaf 1)arthas idea plugin redefine error $(tput sgr0))
  else
    banner_simple "arthas idea plugin redefine success"
  fi
}

# too long  to transfer parameters
arthasIdeaPluginBase64AndPathCommand="${arthasIdeaPluginBase64AndPathCommand}"
# the main function
main() {
  banner_simple "arthas idea plugin redefine beigin;start script full path: $(pwd)/arthas-idea-plugin-redefine.sh"

  installArthas
  if [ $? -ne 0 ]; then
    exit_on_err 1 "arthas install as.sh script error"
  fi

  decodebase64CLassFile
  if [ $? -ne 0 ]; then
    exit_on_err 1 "arthas idea plugin decodebase64CLass error"
  fi

  doStartedefine

  redefineResult
}

main "${@}"
