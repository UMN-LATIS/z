# Z

[![tests](https://github.com/UMN-LATIS/z/actions/workflows/test.yml/badge.svg)](https://github.com/UMN-LATIS/z/actions/workflows/test.yml) [![GitHub Release](https://img.shields.io/github/release/tterb/PlayMusic.svg?style=flat)]()

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

1. Prep your system for running [Ruby and Rails with MySQL](https://gorails.com/setup/)
2. Make sure that `config/database.yml` is correctly configured with database credentials, and `config/ldap.yml` is correctly configured with LDAP credentials, and an instance of MySQL is running.
3. Install the version of ruby in `.ruby-version`:

   ```sh
   rbenv install
   ```

4. Install dependencies with bundler

   ```sh
   bundle install
   ```

5. Create, import the schema, and seed the database. Part of this connects to LDAP, so you will need to be on UMN VPN.

   ```sh
   # create the database, run migrations, and seed the database
   ./bin/rails db:setup # or ./bin/rails db:reset to drop the exist db first
   ```

6. To launch the application, run:

   ```sh
   ./bin/dev
   ```

   This will use `foreman` to start both Vite (used for VueJS), and Rails.

Connect to [http://localhost:5100].

## Testing

In test mode, Rails will use `UserLookupServiceSkeleton`, a stubbed version of the normal LDAP `UserLookupService` which will load test users from Cypress fixtures at `cypress/fixtures` rather than doing a normal LDAP lookup.

### [Rspec](https://github.com/rspec/rspec)

To run the unit tests with Rspec:

```sh
bundle exec rspec
```

### [Cypress](https://www.cypress.io/)

Cypress is used for End to End testing. To run the tests locally, you will need to have the application running.

You'll want to start the server using `UserLookupServiceSkeleton`, a stubbed version of the normal LDAP, which will load test user data from Cypress fixtures at `cypress/fixtures`. This is configured in `Procfile.test`.

```sh
# start the Rails server in test mode wiht user lookup skeleton service stubbed
./bin/foreman start -f Procfile.test
```

Once the server is running, you can open Cypress with:

```sh
# open cypress
yarn cypress open
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

| Environment Name | Server                                                     |
| ---------------- | ---------------------------------------------------------- |
| remotedev        | [cla-z-dev.oit.umn.edu](https://cla-z-dev.oit.umn.edu)     |
| staging          | [cla-z-stage.oit.umn.edu](https://cla-z-stage.oit.umn.edu) |

### Production

See [Deploying to Production](./deploy_to_production.md).

After deploying, populate the ip2location_db1 table with the content from the [IP2Location LITE IP-Country Database](https://lite.ip2location.com/database/ip-country).

## Tech Stack

- Rails
- Vue
- MySQL
- LDAP (for directory lookup)
- [OmniAuth](https://github.com/omniauth/omniauth), for authentication
- [Pundit](https://github.com/elabs/pundit), for authorization
- [Paper trail](https://github.com/airblade/paper_trail), for URL version history
- [Turbolinks](https://github.com/turbolinks/turbolinks), for faster browsing
- [Typeahead](https://github.com/twitter/typeahead.js/), for user autocomplete
- [Google Charts](https://developers.google.com/chart/), for click visualization
- [Barby](https://github.com/toretore/barby), for QR code generation
- [Rubocop](https://github.com/bbatsov/rubocop), to enforce best practices
- [Starburst](https://github.com/csm123/starburst), for in-app announcements

## Internationalization

Most of the language has been extracted into a [single localization file](https://github.umn.edu/latis-sw/z/blob/develop/config/locales/en.bootstrap.yml). This allows you to change any language and make Z applicable to your environment.

## Contribute

- Source Code: <https://www.github.com/z>
- Issue Tracker: <https://www.github.com/umn-latis/z/issues>
