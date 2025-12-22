# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.3

FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

ARG USERNAME=vscode

# Install Chromium and Cypress dependencies for headless testing
RUN sudo apt-get update && sudo apt-get install -y \
    chromium \
    xvfb \
    libgtk2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    libnotify-dev \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    xauth \
    && sudo rm -rf /var/lib/apt/lists/*

# Copy a bashrc for some dev niceities
COPY .devcontainer/.bashrc /home/$USERNAME/.bashrc

# set ownership of anything in the home directory
RUN sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
