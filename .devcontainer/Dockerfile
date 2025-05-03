# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.0

FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

ARG USERNAME=vscode
# https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
RUN echo "USERNAME=$USERNAME"
RUN PERSIST_BASH_HISTORY="export PROMPT_COMMAND='history -a' && export HISTFILE=/workspaces/z/.bash_history" \
    && echo "$PERSIST_BASH_HISTORY" >> "/home/$USERNAME/.bashrc"