FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Step 1: Installing dependencies
RUN apt-get update
RUN apt-get -y install acl bash binutils git xz-utils wget sudo iputils-ping file

# Step 1.1: Change uid and gid to be compatible with Github Actions
RUN usermod -u 1001 vscode \
    && groupmod -g 1001 vscode \
    && chown -R vscode:vscode /home/vscode \
    && chsh -s /usr/bin/fish vscode

# Step 1.5: Setting up devbox user
ENV DEVBOX_USER=vscode
USER $DEVBOX_USER
WORKDIR /home/${DEVBOX_USER}

# Step 2: Installing Nix
RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
RUN . ~/.nix-profile/etc/profile.d/nix.sh

ENV PATH="/home/${DEVBOX_USER}/.nix-profile/bin:$PATH"

# Optional arg to install custom devbox version
ARG DEVBOX_USE_VERSION
# Step 3: Installing devbox
ENV DEVBOX_USE_VERSION=$DEVBOX_USE_VERSION
RUN wget --quiet --output-document=/dev/stdout https://get.jetify.com/devbox | bash -s -- -f
RUN chown -R "${DEVBOX_USER}:${DEVBOX_USER}" /usr/local/bin/devbox
ENV PATH="/home/${DEVBOX_USER}/.local/share/devbox/global/default/.devbox/nix/profile/default/bin:$PATH"

RUN git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
ENV PATH="/home/${DEVBOX_USER}/.emacs.d/bin:$PATH"

# Step 4: Install packages
RUN devbox global add fish
RUN devbox global add ripgrep
RUN devbox global add fd
RUN devbox global add tini
RUN devbox global add emacs

RUN sudo ln -sf /home/${DEVBOX_USER}/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/fish /usr/bin/fish \
    && echo /usr/bin/fish | sudo tee -a /etc/shells \
    && echo /home/${DEVBOX_USER}/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/fish | sudo tee -a /etc/shells \
    && sudo chsh -s /usr/bin/fish ${DEVBOX_USER}

RUN devbox global run -- true

COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} config.fish /home/${DEVBOX_USER}/.config/fish/config.fish

COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} doom.d /home/${DEVBOX_USER}/.doom.d
RUN devbox global run -- ~/.emacs.d/bin/doom sync

ENTRYPOINT ["tini", "--"]

CMD ["fish"]
