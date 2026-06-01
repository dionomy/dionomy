#!/usr/bin/env zsh
set +e

ports=(
  "5173 frontend"
  "8080 backend"
)

blocked=0

for entry in "${ports[@]}"; do
  port="${entry%% *}"
  label="${entry#* }"
  listeners="$(lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | awk 'NR > 1 { print $1 " pid=" $2 " " $9 }')"

  if [[ -n "$listeners" ]]; then
    blocked=1
    print "[warn] $label 포트 $port 사용 중"
    print "$listeners"
  fi
done

if (( blocked > 0 )); then
  print ""
  print "기존 dev 서버가 실행 중이면 그대로 사용하세요."
  print "새로 띄우려면 해당 프로세스를 종료한 뒤 just dev를 다시 실행하세요."
  exit 1
fi

exit 0
