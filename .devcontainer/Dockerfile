# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.0

FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

ARG USERNAME=vscode
# https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
RUN echo "USERNAME=$USERNAME"
RUN PERSIST_BASH_HISTORY="export PROMPT_COMMAND='history -a' && export HISTFILE=/workspaces/z/.bash_history" \
    && echo "$PERSIST_BASH_HISTORY" >> "/home/$USERNAME/.bashrc"