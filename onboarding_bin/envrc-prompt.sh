#!/usr/bin/env bash

echo "Setting up your environment..."

# Git Email
echo "Current value: [$GIT_EMAIL_ADDRESS_PROFESSIONAL]"
read -rp "Enter your git email address for your GitHub organization. IE: octocat@gmail.com (press Enter to keep current): " userInput
GIT_EMAIL_ADDRESS_PROFESSIONAL="${userInput:-$GIT_EMAIL_ADDRESS_PROFESSIONAL}"

# User Name
echo "Current value: [$CURRENT_NAME]"
read -rp "Enter your name on this machine: " userInput
CURRENT_NAME="${userInput:-$CURRENT_NAME}"

# Machine User
echo "Current value: [$CURRENT_USER]"
read -rp "Enter your CURRENT_USER: " userInput
CURRENT_USER="${userInput:-$CURRENT_USER}"

# GitHub URL
echo "Current value: [$CURRENT_USER_GITHUB_URL]"
read -rp "Enter your CURRENT_USER_GITHUB_URL: " userInput
CURRENT_USER_GITHUB_URL="${userInput:-$CURRENT_USER_GITHUB_URL}"

# Company Name
echo "Current value: [$CURRENT_COMPANY]"
read -rp "Enter your CURRENT_COMPANY: " userInput
CURRENT_COMPANY="${userInput:-$CURRENT_COMPANY}"

# IDE Path
echo "Current value: [$IDE_PATH]"
read -rp "Enter your IDE_PATH: " userInput
IDE_PATH="${userInput:-$IDE_PATH}"

# JIRA Base URL
echo "Current value: [$JIRA_BASE_URL]"
read -rp "Enter your JIRA_BASE_URL: " userInput
JIRA_BASE_URL="${userInput:-$JIRA_BASE_URL}"

# GPG Key
echo "Current value: [$CURRENT_USER_GPG_KEY]"
read -rp "Enter your CURRENT_USER_GPG_KEY (leave blank if none): " userInput
CURRENT_USER_GPG_KEY="${userInput:-$CURRENT_USER_GPG_KEY}"

# JIRA User Email
echo "Current value: [$JIRA_USER_EMAIL]"
read -rp "Enter your JIRA_USER_EMAIL: " userInput
JIRA_USER_EMAIL="${userInput:-$JIRA_USER_EMAIL}"

cat <<EOF >.envrc
#!/usr/bin/env bash

# Dotfiles Environment Variables (Generated)

# Sensitive Variables
GIT_EMAIL_ADDRESS_PROFESSIONAL="${GIT_EMAIL_ADDRESS_PROFESSIONAL}"

# Non-Sensitive Variables
CURRENT_NAME="${CURRENT_NAME}"
CURRENT_USER="${CURRENT_USER}"
CURRENT_USER_GITHUB_URL="${CURRENT_USER_GITHUB_URL}"
CURRENT_COMPANY="${CURRENT_COMPANY}"
IDE_PATH="${IDE_PATH}"
JIRA_BASE_URL="${JIRA_BASE_URL}"
CURRENT_USER_GPG_KEY="${CURRENT_USER_GPG_KEY}"
JIRA_USER_EMAIL="${JIRA_USER_EMAIL}"
EOF

echo ".envrc has been created or updated."
