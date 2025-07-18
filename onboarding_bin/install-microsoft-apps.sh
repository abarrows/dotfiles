#!/bin/bash

# Cross-platform script to install Microsoft Outlook and Microsoft Teams
# Supports macOS (via Homebrew) and Windows (via Chocolatey)
# Run this script with: bash install-microsoft-apps.sh

# Note: Removed 'set -e' to allow graceful handling of already-installed apps

echo "🖥️  Cross-Platform Microsoft Applications Installer"
echo "================================================="

# Detect operating system
OS="unknown"
case "$(uname -s)" in
    Darwin*)
        OS="macOS"
        echo "🍎 Detected macOS"
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        OS="Windows"
        echo "🪟 Detected Windows"
        ;;
    Linux*)
        echo "❌ Linux detected but not supported"
        echo "This script only supports macOS and Windows."
        exit 1
        ;;
    *)
        echo "❌ Unsupported operating system: $(uname -s)"
        echo "This script only supports macOS and Windows."
        exit 1
        ;;
esac
echo "================================================="

# Function to install and use Homebrew (macOS)
install_with_homebrew() {
    echo "🍺 Using Homebrew for macOS installation..."

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for the current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            export PATH="/usr/local/bin:$PATH"
        fi

        echo "✅ Homebrew installed successfully"
    else
        echo "✅ Homebrew found, proceeding with installation..."
    fi

    # Update Homebrew
    echo "🔄 Updating Homebrew..."
    if ! brew update; then
        echo "⚠️  Warning: Could not update Homebrew, continuing anyway..."
    fi

    # Install Microsoft Outlook
    echo "📧 Installing Microsoft Outlook..."
    if brew install --cask microsoft-outlook 2>/dev/null; then
        echo "✅ Microsoft Outlook installed successfully"
    else
        echo "⚠️  Microsoft Outlook is already installed or installation failed"
    fi

    # Install Microsoft Teams
    echo "💬 Installing Microsoft Teams..."
    if brew install --cask microsoft-teams 2>/dev/null; then
        echo "✅ Microsoft Teams installed successfully"
    else
        echo "⚠️  Microsoft Teams is already installed or installation failed"
    fi

    # Install AppCleaner
    echo "🧹 Installing AppCleaner..."
    if brew install --cask appcleaner 2>/dev/null; then
        echo "✅ AppCleaner installed successfully"
    else
        echo "⚠️  AppCleaner is already installed or installation failed"
    fi

    echo "🎉 Installation process complete!"
    echo "================================================="
    echo "All applications have been processed."
    echo "You can find these applications in your Applications folder or launch them from Spotlight."

    # Launch AppCleaner
    echo "⚠️  IMPORTANT BACKUP REMINDER:"
    echo "Before uninstalling Slack and any Google App, be sure to backup any conversations, attachments, and/or reocurring meetings, google drive files."
    echo ""
    echo "🚀 Launching AppCleaner..."
    if ! open -a AppCleaner 2>/dev/null; then
        echo "⚠️  Could not automatically launch AppCleaner. Please launch it manually from Applications folder."
    fi
}

# Function to install and use Chocolatey (Windows)
install_with_chocolatey() {
    echo "🍫 Using Chocolatey for Windows installation..."

    # Check if Chocolatey is installed
    if ! command -v choco &> /dev/null; then
        echo "❌ Chocolatey is not installed. Installing Chocolatey..."
        echo "Please run the following command in an Administrator PowerShell:"
        echo "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        echo ""
        echo "After installing Chocolatey, please run this script again."
        exit 1
    else
        echo "✅ Chocolatey found, proceeding with installation..."
    fi

    # Update Chocolatey
    echo "🔄 Updating Chocolatey..."
    if ! choco upgrade chocolatey -y; then
        echo "⚠️  Warning: Could not update Chocolatey, continuing anyway..."
    fi

    # Install Microsoft Outlook (using a simpler approach)
    echo "📧 Installing Microsoft Outlook..."
    if choco install microsoft-365-apps-business -y 2>/dev/null; then
        echo "✅ Microsoft Outlook installed successfully"
    else
        echo "⚠️  Microsoft Outlook is already installed or installation failed"
    fi

    # Install Microsoft Teams
    echo "💬 Installing Microsoft Teams..."
    if choco install microsoft-teams -y 2>/dev/null; then
        echo "✅ Microsoft Teams installed successfully"
    else
        echo "⚠️  Microsoft Teams is already installed or installation failed"
    fi

    # Install CCleaner (Windows equivalent of AppCleaner)
    echo "🧹 Installing CCleaner..."
    if choco install ccleaner -y 2>/dev/null; then
        echo "✅ CCleaner installed successfully"
    else
        echo "⚠️  CCleaner is already installed or installation failed"
    fi

    echo "🎉 Installation process complete!"
    echo "================================================="
    echo "All applications have been processed."
    echo "You can find these applications in your Start Menu or search for them."

    # Launch CCleaner
    echo "⚠️  IMPORTANT BACKUP REMINDER:"
    echo "Before uninstalling Slack and any Google App, be sure to backup any conversations, attachments, and/or reocurring meetings, google drive files."
    echo ""
    echo "🚀 Launching CCleaner..."
    if ! cmd.exe /c start ccleaner 2>/dev/null; then
        echo "⚠️  Could not automatically launch CCleaner. Please launch it manually from Start Menu."
    fi
}

# Execute based on detected OS
case "$OS" in
    "macOS")
        install_with_homebrew
        ;;
    "Windows")
        install_with_chocolatey
        ;;
    *)
        echo "❌ Unsupported operating system: $OS"
        exit 1
        ;;
esac
