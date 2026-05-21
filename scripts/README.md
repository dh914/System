# scripts

로컬 머신에서 `dh914/System` 체크아웃을 항상 원격과 동일하게 유지하기 위한 도구.

## sync.sh

`origin`을 fetch 한 뒤 기본 브랜치로 **하드 리셋**합니다. 로컬 수정 사항은 자동 stash 후 버려집니다(stash 항목 자체는 남음). 사실상 "원격이 진실, 로컬은 그 복사본"이라는 모델입니다.

```bash
SYSTEM_REPO_DIR=~/System scripts/sync.sh
```

`.sync.log`가 리포 루트에 남습니다.

## macOS (launchd)

```bash
cp scripts/launchd/com.dh914.system-sync.plist ~/Library/LaunchAgents/
# plist 안의 /Users/CHANGEME/System 두 곳을 실제 경로로 교체
launchctl load ~/Library/LaunchAgents/com.dh914.system-sync.plist
```

기본 2분 간격(`StartInterval`=120). 즉시 반영이 필요하면 60초 이하로 줄이거나, 아래 webhook 방식 사용.

## Linux (systemd user)

```bash
mkdir -p ~/.config/systemd/user
cp scripts/systemd/system-sync.service ~/.config/systemd/user/
cp scripts/systemd/system-sync.timer   ~/.config/systemd/user/
# 필요시 service 안의 %h/System 경로 수정
systemctl --user daemon-reload
systemctl --user enable --now system-sync.timer
```

## 더 즉각적인 동기화가 필요하면

폴링 대신 GitHub Webhook → 로컬 리스너 조합을 권장:
- 무료 도구: [smee.io](https://smee.io/) + `smee-client` (로컬에서 `smee → curl localhost:PORT/sync`)
- 또는 `cloudflared tunnel`로 로컬 포트 노출 후 GitHub Webhook을 그쪽으로 발사
- 리스너가 `scripts/sync.sh`만 호출하면 됨

폴링 2분이면 충분한 경우가 대부분이라 별도 추가는 보류했습니다.
