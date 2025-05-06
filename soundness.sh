#!/bin/bash

# Soundness CLI 설치 및 설정 자동화 스크립트
# Ubuntu(apt) 및 macOS(brew) 환경 지원

set -e  # 오류 발생 시 스크립트 중단

# ANSI 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 색상 초기화

# 로고 출력
echo -e "${BLUE}"
echo "  _____                      _                    "
echo " / ____|                    | |                   "
echo "| (___   ___  _   _ _ __   __| |_ __   ___  ___ ___ "
echo " \___ \ / _ \| | | | '_ \ / _\` | '_ \ / _ \/ __/ __|"
echo " ____) | (_) | |_| | | | | (_| | | | |  __/\__ \__ \\"
echo "|_____/ \___/ \__,_|_| |_|\__,_|_| |_|\___||___/___/"
echo -e "${NC}"
echo -e "${GREEN}Soundness CLI 자동 설치 스크립트${NC}"
echo ""

# 운영체제 확인
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="ubuntu"
    echo -e "${GREEN}Ubuntu 운영체제가 감지되었습니다.${NC}"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo -e "${GREEN}macOS 운영체제가 감지되었습니다.${NC}"
  else
    echo -e "${RED}지원되지 않는 운영체제입니다. Ubuntu 또는 macOS가 필요합니다.${NC}"
    exit 1
  fi
}

# 쉘 타입 확인
detect_shell() {
  if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_TYPE="zsh"
    echo -e "${GREEN}Zsh 쉘이 감지되었습니다.${NC}"
    if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
      echo -e "${GREEN}Oh My Zsh가 설치되어 있습니다.${NC}"
      OH_MY_ZSH="true"
    else
      OH_MY_ZSH="false"
    fi
    RC_FILE="$HOME/.zshrc"
    ENV_FILE="$HOME/.zshenv"
  else
    SHELL_TYPE="bash"
    echo -e "${GREEN}Bash 쉘이 감지되었습니다.${NC}"
    RC_FILE="$HOME/.bashrc"
    ENV_FILE="$HOME/.bashrc"
  fi
}

# 필수 패키지 설치
install_dependencies() {
  echo -e "${YELLOW}필수 패키지를 설치합니다...${NC}"
  
  if [ "$OS" == "ubuntu" ]; then
    sudo apt update
    sudo apt install -y curl build-essential pkg-config libssl-dev
    
    # Rust가 설치되어 있는지 확인
    if ! command -v cargo &> /dev/null; then
      echo -e "${YELLOW}Rust를 설치합니다...${NC}"
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source "$HOME/.cargo/env"
    else
      echo -e "${GREEN}Rust가 이미 설치되어 있습니다.${NC}"
    fi
    
  elif [ "$OS" == "macos" ]; then
    # Homebrew가 설치되어 있는지 확인
    if ! command -v brew &> /dev/null; then
      echo -e "${YELLOW}Homebrew를 설치합니다...${NC}"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo -e "${GREEN}Homebrew가 이미 설치되어 있습니다.${NC}"
    fi
    
    brew install curl openssl pkg-config
    
    # Rust가 설치되어 있는지 확인
    if ! command -v cargo &> /dev/null; then
      echo -e "${YELLOW}Rust를 설치합니다...${NC}"
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source "$HOME/.cargo/env"
    else
      echo -e "${GREEN}Rust가 이미 설치되어 있습니다.${NC}"
    fi
  fi
  
  echo -e "${GREEN}필수 패키지 설치가 완료되었습니다.${NC}"
}

# Soundness CLI 설치
install_soundness_cli() {
  echo -e "${YELLOW}Soundness CLI를 설치합니다...${NC}"
  
  # 공식 설치 스크립트 사용
  curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
  
  # 환경 변수 설정 확인
  if [ "$SHELL_TYPE" == "zsh" ]; then
    # zsh 환경에서는 .zshenv 파일에 환경변수 추가
    if ! grep -q "soundness" "$ENV_FILE"; then
      echo 'export PATH="$HOME/.soundness/bin:$PATH"' >> "$ENV_FILE"
    fi
  else
    # bash 환경에서는 .bashrc 파일에 환경변수 추가
    if ! grep -q "soundness" "$RC_FILE"; then
      echo 'export PATH="$HOME/.soundness/bin:$PATH"' >> "$RC_FILE"
    fi
  fi
  
  # 현재 세션에 환경 변수 적용
  export PATH="$HOME/.soundness/bin:$PATH"
  
  # 현재 쉘에 bashrc 또는 zshrc 적용
  if [ "$SHELL_TYPE" == "zsh" ]; then
    source "$ENV_FILE" 2>/dev/null || true
  else
    source "$RC_FILE" 2>/dev/null || true
  fi
  
  echo -e "${GREEN}Soundness CLI 설치가 완료되었습니다.${NC}"
  
  # soundnessup 명령 실행
  echo -e "${YELLOW}Soundness CLI를 업데이트합니다...${NC}"
  soundnessup install || echo -e "${YELLOW}soundnessup 명령을 찾을 수 없습니다. 환경 변수 설정이 필요할 수 있습니다.${NC}"
}

# 키 생성 및 관리
setup_keys() {
  echo -e "${YELLOW}Soundness CLI 키 페어를 생성합니다...${NC}"
  
  # 키 이름 설정
  KEY_NAME="default-key"
  
  # 키가 이미 존재하는지 확인
  if [ -d "$HOME/.soundness/keys" ] && [ "$(ls -A "$HOME/.soundness/keys" 2>/dev/null)" ]; then
    echo -e "${GREEN}키가 이미 존재합니다. 키 목록을 확인합니다.${NC}"
    if command -v soundness-cli &> /dev/null; then
      soundness-cli list-keys || echo -e "${RED}키 목록 조회 실패${NC}"
    else
      echo -e "${RED}soundness-cli 명령을 찾을 수 없습니다.${NC}"
    fi
    return
  fi
  
  # 명령어 경로 확인
  SOUNDNESS_CLI_PATH=$(which soundness-cli 2>/dev/null || echo "$HOME/.soundness/bin/soundness-cli")
  
  if [ ! -f "$SOUNDNESS_CLI_PATH" ]; then
    echo -e "${RED}soundness-cli 실행 파일을 찾을 수 없습니다.${NC}"
    manual_key_instructions
    return
  fi
  
  echo -e "${BLUE}키 생성 중...${NC}"
  echo -e "${YELLOW}명령 실행: $SOUNDNESS_CLI_PATH generate-key --name $KEY_NAME${NC}"
  
  # 키 생성 명령 실행 (비대화형 모드로)
  "$SOUNDNESS_CLI_PATH" generate-key --name "$KEY_NAME" </dev/null || {
    echo -e "${RED}키 생성 중 오류가 발생했습니다.${NC}"
    manual_key_instructions
    return
  }
  
  # 키 목록 조회
  echo -e "${YELLOW}생성된 키 목록:${NC}"
  "$SOUNDNESS_CLI_PATH" list-keys || {
    echo -e "${RED}키 목록 조회 실패${NC}"
    manual_key_instructions
    return
  }
}

# 수동 키 생성 안내
manual_key_instructions() {
  echo -e "${YELLOW}다음 단계를 수동으로 실행해 주세요:${NC}"
  echo -e "${BLUE}1. 터미널 환경 변수 적용:${NC}"
  if [ "$SHELL_TYPE" == "zsh" ]; then
    echo -e "   source $ENV_FILE"
  else
    echo -e "   source $RC_FILE"
  fi
  echo -e "${BLUE}2. 키 생성:${NC}"
  echo -e "   soundness-cli generate-key --name default-key"
  echo -e "${BLUE}3. 키 목록 확인:${NC}"
  echo -e "   soundness-cli list-keys"
  echo -e "${BLUE}4. 테스트넷 등록을 위해 위 명령의 출력에서 공개키를 복사하여 Discord에 입력:${NC}"
  echo -e "   !access <base64-encoded-public-key>"
}

# 메인 함수
main() {
  detect_os
  detect_shell
  install_dependencies
  install_soundness_cli
  
  # 환경 변수 재설정 (명시적)
  if [ -d "$HOME/.soundness/bin" ]; then
    export PATH="$HOME/.soundness/bin:$PATH"
    echo -e "${GREEN}PATH 환경 변수에 $HOME/.soundness/bin 추가됨${NC}"
  fi
  
  setup_keys
  
  echo -e "${GREEN}====================================${NC}"
  echo -e "${GREEN}Soundness CLI 설치가 완료되었습니다!${NC}"
  echo -e "${YELLOW}CLI 사용 방법:${NC}"
  echo -e "${BLUE}soundnessup install${NC}  # CLI 설치"
  echo -e "${BLUE}soundnessup update${NC}   # 최신 버전으로 업데이트"
  echo -e "${GREEN}====================================${NC}"
  
  echo -e "${YELLOW}참고: 일부 기능은 터미널을 재시작하거나 다음 명령을 실행한 후에 사용할 수 있습니다:${NC}"
  if [ "$SHELL_TYPE" == "zsh" ]; then
    echo -e "${BLUE}source $ENV_FILE${NC}"
  else
    echo -e "${BLUE}source $RC_FILE${NC}"
  fi
  
  echo -e "${YELLOW}테스트넷 등록을 위해 다음 단계를 따르세요:${NC}"
  echo -e "${BLUE}1. 키 목록 확인:${NC}"
  echo -e "   soundness-cli list-keys"
  echo -e "${BLUE}2. 위 명령의 결과에서 공개키를 복사하여 Discord의 testnet-access 채널에서 사용:${NC}"
  echo -e "   !access <base64-encoded-public-key>"
}

# 스크립트 실행
main
