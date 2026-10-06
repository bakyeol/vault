#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
project_dir="${0:A:h}"
cd "$project_dir" || exit 1
print "사이트 · GitHub 통합 배포"
print "공개 주소: https://bakyeol.github.io/vault/"
/bin/zsh "$project_dir/publish.sh"
result=$?
if (( result == 2 )); then
  print "업로드 후 배포 대기 상태입니다. 위 GitHub 실행 링크를 확인하세요."
elif (( result != 0 )); then
  print -u2 "배포를 중단했습니다. 위 오류를 확인하세요."
fi
read -r "reply?창을 닫으려면 Enter를 누르세요. "
exit "$result"
