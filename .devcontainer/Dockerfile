# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.3

FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

ARG USERNAME=vscode

# Copy a bashrc for some dev niceities
COPY .devcontainer/.bashrc /home/$USERNAME/.bashrc

# set ownership of anything in the home directory
RUN sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
