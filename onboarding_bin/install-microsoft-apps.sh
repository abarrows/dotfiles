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

# Function to install using winget (Windows)
# winget ships with Windows 10 1809+ and Windows 11 via App Installer.
# It requires no external bootstrap URL, avoiding proxy/DNS resolution errors.
install_with_winget() {
    echo "📦 Using winget for Windows installation..."

    # Check if winget is available
    if ! command -v winget &> /dev/null; then
        echo "❌ winget is not installed."
        echo "Install 'App Installer' from the Microsoft Store, or download the latest release from:"
        echo "  https://github.com/microsoft/winget-cli/releases"
        echo "Then re-run this script."
        exit 1
    else
        echo "✅ winget found, proceeding with installation..."
    fi

    # Accept source agreements non-interactively
    winget source update --disable-interactivity 2>/dev/null || true

    winget_install() {
        local pkg="$1"
        local label="$2"
        echo "  Installing ${label}..."
        if winget install --id "${pkg}" --exact --silent \
            --accept-package-agreements --accept-source-agreements 2>/dev/null; then
            echo "✅ ${label} installed successfully"
        else
            echo "⚠️  ${label} is already installed or installation failed"
        fi
    }

    # Install Microsoft Outlook
    echo "� Installing Microsoft Outlook..."
    winget_install "Microsoft.OutlookForWindows" "Microsoft Outlook"

    # Install Microsoft Teams
    echo "💬 Installing Microsoft Teams..."
    winget_install "Microsoft.Teams" "Microsoft Teams"

    # Install Bulk Crap Uninstaller (open-source AppCleaner equivalent)
    echo "🧹 Installing Bulk Crap Uninstaller..."
    winget_install "Klocman.BulkCrapUninstaller" "Bulk Crap Uninstaller"

    echo "🎉 Installation process complete!"
    echo "================================================="
    echo "All applications have been processed."
    echo "You can find these applications in your Start Menu or search for them."

    echo "⚠️  IMPORTANT BACKUP REMINDER:"
    echo "Before uninstalling Slack and any Google App, be sure to backup any conversations, attachments, and/or reocurring meetings, google drive files."
    echo ""
    echo "🚀 To launch Bulk Crap Uninstaller, search for it in the Start Menu."
}

# Execute based on detected OS
case "$OS" in
    "macOS")
        install_with_homebrew
        ;;
    "Windows")
        install_with_winget
        ;;
    *)
        echo "❌ Unsupported operating system: $OS"
        exit 1
        ;;
esac
