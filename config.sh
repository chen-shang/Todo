#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2155
SHOW_BANNER=1

TODO_LIST="/Users/chenshang/Learn/shell/Todo/Resources/TodoList"
TODO_LIST_HISTORY="/Users/chenshang/Learn/shell/Todo/Resources/TodoListHistory"

ICONS=('🐶' '🐱' '🐭' '🐹' '🐰' '🐻' '🐼' '🐨' '🐮' '🐵' '🐜' '🦇' '🦉' '🐘' '🐓' '🐇' '🐈' '🦌')
TAGS=(work learn study)
HEADER="id icon create todo tag priority status"
for i in ${!TAGS[@]};do
  INDEXES+=" ${i}:${TAGS[i]}"
done