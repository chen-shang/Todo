#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2155
source ./../../BaseShell/Utils/BaseHeader.sh
source ./../../BaseShell/Date/BaseLocalDateTime.sh
source ./../../BaseShell/Utils/BaseRandom.sh
source ./../config.sh
#===============================================================================
manual(){
echo "todo︴ ︴默认进入添加模式
todo︴-l︴列表
todo︴-l \${id}︴详情
todo︴-h/-help/?︴帮助文档
todo︴-d \${id}︴完成" |column -s '︴' -t|lolcat
}
todo(){
  firstParam=$1 #一参
  case ${firstParam} in
  -h|-help|?) #帮助文档
    manual
  ;;
  "") #增
    todo_show "${TODO_LIST}" "$2"
    todo_add "simple"
  ;;
  -a) #添
    todo_show "${TODO_LIST}" "$2"
    todo_add
  ;;
  -r) #删
    todo_remove "$2"
  ;;
  -d) #改
    todo_done "$2"
  ;;
  -l) #查
    todo_show "${TODO_LIST}" "$2"
  ;;
  -c) #清
    true > "${TODO_LIST}"
    echo "clear done"
  ;;
  history) #历史详情
    todo_show "${TODO_LIST_HISTORY}" "$2"
  ;;
  -f)
  ;;
  *)
  ;;
  esac
}

# 添加todo
todo_add(){
    local simple="$1"

    local num=1
    while :;do
      local now=$(localdatetime_now)
      echo "[TODO ${num}]"
      read -r -p "[标题] " title
      realTitle="${title}"
      if [[ -z "${title}" ]];then
        exit
      fi
      if [[ -z "${simple}"  ]];then
        read -r -p "[详情] " detail
        if [[ -n "${detail}" ]];then
           realTitle+="*"
        fi
        read -r -p "[标签${INDEXES}] " index
        read -r -p "[优先级 5] " priority
        tag="${TAGS[index]}"
      fi

      echo "${ICONS[$(random_next 17)]}︴${now}︴${realTitle}︴${tag:-work}︴${priority:-0}︴TODO︴${detail:--}" >> "${TODO_LIST}"
      ((num++))
    done
}

todo_done(){
  local id=$1
  if [[ -n "${id}" ]];then
    sed -i '' "${id}s/︴TODO︴/︴DONE︴/g" "${TODO_LIST}"
  fi
  todo_show "${TODO_LIST}" "${id}"
}

todo_remove(){ _NotNull "$1" "id can not be null"
  local id=$1
  # 不保证事务
  # 写历史表
  sed  -n "${id}p" "${TODO_LIST}" >> "${TODO_LIST_HISTORY}"
  # 删原纪录
  sed -i '' "${id}d" "${TODO_LIST}"
}

# 展示todo [List<String>]<-(file:String,id:int)
todo_show(){  _NotNull "$1" "file can not be null"
  local file=$1
  local id=$2

  if [[ -n "${id}" ]];then
    # 指定id显示详情
    body=$(cat < "${file}"|nl|column -c 1 -s "︴" -t|awk -v id="${id}" 'NR==id{print $1,$2,$3,$4,$5,$6,$7}'|sort -rk 6)
    detail=$(cat < "${file}"|nl|column -s "︴" -t|awk -v id="${id}"  'NR==id{ for(i=1; i<=7; i++){ $i="" }; print $0 }')
    echo -e "${HEADER}\n${body}"|column -t|lolcat
    echo -e "${detail}"
  else
    # 未指定id显示列表
    body=$(cat < "${file}"|nl|column -c 1 -s "︴" -t|awk '{print $1,$2,$3,$4,$5,$6,$7}')
    echo -e "${HEADER}\n${body}"|column -t|lolcat
  fi
}
#===============================================================================
source ./../../BaseShell/Utils/BaseEnd.sh
    