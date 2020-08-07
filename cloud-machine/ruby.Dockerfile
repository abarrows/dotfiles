#-------------------------------------------------------------------------------------------------------------
# Author: Andrew Barrows
#-------------------------------------------------------------------------------------------------------------

# Update the VARIANT arg in devcontainer.json to pick a Ruby version: 2, 2.7, 2.6, 2.5
ARG VARIANT=2.7
FROM ruby:${VARIANT} AS cloud-machine-base

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG WORKSPACE=$WORKSPACE
# Options for common package install script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Settings for installing Node.js.
ARG NODE_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/node-debian.sh"
ARG NODE_SCRIPT_SHA="dev-mode"
ARG NODE_VERSION="lts/*"
ENV NVM_DIR=/usr/local/share/nvm
# Have nvm create a "current" symlink and add to path to work around https://github.com/microsoft/vscode-remote-release/issues/3224
ENV NVM_SYMLINK_CURRENT=true
ENV PATH=${NVM_DIR}/current/bin:${PATH}

# TODO: Convert this to a multi-stage build.
# FROM cloud-machine-base:latest
# COPY --from=0 WORKDIR ${workspaceFolder}
# Configure apt and install packages
RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  #
  # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
  && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
  && curl -sSL ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
  && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
  #
  # Install Node.js for front end development
  && curl -sSL ${NODE_SCRIPT_SOURCE} -o /tmp/node-setup.sh \
  && ([ "${NODE_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/node-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/node-setup.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
  #
  # Install gems and dependencies
  && apt-get -y install build-essential libsqlite3-dev zlib1g-dev libxml2

# Clean up
RUN apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh /tmp/node-setup.sh \
  && gem install bundler

# ** [Optional] Uncomment this section to install additional OS packages. **
#
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# ** [Optional] Uncomment this section to install additional Ruby gems packages. **
#
# RUN gem install <your gem names here>

# Move our project into workspace
WORKDIR $WORKSPACE

COPY . $WORKSPACE

# 1. Copy custom zsh shell aliases and commands into workspace
# 2. Copy git configuration into workspace
# RUN cp general .
# RUN cp linting-and-formatting .
# COPY ruby-entrypoint.sh .
# 3. Copy linting tools and configuration into workspace
# Add a script to be executed every time the container starts.
# RUN echo 'Ready for entrypoint.  The present location is: ' && pwd
ENTRYPOINT ["ruby-entrypoint.sh"]
CMD ["zsh"]
EXPOSE 3060
