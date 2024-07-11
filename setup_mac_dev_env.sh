#!/bin/zsh

check_command() {
  local cmd=$1
  local name=$2
  local install_flag=$3

  if command -v "$cmd" &>/dev/null; then
    echo "✅ $name is installed"
  else
    echo "❌ $name is not installed"
    eval "$install_flag=1"
  fi
}

check_github_private_token() {
    if [ -f ~/.npmrc ] && grep -q "authToken" ~/.npmrc; then
      echo "✅ ~/.npmrc with personal api github token exists"
        
    else
      echo "❌ ~/.npmrc with github personal api token missing"
      missing_github_token=1
    fi
}

install_github_api_token() {
  echo "See how to create Github token here: https://www.notion.so/tibber/Onboarding-1cbdbdf16130440783b1da8733f973d4#27acd60f2b0649c1ade68942028b3beb" 
  echo "Please enter your GitHub private token:"
  read -s TOKEN

  echo "//npm.pkg.github.com/:_authToken=$TOKEN" > "$HOME/.npmrc"
  echo "~/.npmrc has been created with your GitHub token."
}

has_default_ssh_key() {
  SSH_KEY_PATTERNS=("id_rsa" "id_ecdsa" "id_ecdsa_sk" "id_ed25519" "id_ed25519_sk")
  for key in "${SSH_KEY_PATTERNS[@]}"; do
      if [ -f "$HOME/.ssh/$key" ]; then
          echo "✅ Found potential GitHub SSH key: $key"
          return 1
      fi
  done
  return 0
}

# You can specify a specific ssh key for github
has_github_ssh_config() {
  if grep -q "Host github.com" ~/.ssh/config 2>/dev/null; then
    echo "✅ GitHub entry in ~/.ssh/config exists"
    return 1
  else
    return 0
  fi
}

check_ssh_config() {
  if has_default_ssh_key || has_github_ssh_config; then
    echo "❌ Neither default SSH Key or ~/.ssh/config with GitHub entry found"
    missing_ssh_config=1
  fi
}

check_aws_config() {
  if grep -q "\[default\]" ~/.aws/config 2>/dev/null; then
    echo "✅ ~/.aws/config has [default] entry"
  else
    echo "❌ ~/.aws/config missing [default] entry. See docs: https://www.notion.so/tibber/Onboarding-1cbdbdf16130440783b1da8733f973d4#9980ce95df1d43748980fe8d17e7392f"
    missing_aws_config=1
  fi
}

check_aws_vpn() {
  if [ -d "/Applications/AWS VPN Client" ]; then
    echo "✅ AWS VPN client installed"
  else
    echo "❌ AWS VPN client is not installed"
    missing_aws_vpn_client=1
  fi
}

prompt_install() {
  printf "Do you want to install the missing applications now? (y/n): "
  read choice
  case "$choice" in
    y|Y)
      install_missing
      ;;
    n|N)
      echo "Installation skipped."
      ;;
    *)
      echo "Invalid choice. Installation skipped."
      ;;
  esac
}

install_homebrew() {
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_aws_cli() {
  echo "Installing aws-cli..."
  brew install awscli
}

install_aws_vpn_client() {
  echo "Installing AWS VPN client..." 
  brew install --cask aws-vpn-client
}

install_yawsso() {
  echo "Installing yawsso..."
  brew install yawsso
}

run_aws_config() {
  echo "Running AWS SSO config. See: See docs: https://www.notion.so/tibber/Onboarding-1cbdbdf16130440783b1da8733f973d4#9980ce95df1d43748980fe8d17e7392f"
  aws configure sso
}

install_missing() {
  if [[ "$missing_homebrew" -eq 1 ]]; then
    install_homebrew
    # Ensure brew is available in PATH after installation
    export PATH="/opt/homebrew/bin:$PATH"
  fi
  [[ "$missing_github_token" -eq 1 ]] && install_github_api_token
  [[ "$missing_aws_cli" -eq 1 ]] && install_aws_cli
  [[ "$missing_aws_vpn_client" -eq 1 ]] && install_aws_vpn_client
  [[ "$missing_yawsso" -eq 1 ]] && install_yawsso
  [[ "$missing_aws_config" -eq 1 ]] && run_aws_config
}

main() {
  echo -e "Welcome to the experimental Tibber Engineering setup tool! This tool aims to automate as much as possible when it comes to setting up your work environment. This is work in progress and a shared engineering effort, which means feedback and contributions are most welcome. Feel free to provide those on Slack via #developers, and PR submissions via https://github.com/tibber/tibber-tools/tree/master/onboarding.\n"
  missing_homebrew=0
  missing_github_token=0
  missing_aws_cli=0
  missing_ssh_config=0
  missing_aws_vpn_client=0
  missing_aws_config=0
  missing_yawsso=0

  check_command "brew" "Homebrew" missing_homebrew  
  check_command "aws" "aws-cli" missing_aws_cli
  check_command "yawsso" "yawsso" missing_yawsso
  check_aws_vpn
  check_github_private_token
  check_ssh_config
  check_aws_config

  if (( missing_homebrew || missing_github_token || missing_aws_cli || missing_ssh_config || missing_aws_vpn_client || missing_aws_config )); then
    prompt_install
  else
    echo -e "\n🥳 All checks passed!"
  fi
}

main
