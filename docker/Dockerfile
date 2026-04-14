FROM rockylinux:9

# Build args for version pinning and user configuration
ARG RUBY_VERSION=3.4.3
ARG BUNDLER_VERSION=2.5.23
ARG NODE_VERSION=22
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ARG SKIP_BUNDLE_INSTALL=false

EXPOSE 3000

# Enable repositories and module streams
RUN dnf install -y dnf-plugins-core && \
	dnf config-manager --set-enabled crb && \
	dnf module enable -y nodejs:${NODE_VERSION} && \
	dnf clean all && \
	rm -rf /var/cache/dnf

# Install system dependencies in a single layer
RUN dnf groupinstall -y "Development Tools" && \
	dnf install -y \
	git \
	sudo \
	bzip2 \
	gcc \
	make \
	zlib \
	zlib-devel \
	wget \
	autoconf \
	bison \
	openssl-devel \
	readline-devel \
	nano \
	sqlite-devel \
	libaio \
	gcc-c++ \
	curl-devel \
	libnsl \
	mysql \
	mysql-devel \
	procps-ng \
	man-db man-pages \
	less \
	which \
	findutils \
	iproute \
	net-tools \
	nodejs \
	npm \
	ruby \
	ruby-devel \
	libffi-devel \
	git-credential-libsecret \
	libyaml \
	libyaml-devel && \
	dnf clean all && \
	rm -rf /var/cache/dnf

# Install Chromium (from EPEL) and Cypress shared-library dependencies
RUN dnf install -y epel-release && \
	dnf install -y \
	chromium \
	xorg-x11-server-Xvfb \
	at-spi2-atk \
	gtk3 \
	libdrm \
	mesa-libgbm \
	libxkbcommon \
	alsa-lib && \
	dnf clean all && \
	rm -rf /var/cache/dnf

# Install Ruby from source
RUN git clone https://github.com/sstephenson/ruby-build.git /tmp/ruby-build && \
	/tmp/ruby-build/install.sh chdir=/tmp/ruby-build && \
	RUBY_CFLAGS="-std=gnu99" ruby-build ${RUBY_VERSION} /usr/local && \
	rm -rf /tmp/ruby-build

# Set up application environment
ENV APP_HOME=/app \
	LC_ALL=C

# Create non-root user with matching UID/GID
RUN groupadd -g ${USER_GID} ${USERNAME} && \
	useradd -m -u ${USER_UID} -g ${USER_GID} -G wheel -s /bin/bash ${USERNAME} && \
	echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Make USERNAME available at runtime
ENV USERNAME=${USERNAME}

WORKDIR $APP_HOME

# Copy bashrc for better container development experience
COPY --chown=${USERNAME}:${USERNAME} docker/.bashrc /home/${USERNAME}/.bashrc

# Configure npm to install global packages in user home (survives rebuilds when mounted)
ENV NPM_CONFIG_PREFIX=/home/${USERNAME}/.npm-global \
	PATH=/home/${USERNAME}/.npm-global/bin:$PATH

# Create npm global directory
RUN mkdir -p /home/${USERNAME}/.npm-global && \
	chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.npm-global

# Configure bundler to install gems in app's vendor/bundle directory
ENV BUNDLE_PATH=$APP_HOME/vendor/bundle \
	BUNDLE_BIN=$APP_HOME/vendor/bundle/bin \
	PATH=$APP_HOME/vendor/bundle/bin:$PATH

# Install bundler
RUN gem install bundler -v ${BUNDLER_VERSION}

# Create app directory and set ownership
RUN mkdir -p $APP_HOME && \
	chown -R ${USERNAME}:${USERNAME} $APP_HOME

# Switch to non-root user
USER ${USERNAME}

# Copy Gemfile for bundle install
COPY --chown=${USERNAME}:${USERNAME} Gemfile Gemfile.lock ./

# Install gems during build unless SKIP_BUNDLE_INSTALL is set (devcontainers
# defer this to postCreateCommand so the volume-mounted bundle cache is used).
RUN if [ "$SKIP_BUNDLE_INSTALL" = "false" ]; then \
	bundle install; \
	else \
	echo "Skipping bundle install (will run after container starts)"; \
	fi

# Copy application code
COPY --chown=${USERNAME}:${USERNAME} . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
