#!/bin/bash

# Soundness CLI 다중 키 생성 자동화 스크립트
# Ubuntu(apt) 및 macOS(brew) 환경 지원

set -e  # 오류 발생 시 스크립트 중단

# ANSI 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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
echo -e "${GREEN}Soundness CLI 다중 키 생성 자동 설치 스크립트${NC}"
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
  
  # 명령어 경로 확인
  SOUNDNESS_CLI_PATH=$(which soundness-cli 2>/dev/null || echo "$HOME/.soundness/bin/soundness-cli")
  
  if [ ! -f "$SOUNDNESS_CLI_PATH" ]; then
    echo -e "${RED}soundness-cli 실행 파일을 찾을 수 없습니다.${NC}"
    manual_key_instructions
    return
  fi
  
  # 키 개수 입력 받기
  echo -e "${CYAN}생성할 키 개수를 입력하세요 (1-100): ${NC}"
  read -p "" KEY_COUNT
  
  # 입력값 검증
  if ! [[ "$KEY_COUNT" =~ ^[0-9]+$ ]] || [ "$KEY_COUNT" -lt 1 ] || [ "$KEY_COUNT" -gt 100 ]; then
    echo -e "${RED}유효하지 않은 입력입니다. 1에서 100 사이의 숫자를 입력하세요.${NC}"
    setup_keys
    return
  fi
  
  echo -e "${GREEN}${KEY_COUNT}개의 키를 생성합니다.${NC}"
  
  # 결과를 저장할 파일 준비
  RESULT_FILE="$HOME/soundness_keys_$(date +%Y%m%d%H%M%S).txt"
  echo "# Soundness Layer 키 목록" > "$RESULT_FILE"
  echo "# 생성 시간: $(date)" >> "$RESULT_FILE"
  echo "# ---------------------------------" >> "$RESULT_FILE"
  echo "" >> "$RESULT_FILE"
  
  # 각 키 생성
  for ((i=1; i<=KEY_COUNT; i++)); do
    KEY_NAME="key_${i}"
    echo -e "${BLUE}[$i/$KEY_COUNT] 키 생성 중: ${KEY_NAME}${NC}"
    
    # 키 생성 명령 실행 (비대화형 모드로)
    "$SOUNDNESS_CLI_PATH" generate-key --name "$KEY_NAME" </dev/null || {
      echo -e "${RED}키 생성 중 오류가 발생했습니다: ${KEY_NAME}${NC}"
      continue
    }
    
    # 생성된 키의 정보 가져오기
    KEY_INFO=$("$SOUNDNESS_CLI_PATH" list-keys | grep -A 1 "$KEY_NAME")
    
    if [ -n "$KEY_INFO" ]; then
      # 키 정보 추출
      PUBLIC_KEY=$(echo "$KEY_INFO" | tail -n 1 | awk '{print $2}')
      
      # 결과 파일에 추가
      echo "## $KEY_NAME" >> "$RESULT_FILE"
      echo "Public Key: $PUBLIC_KEY" >> "$RESULT_FILE"
      echo "Discord Command: !access $PUBLIC_KEY" >> "$RESULT_FILE"
      echo "" >> "$RESULT_FILE"
      
      echo -e "${GREEN}키 생성 완료: ${KEY_NAME}${NC}"
      echo -e "${PURPLE}Public Key: ${PUBLIC_KEY}${NC}"
    else
      echo -e "${RED}키 정보를 가져오는 데 실패했습니다: ${KEY_NAME}${NC}"
    fi
  done
  
  # 전체 키 목록 표시
  echo -e "${YELLOW}전체 키 목록:${NC}"
  "$SOUNDNESS_CLI_PATH" list-keys
  
  echo -e "${GREEN}키 생성이 완료되었습니다.${NC}"
  echo -e "${GREEN}키 정보가 저장된 파일: ${RESULT_FILE}${NC}"
  
  # 니모닉 백업 안내
  echo -e "${YELLOW}개별 키의 니모닉을 백업하려면 다음 명령을 사용하세요:${NC}"
  echo -e "${CYAN}soundness-cli export-key --name [키_이름]${NC}"
  echo -e "${RED}경고: 니모닉 구문은 안전하게 보관하고 절대 공유하지 마세요.${NC}"
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
  echo -e "   soundness-cli generate-key --name key_1"
  echo -e "${BLUE}3. 키 목록 확인:${NC}"
  echo -e "   soundness-cli list-keys"
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
  echo -e "${GREEN}Soundness CLI 설치 및 키 생성이 완료되었습니다!${NC}"
  echo -e "${YELLOW}주요 명령어 안내:${NC}"
  echo -e "${BLUE}soundnessup install${NC}  # CLI 설치"
  echo -e "${BLUE}soundnessup update${NC}   # 최신 버전으로 업데이트"
  echo -e "${BLUE}soundness-cli list-keys${NC}  # 키 목록 확인"
  echo -e "${BLUE}soundness-cli export-key --name [키_이름]${NC}  # 니모닉 백업"
  echo -e "${GREEN}====================================${NC}"
  
  echo -e "${YELLOW}참고: 일부 기능은 터미널을 재시작하거나 다음 명령을 실행한 후에 사용할 수 있습니다:${NC}"
  if [ "$SHELL_TYPE" == "zsh" ]; then
    echo -e "${BLUE}source $ENV_FILE${NC}"
  else
    echo -e "${BLUE}source $RC_FILE${NC}"
  fi
  
  echo -e "${YELLOW}테스트넷 등록을 위해 생성된 모든 키 정보는 다음 파일에서 확인할 수 있습니다:${NC}"
  echo -e "${GREEN}$HOME/soundness_keys_*.txt${NC}"
}

# 스크립트 실행
main
