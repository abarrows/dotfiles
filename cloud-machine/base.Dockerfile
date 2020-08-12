#-------------------------------------------------------------------------------------------------------------
# Author: Andrew Barrows
#-------------------------------------------------------------------------------------------------------------

FROM ubuntu:18.04 AS cloud-machine-base
# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.

ARG USERNAME=abarrows
ARG USER_UID=1000
ARG USER_GID=$USER_UID
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
# COPY --from=0
# Configure apt and install packages
RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  #
  # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
  && apt-get -y install --no-install-recommends curl locales fonts-powerline ca-certificates 2>&1 \
  && curl -sSL ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
  && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
  #
  # Install Node.js for front end development
  && curl -sSL ${NODE_SCRIPT_SOURCE} -o /tmp/node-setup.sh \
  && ([ "${NODE_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/node-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/node-setup.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
  #
  # set up locale
  && locale-gen en_US.UTF-8

# Switch back to dialog for any ad-hoc use of apt-get
# ENV DEBIAN_FRONTEND=dialog

# ## setup and install oh-my-zsh
RUN /bin/bash -c "$(curl https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
  -p git \
  -p ssh-agent \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-completions \
  -p nvm
# RUN cp /root/.zshrc /home/"$USERNAME" \
#  sed -i -e "s/\/root\/.oh-my-zsh/\/home/\"$USERNAME\"/.oh-my-zsh/g" /home/"$USERNAME"/.zshrc
# chown -R "$USER_UID":"$USER_GID" /home/"$USERNAME"/.oh-my-zsh
# /home/"$USERNAME"/.zshrc
# RUN bash ./setup.sh

# Sets up pathing for NVM and loads it.
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/$USERNAME/.zshrc"
RUN echo '\n' >> "$HOME/.zshrc"
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$HOME/.zshrc"


# ZSH in Docker by Deluan on Github.  See url for more information
# Clean up
RUN apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh /tmp/node-setup.sh

# ** [Optional] Uncomment this section to install additional OS packages. **
#
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Move our project into workspace
# WORKDIR $HOME

# COPY . /$HOME/
RUN echo 'This is right before the base-entrypoint.'

# 1. Copy custom zsh shell aliases and commands into workspace
# 2. Copy git configuration into workspace
# RUN cp general .
# RUN cp linting-and-formatting .
# COPY ruby-entrypoint.sh .
# 3. Copy linting tools and configuration into workspace
# Add a script to be executed every time the container starts.
# RUN echo 'Ready for entrypoint.  The present location is: ' && pwd
ENTRYPOINT ["base-entrypoint.sh"]
EXPOSE 3000
