cd ~/Documents &&
  mkdir -p AMU/repos/amu-development-team &&
  cd ~/Documents/AMU/repos/amu-development-team &&
  git clone https://"${YOUR_GITHUB_PAT}":x-oauth-basic@github.com/${COMPANY_NAME}/amu-onboarding.git &&
  cd amu-onboarding &&
  cp .envrc.example .envrc &&
  open .envrc
