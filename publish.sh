#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h}"
cd "$project_dir"
repo="bakyeol/vault"
site_url="https://bakyeol.github.io/vault/"

for tool in git npm gh; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    print -u2 "배포 중단: $tool 명령을 찾을 수 없습니다."
    exit 1
  fi
done
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
gh auth status >/dev/null 2>&1 || { print -u2 "GitHub 인증을 확인하세요: gh auth login"; exit 1; }
mkdir -p .quartz-cache
lock_dir=".quartz-cache/publish.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  print -u2 "이미 통합 배포가 실행 중입니다. 먼저 열린 배포 창을 확인하세요."
  exit 1
fi
trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT
trap 'exit 130' INT TERM

print "[1/4] 사이트 빌드"
npm run quartz -- build
print "[2/4] 변경사항 저장"
git add -- content/ quartz.config.yaml publish.sh PUBLISHING.md AGENTS.md "사이트 배포.command" "사이트·GitHub 통합 배포.command"
if git diff --cached --quiet; then
  print "새 변경사항이 없습니다. 기존 커밋의 업로드와 배포 상태를 확인합니다."
else
  git commit -m "Publish notes and site settings"
fi
print "[3/4] GitHub 업로드"
git push origin v5
commit_sha="$(git rev-parse HEAD)"
print "[4/4] GitHub Pages 배포 확인"
run_id=""
for attempt in {1..12}; do
  run_id="$(gh run list --repo "$repo" --workflow deploy.yml --commit "$commit_sha" --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
  [[ -n "$run_id" ]] && break
  sleep 5
done
if [[ -z "$run_id" ]]; then
  print -u2 "업로드는 완료됐지만 해당 커밋의 Pages 실행을 찾지 못했습니다."
  print "확인: https://github.com/$repo/actions/workflows/deploy.yml"
  exit 2
fi
run_url="https://github.com/$repo/actions/runs/$run_id"
print "배포 기록: $run_url"
last_state=""
# 최대 10분 확인합니다. 대기 상태를 배포 완료로 표시하지 않습니다.
for attempt in {1..60}; do
  run_state="$(gh run view "$run_id" --repo "$repo" --json status,conclusion --jq '.status + ":" + (.conclusion // "")')"
  if [[ "$run_state" != "$last_state" ]]; then
    print "배포 상태: $run_state"
    last_state="$run_state"
  fi
  if [[ "$run_state" == "completed:success" ]]; then
    print "완료: GitHub 업로드와 Pages 배포가 모두 성공했습니다."
    print "사이트: $site_url"
    print "이전 화면이 보이면 브라우저에서 강력 새로고침(⌘⇧R)하세요."
    exit 0
  elif [[ "$run_state" == completed:* ]]; then
    print -u2 "Pages 배포가 성공하지 못했습니다: $run_state"
    gh run view "$run_id" --repo "$repo" --log-failed || true
    exit 1
  fi
  sleep 10
done
print -u2 "GitHub 업로드는 완료됐지만 Pages 배포가 아직 대기 또는 실행 중입니다."
print "배포 기록에서 완료 여부를 확인하세요: $run_url"
exit 2
