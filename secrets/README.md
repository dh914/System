# Secrets

이 디렉터리는 **SOPS + age**로 암호화된 자격증명만 보관합니다.
평문 파일은 절대 커밋하지 마세요 — `.gitignore`로 차단되어 있지만 손으로 우회하지 말 것.

## 구조

- `credentials.enc.yaml` — 모든 계정/API 키 모음 (암호화됨)
- `.sops.yaml` (리포 루트) — 암호화 정책: `age` 공개키, 암호화 대상 필드

## 복호화 / 편집

비공개 키 `AGE-SECRET-KEY-...`를 안전한 곳(1Password, iCloud Keychain 등)에 보관하고,
사용 시 환경변수로 전달합니다.

```bash
export SOPS_AGE_KEY="AGE-SECRET-KEY-...본인 키..."

# 전체 복호화 (stdout)
sops --decrypt secrets/credentials.enc.yaml

# 편집기로 in-place 편집 (저장 시 자동 재암호화)
sops secrets/credentials.enc.yaml

# 특정 값만 추출 (jq 같은 도구는 복호화 후 yq로)
sops --decrypt secrets/credentials.enc.yaml | yq '.api_keys.openrouter.api_key'
```

## 새 키 추가

```bash
# 1) 평문 임시 파일을 /tmp 등 리포 외부에 작성
# 2) sops --encrypt --age <public-key> /tmp/new.yaml > secrets/new.enc.yaml
# 3) 평문 파일 즉시 shred -u
```

## age 키 회전

1. `age-keygen -o new-key.txt`로 새 키쌍 생성
2. `.sops.yaml`의 `age:` 값을 새 공개키로 교체
3. 기존 비공개 키로 한 번 복호화 후 새 공개키로 재암호화:
   ```bash
   sops updatekeys secrets/credentials.enc.yaml
   ```
4. 옛 비공개 키 폐기

## 주의

- public 리포지토리이므로 암호화된 파일이라도 **양자 컴퓨터 시대 이후의 미래까지 안전을 보장하지 않습니다**. 정말 민감한 키는 GitHub Actions Secrets 또는 외부 비밀 관리자(1Password, Doppler 등)를 권장합니다.
- 자격증명이 채팅·이슈·PR 본문 등 어디든 평문으로 노출되면 **즉시 발급처에서 rotate**하세요.
