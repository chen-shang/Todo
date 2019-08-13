#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2155
source ../../BaseShell/Starter/BaseHeader.sh
source ../../BackUp/Date/BaseLocalDateTime.sh
source ./../../BaseShell/Utils/BaseRandom.sh
source ./../config.sh
#===============================================================================
manual(){
echo "
-l︴列表
-l \${id}︴详情
-h/-help/?︴帮助文档
-d \${id}︴完成" |column -s '︴' -t|lolcat
}
todo(){
  firstParam=$1 #一参
  case ${firstParam} in
  ?|help) #帮助文档
    manual
  ;;
  -a|add) #增
    todo_add
  ;;
  -r|delete) #删
    todo_remove "$2"
  ;;
  -d|done) #改
    todo_done "$2"
  ;;
  -l|list|"") #查
    todo_show "${TODO_LIST}" "$2"
  ;;
  -c|clear) #清
    true > "${TODO_LIST}"
    echo "clear done"
  ;;
  -h|history) #历史详情
    todo_show "${TODO_LIST_HISTORY}" "$2"
  ;;
  -f|filter)
  ;;
  -q|quit)
    exit
  ;;
  -s|show)
    todo_show "${TODO_LIST}" "$2"
    exit
  ;;
  *)
    echo "not a valid cmd"
  ;;
  esac
  read -r -p "> " -a cmd
  todo ${cmd[@]}
}

# 添加todo
todo_add(){
  local now=$(localdatetime_now)
  read -r -p "[标题] " title
  realTitle="${title}"
  if [[ -z "${title}" ]];then
    exit
  fi
  read -r -p "[详情] " detail
  if [[ -n "${detail}" ]];then
       realTitle+="*"
  fi
  read -r -p "[标签${INDEXES}] " index
  read -r -p "[优先级 5] " priority
  tag="${TAGS[index]}"

  echo "${ICONS[$(random_int 17)]}︴${now}︴${realTitle}︴${tag:-work}︴${priority:-0}︴TODO︴${detail:--}" >> "${TODO_LIST}"
}

todo_done(){ _NotNull "$1" "id can not be null"
  local id=$1
  local title=$(sed -n "${id}p" "${TODO_LIST}"|column -s "︴" -t|awk '{print $3}')
  local status=$(sed -n "${id}p" "${TODO_LIST}"|column -c 1 -s "︴" -t|awk '{print $6}')
  if [[ "DONE" == "${status}" ]];then
    todo_remove ${id}
  else
    sed -i '' "${id}s/︴TODO︴/︴DONE︴/g" "${TODO_LIST}"
    echo "done: ${title}"
  fi
}

todo_remove(){ _NotNull "$1" "id can not be null"
  local id=$1
  local title=$(sed -n "${id}p" "${TODO_LIST}"|column -s "︴" -t|awk '{print $3}')
  # 不保证事务
  # 写历史表
  sed  -n "${id}p" "${TODO_LIST}" >> "${TODO_LIST_HISTORY}"
  # 删原纪录
  sed -i '' "${id}d" "${TODO_LIST}"
  echo "delete: ${title}"
}

# 展示todo [List<String>]<-(file:String,id:int)
todo_show(){  _NotNull "$1" "file can not be null"
  local file=$1
  local id=$2

  if [[ -n "${id}" ]];then
    # 指定id显示详情
    body=$(sed -n "${id}p" "${TODO_LIST}"|column -s "︴" -t|awk -v id="${id}" '{print id,$1,$2,$3,$4,$5,$6}')
    detail=$(sed -n "${id}p" "${TODO_LIST}"|column -s "︴" -t|awk -v id="${id}" '{print $7}')
    echo -e "${HEADER}\n${body}"|column -t|lolcat
    echo -e "详情:\n    ${detail}"|lolcat
  else
    # 未指定id显示列表
    body=$(cat < "${file}"|nl|column -c 1 -s "︴" -t|awk '{print $1,$2,$3,$4,$5,$6,$7}'|sort -rk 6)
    echo -e "${HEADER}\n${body}"|column -t|lolcat
  fi
}
#===============================================================================
source ../../BaseShell/Starter/BaseEnd.sh
