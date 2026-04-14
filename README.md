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

In another terminal, install JS dependencies and set up the databases:

```sh
# install node deps
docker compose exec web npm install

# create dev db, load schema, and seed
docker compose exec web bin/rails db:setup

# create test db, load schema, skip seeding
docker compose exec -e RAILS_ENV=test web bin/rails db:create db:schema:load
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

#### Dev Container (Headless only)

You can only run cypress within a docker container headlessly (no GUI):

```sh
# run headless
npm run test:e2e
```

#### From Host (headless or interactive)

Runs Cypress from your host machine against a test Rails server in a throwaway container. The dev stack can keep running — the test server lives on a separate port so there's no conflict and no need to flip `RAILS_ENV`.

**One-time host setup:**

1. Install [Node.js](https://nodejs.org/) (version 22).
2. Install JS deps on the host:

   ```sh
   npm install
   ```

**Each run:** open two terminals.

Terminal 1 — start the test Rails server (container port 3000 → host 3001):

```sh
docker compose run --rm -p 3001:3000 web npm run test:e2e:server
```

Terminal 2 — run Cypress, pointed at port 3001:

```sh
# headless
npx cypress run --config baseUrl=http://localhost:3001

# interactive GUI
npx cypress open --config baseUrl=http://localhost:3001
```

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
