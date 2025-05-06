# Soundness CLI 원터치 설치 스크립트

이 저장소는 [Soundness Layer](https://github.com/soundnesslabs/soundness-layer) 테스트넷에 참여하기 위한 CLI 도구를 쉽게 설치할 수 있는 원터치 스크립트를 제공합니다.

## 기능

- Ubuntu 및 macOS 환경 자동 감지
- bash 및 zsh 쉘 자동 감지
- 필수 의존성 패키지 자동 설치
- Soundness CLI 설치 및 환경 변수 설정
- 키 페어 자동 생성
- 테스트넷 등록을 위한 지침 제공

## 시스템 요구사항

- Ubuntu 또는 macOS 운영체제
- bash 또는 zsh 쉘
- 관리자 권한 (일부 패키지 설치에 필요)

## 설치 방법

### 빠른 설치 (원터치)

1. 스크립트를 다운로드합니다:
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/soundness-setup/main/soundness_setup.sh -o soundness_setup.sh
```

2. 실행 권한을 부여합니다:
```bash
chmod +x soundness_setup.sh
```

3. 스크립트를 실행합니다:
```bash
./soundness_setup.sh
```

### 수동 설치

Soundness CLI를 수동으로 설치하려면 다음 단계를 따르세요:

1. Soundness CLI 설치:
```bash
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
```

2. 환경 변수 설정:
```bash
# bash 사용 시
source ~/.bashrc

# zsh 사용 시
source ~/.zshenv
```

3. 키 생성:
```bash
soundness-cli generate-key --name my-key
```

4. 키 목록 확인:
```bash
soundness-cli list-keys
```

## 테스트넷 등록

1. 키 목록에서 공개키를 확인합니다:
```bash
soundness-cli list-keys
```

2. Discord의 `testnet-access` 채널에서 다음 명령을 사용하여 액세스를 요청합니다:
```
!access <base64-encoded-public-key>
```

## 문제 해결

### 환경 변수 문제

스크립트 실행 후 `command not found` 오류가 발생하면 다음 명령을 실행하세요:

```bash
# bash 사용 시
source ~/.bashrc

# zsh 사용 시
source ~/.zshenv
```

### 키 생성 문제

키 생성 중 오류가 발생하면 수동으로 다음 명령을 실행하세요:

```bash
soundness-cli generate-key --name default-key
```

## 주요 명령어

* `soundnessup install` - CLI 설치
* `soundnessup update` - 최신 버전으로 업데이트
* `soundness-cli generate-key --name my-key` - 새 키 생성
* `soundness-cli list-keys` - 저장된 키 목록 확인
* `soundness-cli export-key --name my-key` - 저장된 키의 니모닉 구문 내보내기

## 보안 주의사항

⚠️ **경고**: 니모닉 구문을 안전하게 보관하고 절대 공유하지 마세요. 니모닉을 가진 사람은 귀하의 키 페어에 접근할 수 있습니다.

## 라이선스

MIT

## 관련 링크

* [Soundness Layer GitHub](https://github.com/soundnesslabs/soundness-layer)
* [Soundness Labs 공식 웹사이트](https://soundness.com/)
* [Soundness Labs Discord](https://discord.gg/soundness)
