# System

이 리포지토리는 GitHub의 모든 활동을 자동으로 수집·기록합니다.

## 동작 방식

`.github/workflows/activity-log.yml` 워크플로우가 리포지토리에서 발생하는 모든
주요 이벤트(push, pull_request, issues, issue_comment, release, fork, star,
workflow_run, discussion 등)를 감지하고, 다음 두 가지 형식으로 저장합니다.

- `logs/events/YYYY/MM/YYYY-MM-DD.md` — 사람이 읽기 좋은 한 줄 요약
- `logs/raw/YYYY/MM/*.json` — GitHub이 전송한 원본 이벤트 페이로드 전체

각 이벤트가 발생할 때마다 `github-actions[bot]`이 `main` 브랜치에 직접 커밋·푸시합니다.

## 주의

- 로그는 자동 생성되므로 손으로 수정하지 마세요. 다음 이벤트 발생 시 머지 충돌이 발생할 수 있습니다.
- 비공개 정보가 포함된 이벤트 페이로드가 그대로 저장되므로, 리포지토리 가시성을 신중히 설정하세요.
- 워크플로우 실행 자체도 `workflow_run` 이벤트로 기록되어 무한 루프가 우려될 수 있지만,
  `workflow_run`은 commit/push로 인한 push 이벤트와 달리 워크플로우 완료 시점에만 트리거되며
  로그 작성 워크플로우는 `push` 이벤트로 다시 트리거되지 않도록 `concurrency` 그룹과
  최소한의 변경만 커밋하는 방식으로 동작합니다.
