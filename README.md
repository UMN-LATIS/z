# Z

[![tests](https://github.com/UMN-LATIS/z/actions/workflows/test.yml/badge.svg)](https://github.com/UMN-LATIS/z/actions/workflows/test.yml)

Z is a custom URL shortener for the [University of Minnnesota](https://www.umn.edu) developed by [LATIS](https://cla.umn.edu/latis). We use Z to create and manage University branded short links, for example: <http://z.umn.edu/mycoolsite>.

**Features**

- Custom or generated link short urls at z.umn.edu
- QR code generation
- Click statistics
- Collections of links
- Sharing link management between users
- Integration with University directory
- Ownership transfer of links
- Administrative dashboard
- History of link changes
- Link creation API

## Getting Started

**Prerequisite:** Docker

### Option 1: VS Code Dev Container
**Steps:**

1. Open VSCode with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed.
2. Click **Reopen in Container** when prompted.
3. Start the app:

   ```sh
   ./bin/dev
   ```

4. Open <http://localhost:3000>.

### Option 2: Docker Compose


```sh
git clone https://github.com/UMN-LATIS/z.git
cd z
cp .env.example .env
docker compose up
```

In another terminal, set up the database:

```sh
docker compose exec web bin/rails db:setup

# OR to drop an existing db first
# docker compose exec web bin/rails db:reset
```

Open <http://localhost:3000>.

**Common commands:**

```sh
# shell into the container
docker compose exec web bash

# run unit tests
docker compose exec web bundle exec rspec
```

### Mocking LDAP

Development mode looks up users in UMN LDAP which requires **UMN VPN**.

To skip LDAP, set this in your `.env`:

```sh
# 1 = mock ldap lookups
USER_LOOKUP_SKELETON=1
```

Rails will load test users from `cypress/fixtures/` instead. The test environment does this automatically.

## Testing

### Unit tests ([RSpec](https://github.com/rspec/rspec))

```sh
docker compose exec web bundle exec rspec
```

### End-to-end tests ([Cypress](https://www.cypress.io/))

Docker and devcontainer environments can only run Cypress **headlessly** (no GUI). For the interactive runner, you need to run Cypress from your host machine.

#### Headless (Docker or devcontainer)

Boots a test server and runs the full suite:

```sh
docker compose exec web npm run test:e2e
```

#### Interactive (from host)

**One-time host setup:**

1. Install [Node.js](https://nodejs.org/) (version 22).
2. Install dependencies locally:

   ```sh
   npm install
   ```

**Each run:**

1. Put Rails in test mode. In your `.env`, change:

   ```sh
   RAILS_ENV=test
   ```

   (`USER_LOOKUP_SKELETON=1` is already the default.)

2. Start the stack:

   ```sh
   docker compose up
   ```

3. In another terminal on your host, open Cypress:

   ```sh
   npx cypress open
   ```

   Cypress will connect to the Rails server at <http://localhost:3000>.

When you're done, set `RAILS_ENV=development` back in `.env` and restart the stack.

## Deployment

For deployment, we use:

- [Capistrano](https://github.com/capistrano/capistrano), for deployment
- Apache/[Passenger](https://github.com/phusion/passenger), as our server stack
- [LATIS Ansible Playbook](https://github.umn.edu/latis-sw/ansible_playbooks), for larger platform changes like a ruby version bump.

See `config/deploy.rb` and `config/deploy/` for deployment configuration.

### Remote Dev and Staging

To deploy remote dev and staging environments:

```sh
bundle exec cap <environmentname> deploy
```

| Environment Name | Server                                                       |
| ---------------- | ------------------------------------------------------------ |
| remotedev        | [cla-z-r9-dev.oit.umn.edu](https://cla-z-r9-dev.oit.umn.edu) |
| staging          | [cla-z-r9-tst.oit.umn.edu](https://cla-z-r9-tst.oit.umn.edu) |

### Production

See [Deploying to Production](./deploy_to_production.md).

After deploying, populate the ip2location_db1 table with the content from the [IP2Location LITE IP-Country Database](https://lite.ip2location.com/database/ip-country).

## Internationalization

Most of the language has been extracted into a [single localization file](https://github.umn.edu/latis-sw/z/blob/develop/config/locales/en.bootstrap.yml). This allows you to change any language and make Z applicable to your environment.

## Contribute

- Source Code: <https://www.github.com/z>
- Issue Tracker: <https://www.github.com/umn-latis/z/issues>
