# DEPLOYING TO PRODUCTION

Deploying `z` to production involves a few more steps since there are multiple servers and a load balancer involved. Here are some notes.

## 👥 THE PLAYERS

- <https://z.umn.edu> points to a load balancer. The service provides an SSL cert and balances traffic between:
- `cla-z-prd-web-03.oit.umn.edu`: Production server 1. (Note: `...-web-01` and `...-web-02` are older servers, no longer in service)
- `cla-z-prd-web-04.oit.umn.edu`: Production server 2.
- Your local machine will be used to verify that each production server deployment was successful.

Just like `dev` and `staging` deployments, we'll use Ansible for updating the platform and Capistrano for deploying the app.

## ⚡️ THE PROCESS

### 2 WEEKS BEFORE

1. When Z is ready for production deployment, create a release branch following gitflow style. Deploy to staging.

2. Because Z is critical UMN infrastructure, user-impacting deployments should receive approval from the [Enterprise Change Approval Board (CAB)](https://it.umn.edu/resources-it-staff-partners/change-management/change-approval-board).
   1. Ping LATIS' CAB representative to let them know a Z deployment will be upcoming and you're submitting a CAB request.
   2. Schedule a time for deployment. Invite a [LATIS system engineer](https://neighborhood.cla.umn.edu/latis/people/latis-staff-list) to help with load balancing hokey pokey.
   3. Complete the CAB request.
   4. Proceed if approval from CAB, or defer change if not approved.

### DEPLOY DAY

#### PREP

1.  Connect to VPN
2.  Start tailing log files on production servers with `tail -f /swadm/web/z/current/log/lograge_production.log`
3.  Open Ansible Playbook locally
4.  Open z.umn.edu repo locally
5.  Open `/etc/hosts` locally. Add entries for `cla-z-prd-web-03.oit.umn.edu` and `cla-z-prd-web-04.oit.umn.edu`. {: #config-etc-hosts }

    ```
    # /etc/hosts

    # Z DEPLOYMENT
    # Uncomment to force z.umn.edu to resolve to a particular
    # production server. Used when testing that a production
    # deploy is successful.

    # cla-z-prd-web-03.oit.umn.edu
    # 134.84.24.45 z.umn.edu

    # cla-z-prd-web-04.oit.umn.edu
    # 134.84.24.47 z.umn.edu
    ```

> **🙋‍♀️ Wait?! Why do we need to do this?**
>
> If you type `cla-z-prd-web-03.oit.umn.edu` into your browser and try to sign in, it'll redirect you to `z.umn.edu`. Configuring `/etc/hosts` will make sure any redirects to `z.umn.edu` also resolve to `cla-z-prd-web-03.oit.umn.edu`.

### DEPLOYING TO EACH PRODUCTION SERVER (`cla-z-prd-web-03.oit.umn.edu`)

Complete this for each server you're deploying to. In the example below, we'll use `cla-z-prd-web-03.oit.umn.edu` as our first target.

1. Take `cla-z-prd-web-03.oit.umn.edu` out of the load balancing group. This is done with the help of a [LATIS System Engineer](https://neighborhood.cla.umn.edu/latis/people/latis-staff-list).

2. Wait for connections to drain by monitoring the logfiles on `cla-z-prd-web-03.oit.umn.edu`. Once there's no traffic, proceed. (Note: There may be a small amount of bot (?) traffic directly to an individual host like `cla-z-prd`.).

3. Set your local computer to resolve `z.umn.edu` to the ip address of the `cla-z-prd-web-03.oit.umn.edu`. On a mac, this means editing `/etc/hosts` with:

   ```
   # cla-z-prd-web-03.oit.umn.edu
   # 134.84.24.45 z.umn.edu
   ```

Verify that `z.umn.edu` resolves locally to the correct IP with `ping z.umn.edu`.

#### USE ANSIBLE TO CONVERGE HOST CHANGES

Ansible is not needed for every Z deployment, but will be required when doing things like bumping a ruby or node version. See [Ansible playbook](https://github.umn.edu/latis-sw/ansible_playbooks).

1. Log in to [Ansible Tower](https://tower.oit.umn.edu/).
2. Go to Resources > Templates.
3. Choose `Z`, and launch
4. You'll be prompted for a _Limit_ – the hosts you want to scope the deploy to. Enter the host name as defined in Ansible, e.g. `cla-z-prd-3`, not `cla-z-prd-web-03.oit.umn.edu`.
5. Proceed

#### CAPISTRANO

Use Capistrano to deploy Rails:

1. Edit `config/deploy/production.rb` and uncomment the server to which we're deploying. For example, if deploying to `prd`:

   ```rb
   # role-based syntax
   ...

   role :app, %w[swadm@cla-z-prd-web-03.oit.umn.edu]
   role :web, %w[swadm@cla-z-prd-web-03.oit.umn.edu]
   role :db,  %w[swadm@cla-z-prd-web-03.oit.umn.edu]
   # role :app, %w[swadm@cla-z-prd-web-04.oit.umn.edu]
   # role :web, %w[swadm@cla-z-prd-web-04.oit.umn.edu]
   # role :db,  %w[swadm@cla-z-prd-web-04.oit.umn.edu]
   ...
   ```

2. Deploy to production

   ```console
   bundle exec cap production deploy
   ```

3. Verify:

   - [x] Go to: <http://z.umn.edu>. If we configured our `/etc/hosts` file correctly, this should resolve to our recently deployed server: `cla-z-prod.oit.umn.edu`.
   - [x] Home Page renders.
   - [x] Login works.
   - [x] Previously created Z-links exist.
   - [x] Test a previously created zlink: <https://z.umn.edu/latis>
   - [x] Create a zlink.
   - [x] Click the new zlink and verify it redirects.
   - [x] Check logs for errors.

#### NEXT STEPS

1. Add `cla-z-prd-web-03.oit.umn.edu` back to load balanced group.
2. Monitor traffic for unexpected errors once it's receiving traffic again.
3. If all good, proceed to next server in group: `cla-z-prd-web-04.oit.umn.edu` and repeat the steps above.

### POST DEPLOY

After successful deployment:

- [x] Log in to Team Dynamix, and mark the CAB ticket as completed.
- [x] Merge the release branch into main (and develop, if needed).
- [x] Create a Release on github, tagged with the latest version.
