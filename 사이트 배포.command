#!/bin/zsh
# Finder에서 더블클릭하면 현재 content 폴더를 빌드하고 공개 사이트에 올립니다.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
project_dir="${0:A:h}"
cd "$project_dir" || exit 1
print "공개 사이트: https://bakyeol.github.io/vault/"
print "content 폴더의 자료를 빌드하고 GitHub에 업로드합니다."
/bin/zsh "$project_dir/publish.sh"
result=$?
if (( result == 0 )); then
  print "완료: GitHub Actions 배포가 끝나면 사이트에 반영됩니다."
else
  print -u2 "실패: 위 오류를 확인하세요. 종료 코드: $result"
fi
read -r "reply?창을 닫으려면 Enter를 누르세요. "
exit "$result"
