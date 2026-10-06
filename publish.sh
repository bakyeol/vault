#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h}"
cd "$project_dir"

if [[ "$(git branch --show-current)" != "v5" ]]; then
  print -u2 "배포 중단: 현재 브랜치가 v5가 아닙니다."
  exit 1
fi

if [[ "$(git remote get-url origin)" != "https://github.com/bakyeol/vault.git" ]]; then
  print -u2 "배포 중단: origin이 예상한 저장소가 아닙니다."
  exit 1
fi

if ! git diff --cached --quiet; then
  print -u2 "배포 중단: 이미 스테이징된 변경이 있습니다. 먼저 확인하고 커밋하세요."
  exit 1
fi

npm run quartz -- build
git add -- content/ quartz.config.yaml publish.sh PUBLISHING.md AGENTS.md "사이트 배포.command"

if git diff --cached --quiet; then
  print "공개할 새 콘텐츠가 없습니다."
  exit 0
fi

git commit -m "Publish notes and site settings"
git push origin v5
