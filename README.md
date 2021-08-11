# Z

[![tests](https://github.com/UMN-LATIS/z/actions/workflows/ci.yml/badge.svg)](https://github.com/UMN-LATIS/z/actions/workflows/ci.yml)

Z is a custom URL shortener developed at LATIS@UMN. Instead of using a third party service, we use Z to create and manage University branded short links, for example: http://z.umn.edu/mycoolsite. The goal of this project is to provide a modern, open source solution to University branded short links.

## Features

- Custom or generated link keywords
- QR code generation
- Click statistics
- Link organization into collections
- Sharing link management between users
- Integration with University directory
- Ownership transfer of links
- Administrative dashboard
- History of link changes
- Responsive design
- Link creation API

## Installation ([Docker](https://www.docker.com))

The included `docker-composer.yml` and `Dockerfile` files should allow this application to be run in [Docker](https://www.docker.com). To get started, run

     docker-compose run web rake db:create
     docker-compose run web rails db:migrate RAILS_ENV=development

To launch the application, run

     docker-compose up

and connect to your localhost on port 3000.

## Installation (Dockerless)

Make sure that config/database.yml is correctly configured with database credentials, and config/lda.yml is correctly configured with LDAP credentials, and an instance of MySQL is running.

    rvm install 2.3.1
    gem install bundler
    bundle install
    rails db:reseed

To launch the application, run

     rails s

and connect to your localhost on port 3000.

## Technology and Dependencies

- Rails 5.0.2
- MySQL
- LDAP (for directory lookup)

### Auth

- [OmniAuth](https://github.com/omniauth/omniauth), for authentication
- [Pundit](https://github.com/elabs/pundit), for authorization

### Deployment

- [Capistrano](https://github.com/capistrano/capistrano), for deployment
- Apache/[Passenger](https://github.com/phusion/passenger), as our server stack

  ```console
  bundle exec cap <environmentname> deploy
  ```

If a deployment requires a Ruby version bump or other platform updates, see: [LATIS ansible playbook](https://github.umn.edu/latis-sw/ansible_playbooks)

#### Deploying to Production

Deploying `z` to production involves a few more steps since there are multiple servers and a load balancer involved.

##### THE PLAYERS
- <https://z.umn.edu> points to a load balancer. The service provides an SSL cert and balances traffic between:
- `cla-z-prd.oit.umn.edu`: Production server 1.
- `cla-z-prd-2.oit.umn.edu`: Production server 2.
- Your local machine will be used to verify that each production server deployment was successful.

##### THE PROCESS

T-minus 2 weeks

0. When Z is ready for production deployment, create a release branch following gitflow style. Deploy to staging.

1. Because Z is critical UMN infrastructure, user-impacting deployments should receive approval from the [Enterprise Change Approval Board (CAB)](https://it.umn.edu/resources-it-staff-partners/change-management/change-approval-board). 
   1. Ping LATIS' CAB representative to let them know a Z deployment will be upcoming and you're submitting a CAB request.
   2. Schedule a time for deployment. Invite a [LATIS system engineer](https://neighborhood.cla.umn.edu/latis/people/latis-staff-list) to help with load balancing hokey pokey.
   3. Complete the CAB request.
   4. Proceed if approval from CAB, or defer change if not approved.

Deploy Day

1. Prep
   1. Connect to VPN
   2. Start tailing log files on production servers with `tail -f /swadm/web/z/current/log/*log`
   3. Open Ansible Playbook locally
   4. Open z.umn.edu repo locally
   5. Open `/etc/hosts` locally. Add entries for `cla-z-prd.oit.umn.edu` and `cla-z-prd-2.oit.umn.edu`.
     ```
     # /etc/hosts

     # Z DEPLOYMENT
     # Uncomment to force z.umn.edu to resolve to a particular
     # production server. Used when testing that a production 
     # deploy is successful.

     # cla-z-prd
     # 128.101.122.117 z.umn.edu
     
     # cla-z-prd-2
     # 128.101.122.224 z.umn.edu

     ```

     **Wait. Why do we need to do this? Isn't testing `cla-z-prd` directly good enough?**
     If you type `cla-z-prd.oit.umn.edu` into your browser and try to sign in, it'll redirect you to `z.umn.edu`. This makes sure any redirects to `z.umn.edu` also resolve to `cla-z-prd.oit.umn.edu`.

2. Take one of the servers, `cla-z-prd-oit.edu`, out of the load balancing group.  This is done with the help of a [LATIS System Engineer](https://neighborhood.cla.umn.edu/latis/people/latis-staff-list).
3. Wait for connections to drain by monitoring the logfiles on `cla-z-prd-oit.edu`. Once there's no traffic, proceed. (Note: There may be a small amount of bot (?) traffic directly to an individual host like `cla-z-prd`.).
4. Uncomment the line in `/etc/hosts` file to point `z.umn.edu` to the ip address of the `cla-z-prd-oit.umn.edu`.
   ```
   # cla-z-prd
   128.101.122.117 z.umn.edu
   ```
5. If Ansible-ing:
   1.  In the [ansible playbook](https://github.umn.edu/latis-sw/ansible_playbooks), edit [z.yml](https://github.umn.edu/latis-sw/ansible_playbooks/blob/main/z.yml) so that `hosts` value references the correct hostname, `cla-z-prd`. See: [inventory.yml](https://github.umn.edu/latis-sw/ansible_playbooks/blob/main/inventory.yml) and [host_vars](https://github.umn.edu/latis-sw/ansible_playbooks/blob/main/host_vars/cla-z-prd.yml) for host options.
       ```yml
       ---
       - hosts: cla-z-prd
        vars:
          ruby_version: "2.7.3"
        pre_tasks:
        ...
       ```
   2. Login to lastpass.
      ```sh
      lpass login <username@umn.edu>
      ```
      Ansible will use the Z Rails Application keys stored in lastpass.

   3. Coverge the host:
      ```sh
      ansible-playbook -i inventory.yml z.yml
      ```
6. Use Capistrano to deploy Rails.
   1. 

   ```sh
   
   ```

Hardware load balancer in front of the service. 

Take one of the services out.
Manually update localhost file.
Put service back in.

tail log:/swadm/web/z/current/log/*log

###### Ansible

Deploying z prod 2
Target cla-z-prd-2 with ansible hosts. z.yml

Running ansible-playbook -i inventory.yml

Running into Unable to find `ssl/cla-z-prd-2.crt`

`cla-z-prd`
Missing files for cla-z-prd-2. Colin added to ansible.

SSL connection to z.umn.edu terminates at the load balancer, so the SSL cert doesn't really matter.

Running ansible
     - SSL certi shows up in yellow, but that's normal
     - Install Ruby takes a long time.

Update `/etc/hosts` so that z.umn.edu points directly to prd-2
128.101.122.244 z.umn.edu

We get a little traffic to prod-2 while deploying. Colin thinks `robots.txt` could handle that.

Ran into a error in LastPass.

##### Cap

Colin edits the `config/deploy/production.rb` file. 

- `lograge_production.log`

Repeat with `prd1`



# Deploying to prd

Repeat. Update hosts file. 

Ran into issues with deploying

Manually changed:
- In Z app production.rb
- z.yml file

Local:
- /etc/hosts

## ACTION ITEMS

- Add test for datatables filters
- Change production.rb
- Investigate why traffic we're getting traffic.
- Close out release branch
- Get on Datatables release branch

### Data

After deploying, populate the ip2location_db1 table with the content from the [IP2Location LITE IP-Country Database](https://lite.ip2location.com/database/ip-country).

### Testing

- [Rspec](https://github.com/rspec/rspec)/[Capybara](https://github.com/teamcapybara/capybara), for testing
- [PhantomJS](http://phantomjs.org)/[Apparition](https://github.com/twalpole/apparition), for browser emulation

The application has a a comprehensive testing suite using Rspec and Capybara. Front end tests are configured to run with PhantomJS and Apparition. The test suite can be ran by running:

    bundle exec rspec

### Other tech

- [Paper trail](https://github.com/airblade/paper_trail), for URL version history
- [Turbolinks](https://github.com/turbolinks/turbolinks), for faster browsing
- [Typeahead](https://github.com/twitter/typeahead.js/), for user autocomplete
- [Google Charts](https://developers.google.com/chart/), for click visualization
- [Barby](https://github.com/toretore/barby), for QR code generation
- [Rubocop](https://github.com/bbatsov/rubocop), to enforce best practices
- [Starburst](https://github.com/csm123/starburst), for in-app announcements

## Customization

Z was designed to be forkable and customizable. Most of the language has been extracted into a [single localization file](https://github.umn.edu/latis-sw/z/blob/develop/config/locales/en.bootstrap.yml). This allows you to change any language and make Z applicable to your environment. Z uses [OmniAuth](https://github.com/omniauth/omniauth), which supports a wide variety of [authentication strategies](https://github.com/omniauth/omniauth/wiki/list-of-strategies).

## Contribute

- Issue Tracker: https://github.umn.edu/latis-sw/z/issues
- Source Code: https://github.umn.edu/latis-sw/z

## Support

If you are having issues, please let us know.
We have a mailing list located at: help@umn.edu
