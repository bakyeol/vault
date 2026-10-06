# 공개 범위와 배포

이 저장소는 GitHub Pages의 `https://bakyeol.github.io/vault/`에 공개됩니다. 현재 `content/`에는 Quartz 동작 확인용 테스트 문서만 들어 있습니다. 여기에 둔 Markdown 파일과 첨부 자료는 방문자가 볼 수 있습니다.

실제 Obsidian 문서를 추가하기 전에는 공개 가능한 노트와 첨부 파일만 `content/`에 선별해 넣으세요. 현재 Obsidian Documents Vault는 연결하지 않았습니다. 전체 Vault를 그대로 복사하거나 심볼릭 링크하면 비공개 메모와 첨부까지 저장소에 올라갈 수 있습니다.

공개용 Markdown을 `content/`에 넣은 뒤 프로젝트 폴더에서 `./publish.sh`를 실행하면 로컬 빌드, 콘텐츠 커밋, GitHub 업로드가 순서대로 진행됩니다. 업로드가 끝나면 GitHub Actions가 사이트를 갱신합니다. 이 스크립트는 `content/`만 커밋하도록 제한되어 있습니다.
