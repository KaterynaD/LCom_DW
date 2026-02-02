# EC2 Airflow + dbt (Redshift) in Docker (Amazon Linux 2023)

This folder is the **runtime infrastructure** for running **Apache Airflow + dbt (Redshift)** in Docker on an **Amazon Linux 2023 EC2** host.

**Goal:** you can rebuild a brand‑new EC2 instance and restore everything needed to run Airflow + dbt from this document.

> Scope (this README)
> - Host prerequisites (Docker, Compose, Git, cron, mail, Self Hosted GitHub Actions)
> - Host folder layout under `/home/kdrogaieva/Prod`
> - Secrets creation + locking down access (root + `airflow_secrets`)
> - One-time Airflow init, day-to-day start/stop, logs
> - Boot start (systemd) and health monitoring alert (cron)
> - Running dbt manually inside container
>
> Out of scope (separate README)
> - CI/CD workflow logic and release policy (only the infra prerequisites are mentioned here)

---

## Quick restore checklist (top-level)

Use this as the “I need everything back fast” list.

1. **Provision EC2** (Amazon Linux 2023) and SSH in as `kdrogaieva`.
2. **Install prerequisites**: Docker, Docker Compose, Git, cron, Postfix/mailx, Self Hosted GitHub Actions (sections below).
3. **Create host folders** under `/home/kdrogaieva/Prod` (section “Host directory layout”).
4. **Copy runtime folders out of the repo**:
   - copy repo’s `airflow_runtime/` → `/home/kdrogaieva/Prod/airflow_runtime`
   - copy repo’s `deploy/` → `/home/kdrogaieva/Prod/deploy`
5. **Create required secret files**:
   - `/home/kdrogaieva/Prod/airflow_env/.env`
   - `/home/kdrogaieva/Prod/airflow_env/.smtp_password`
    - `/home/kdrogaieva/Prod/airflow_env/.airflow_admin_password`
   - `/home/kdrogaieva/Prod/dbt_profile/profiles.yml`
6. **Secure secret files** (root ownership + `airflow_secrets` group, chmod 640).
7. **Build Docker image** from `/home/kdrogaieva/Prod/airflow_runtime`.
8. **Initialize Airflow** (`./init_airflow.sh`) and verify `/health`.
9. **Install systemd service** (`airflow-docker.service`) and reboot test.
10. **Configure cron** to run `alert_airflow_docker.sh` every 4 hours.
11. **Configure Postfix+SES** so cron/script email alerts are delivered.

---

## Host directory layout

### `/home/kdrogaieva`

```
/home/kdrogaieva
├── Prod/
└── actions-runner/
```

### `/home/kdrogaieva/Prod`

```
/home/kdrogaieva/Prod
├── airflow_env/
├── airflow_logs/
├── airflow_pgdata/
├── airflow_plugins/
├── airflow_runtime/
├── dbt_logs/
├── dbt_profile/
├── dbt_target/
├── deploy/
├── docs/
├── releases/
└── repo-mirror/
```

### `/home/kdrogaieva/Prod/airflow_runtime`

```
/home/kdrogaieva/Prod/airflow_runtime
├── build_assets/
├── Dockerfile
├── docker-compose.yml
├── airflow-docker.service
├── init_airflow.sh
├── start_airflow.sh
├── stop_airflow.sh
├── alert_airflow_docker.sh
└── README.md
```

### `/home/kdrogaieva/Prod/deploy`

```
/home/kdrogaieva/Prod/deploy
├── bin/
│   ├── deploy_release.sh
│   ├── deploy_release_from_actions.sh
│   └── publish_dbt_docs.sh
├── locks/
└── logs/
```

---

## What lives where (purpose of each folder)

### Runtime folders (must be outside the repo)

- **`/home/kdrogaieva/Prod/airflow_runtime/`**  
  Docker compose stack for Airflow + Postgres, image build, start/stop/init scripts, boot service, monitoring script.

- **`/home/kdrogaieva/Prod/airflow_runtime/build_assets`** for any additional files. Currently there is index.html to customize dbt documentation. It's used inside Docker file.

- **`/home/kdrogaieva/Prod/airflow_env/`**  
  Airflow runtime secrets:
  - `.env` (Airflow config + Fernet + secret key + SMTP settings, etc.)
  - `.smtp_password` (SMTP password used by Airflow inside container and Postfix/mailx to send mail from the host in alert_airflow_docker.sh)
  - `.airflow_admin_password` (Airflow user password. It's used inside docker_compose.yml)

- **`/home/kdrogaieva/Prod/dbt_profile/`**  
  dbt `profiles.yml` used by dbt runs inside the container.

- **`/home/kdrogaieva/Prod/airflow_logs/`**  
  Airflow task logs (docker volume mapping).

- **`/home/kdrogaieva/Prod/airflow_pgdata/`**  
  Postgres data directory (docker volume mapping).

- **`/home/kdrogaieva/Prod/airflow_plugins/`**  
  Place for Airflow plugins if needed (volume mapping; currently empty).

- **`/home/kdrogaieva/Prod/dbt_logs/`**  
  dbt logs output (e.g., `dbt.log`) (volume mapping).

- **`/home/kdrogaieva/Prod/dbt_target/`**  
  dbt `target/` artifacts for docs/manifest/catalog, etc. (volume mapping).

- **`/home/kdrogaieva/Prod/repo-mirror/`**, **`/home/kdrogaieva/Prod/releases/`**, **`/home/kdrogaieva/Prod/docs/`**, **`/home/kdrogaieva/Prod/deploy/`**  
  These support deployment and docs publishing. CI/CD details are documented in a separate README, but the folders must exist.

### Repo vs host (important)

`airflow_runtime` and `deploy` are **part of the repo**, but for operations they are **copied outside of the repo** into stable host paths under `/home/kdrogaieva/Prod/` so:
- deployments do not break paths
- logs / pgdata / secrets survive repo changes
- CI/CD can run reliably on the EC2 host

---

## 1) Prerequisites on EC2 (Amazon Linux 2023)

### 1.1 Update packages

```bash
sudo dnf update -y
```

### 1.2 Docker

```bash
sudo dnf install -y docker

sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker

# Run docker without sudo
sudo usermod -aG docker kdrogaieva
newgrp docker

# Quick test:
docker run --rm hello-world
```

### 1.3 Docker Compose (Compose V2 plugin)

```bash
sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -SL \
  https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version
```

### 1.4 Git

```bash
sudo dnf install -y git
git --version

git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
git config --global --list
```

### 1.5 SSH keys for GitHub / Bitbucket (deploy keys)

1) Check keys:

```bash
ls -la ~/.ssh
```

2) Generate if missing:

```bash
ssh-keygen -t ed25519 -C "your.email@company.com"
```
It creates id_ed25519.pub and  id_ed2551 files in /home/kdrogaieva/.ssh

3) Recommended permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

4) (Optional) ssh-agent for interactive use:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l
```

5) Add `id_ed25519.pub` to:
- GitHub repo → Settings → Deploy keys
- Bitbucket → Personal settings → SSH keys → Add key →  SSH Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

6) Add github.com host key:

```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts
```


### 1.6 Self Hosted GitHub Actions

GitHub Repo → Settings → Actions → Runners → New self-hosted runner → Linux x64

Use the script provided in GitHub 
Below are just example actual at the moment when Readme was created
```bash
# Create a folder
cd /home/kdrogaieva
mkdir actions-runner && cd actions-runner
# Download the latest runner package
curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz




# For EC2 Amazon Linux manually install the required dependencies for the GitHub Actions runner

sudo yum update -y

sudo yum install libicu -y

sudo yum install lld -y

# You need to run in GitHub UI Actions->  Runner -> Create new runner to get new token

./config.sh \
  --url https://github.com/learningcom/transformations \
  --token XYZ \
  --name airflow-ec2-runner \
  --work _work \
  --labels ec2,airflow,private

# Run as a service

sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status

```

### 1.7 Email from host (Postfix + mailx via Amazon SES)

This is required for cron/script alert emails to be delivered.

#### 1 Install + start

```bash
sudo dnf install -y postfix mailx cyrus-sasl-plain

# Enable + start Postfix
sudo systemctl enable postfix
sudo systemctl start postfix

# Confirm it’s running:
sudo systemctl status postfix --no-pager
```

#### 2 SES credentials map

```bash
sudo nano /etc/postfix/sasl_passwd
```

Add:

```text
[email-smtp.us-west-2.amazonaws.com]:587 YOUR_SES_SMTP_USERNAME:YOUR_SES_SMTP_PASSWORD
```

Lock down + build db:

```bash
# Lock it down:
sudo chmod 600 /etc/postfix/sasl_passwd

# Build the hashed DB that Postfix actually reads:
sudo postmap /etc/postfix/sasl_passwd

# You should now have:
ls -l /etc/postfix/sasl_passwd*

# -rw-------. 1 root root   107 Jan 28 04:31 /etc/postfix/sasl_passwd
# -rw-------. 1 root root 12288 Jan 28 04:32 /etc/postfix/sasl_passwd.db

```

#### 3 Configure relay

```bash
sudo nano /etc/postfix/main.cf
```

Add/update:

```text
# Relay all outbound mail through Amazon SES
relayhost = [email-smtp.us-west-2.amazonaws.com]:587

# SMTP auth
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

# TLS
smtp_use_tls = yes
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt

# Only listen locally (recommended for a host relay)
inet_interfaces = loopback-only
```

Validate:

```bash
sudo postfix check


# /usr/sbin/postconf: warning: /etc/postfix/main.cf, line 759: overriding earlier entry: smtp_tls_security_level=may
# /usr/sbin/postconf: warning: /etc/postfix/main.cf, line 763: overriding earlier entry: inet_interfaces=localhost

```

#### 4 Force external sender domain + rewrite map

Set origin domain:

```bash
sudo postconf -e "myorigin=learning.com"
```

Create generic rewrite map:

```bash
sudo nano /etc/postfix/generic
```

Example:

```text
@ip-172-25-8-33.ldc.aws kdrogaieva@learning.com
@localhost kdrogaieva@learning.com
kdrogaieva kdrogaieva@learning.com
root kdrogaieva@learning.com
```

(The above did not work reliable for me. When I ran a test without "-r"  the command did not work or somehow recepient and sender was the same in the email I received. The commands with "-r" are fine. )

Build + enable:

```bash
sudo postmap /etc/postfix/generic

sudo nano /etc/postfix/main.cf
# add:
smtp_generic_maps = hash:/etc/postfix/generic

sudo systemctl restart postfix
```

#### 5 Test

```bash
echo "Hello" | mail -r "reportinganalytics@learning.com" -s "SES test" kdrogaieva@learning.com
 
echo "Hello" | mail -r "kdrogaieva@learning.com" -s "SES test" kdrogaieva@learning.com

echo "Hello from $(hostname) via Postfix + Amazon SES" | mail -s "SES test from host" kdrogaieva@learning.com

```

If you see duplicate warnings in `postfix check`, remove duplicate conflicting lines (example: duplicate `inet_interfaces` or `smtp_tls_security_level`) and restart postfix.


```bash
sudo postfix check

# postfix: warning: /etc/postfix/main.cf, line 759: overriding earlier entry: smtp_tls_security_level=may
# postfix: warning: /etc/postfix/main.cf, line 763: overriding earlier entry: inet_interfaces=localhost


sudo nano /etc/postfix/main.cf

# Find lines and delete
# inet_interfaces = localhost
# smtp_tls_security_level = may
```


### 1.8 Cron service (if does not exists on the host)

```bash
sudo dnf install -y cronie
sudo systemctl enable crond
sudo systemctl start crond
```
---

## 2) Create host folders under `/home/kdrogaieva/Prod`

```bash
cd /home/kdrogaieva
mkdir -p /home/kdrogaieva/Prod

mkdir -p /home/kdrogaieva/Prod/airflow_env
mkdir -p /home/kdrogaieva/Prod/airflow_logs
mkdir -p /home/kdrogaieva/Prod/airflow_pgdata
mkdir -p /home/kdrogaieva/Prod/airflow_plugins
mkdir -p /home/kdrogaieva/Prod/airflow_runtime

mkdir -p /home/kdrogaieva/Prod/dbt_logs
mkdir -p /home/kdrogaieva/Prod/dbt_profile
mkdir -p /home/kdrogaieva/Prod/dbt_target

mkdir -p /home/kdrogaieva/Prod/deploy/{bin,locks,logs}


mkdir -p /home/kdrogaieva/Prod/releases


```

## 3) Create docs repo (documentation)

```bash
cd /home/kdrogaieva/Prod
git clone git@github.com:learningcom/transformations.git /home/kdrogaieva/Prod/docs
```

Confirm:
```bash
cd /home/kdrogaieva/Prod/docs
git status
git branch --show-current
git remote -v
git log -1 --oneline
```
## 4) Create the mirror repo (repo-mirror)
```bash
cd /home/kdrogaieva/Prod
git clone --mirror git@github.com:learningcom/transformations.git /home/kdrogaieva/Prod/repo-mirror
```

Confirm:
```bash

cd /home/kdrogaieva/Prod/repo-mirror
git remote -v
git show -s --oneline HEAD
```

## 5) Create your first release and set the active symlink
```bash

cd /home/kdrogaieva/Prod/repo-mirror
git fetch --prune origin

INITIAL_SHA="$(git rev-parse origin/master)"
echo "Initial SHA: $INITIAL_SHA"

```
Create release directory via worktree:
```bash

mkdir -p /home/kdrogaieva/Prod/releases

git worktree add "/home/kdrogaieva/Prod/releases/$INITIAL_SHA/transformations" "$INITIAL_SHA"

```
Create the active symlink:
```bash
ln -sfn "/home/kdrogaieva/Prod/releases/$INITIAL_SHA/transformations" current
readlink -f current

```

## 6) Copy into runtime folders content from the repo



- airflow_runtime -> /home/kdrogaieva/Prod/airflow_runtime
- deploy ->  /home/kdrogaieva/Prod/deploy



---

## 7) Create secrets files

### 7.1 Create Airflow `.env`

Create/edit:

```bash
sudo nano /home/kdrogaieva/Prod/airflow_env/.env
```

Generate Fernet key:

```bash
python3 - << 'PY'
from cryptography.fernet import Fernet
print(Fernet.generate_key().decode())
PY
```

Generate secret key:

```bash
openssl rand -base64 32
```

Paste the values into `.env`

### 7.2 Create `.smtp_password`

```bash
sudo nano /home/kdrogaieva/Prod/airflow_env/.smtp_password
```

Paste only the SMTP password.

### 7.3 Create `.airflow_admin_password`

```bash
sudo nano /home/kdrogaieva/Prod/airflow_env/.airflow_admin_password
```

Paste only the Airflow Admin password (your choice. docker_compose.yml will use the password to create admin user).

### 7.4 Create `dbt` `profiles.yml`

Create/edit:

```bash
sudo nano /home/kdrogaieva/Prod/dbt_profile/profiles.yml
```

---

## 8) Secure secrets on the host (root + airflow_secrets group)

### 8.1 Create group and get GID

```bash
sudo groupadd -f airflow_secrets
getent group airflow_secrets
```

Example:

```
airflow_secrets:x:1004:
```

> Use only the numeric GID (e.g., `1004`) in `docker-compose.yml`.

### 8.2 Add your user to the group

```bash
sudo usermod -aG airflow_secrets kdrogaieva
newgrp airflow_secrets
groups kdrogaieva
```

### 8.3 Lock down secret files

```bash
sudo chown root:airflow_secrets /home/kdrogaieva/Prod/airflow_env/.smtp_password
sudo chmod 640 /home/kdrogaieva/Prod/airflow_env/.smtp_password

sudo chown root:airflow_secrets /home/kdrogaieva/Prod/airflow_env/.env
sudo chmod 640 /home/kdrogaieva/Prod/airflow_env/.env

sudo chown root:airflow_secrets /home/kdrogaieva/Prod/airflow_env/.airflow_admin_password
sudo chmod 640 /home/kdrogaieva/Prod/airflow_env/.airflow_admin_password

sudo chown root:airflow_secrets /home/kdrogaieva/Prod/dbt_profile/profiles.yml
sudo chmod 640 /home/kdrogaieva/Prod/dbt_profile/profiles.yml
```

Verify:

```bash
ls -l /home/kdrogaieva/Prod/airflow_env/.smtp_password
ls -l /home/kdrogaieva/Prod/airflow_env/.airflow_admin_password
ls -l /home/kdrogaieva/Prod/airflow_env/.env
ls -l /home/kdrogaieva/Prod/dbt_profile/profiles.yml
```

Host read test (as your user):

```bash
cat /home/kdrogaieva/Prod/airflow_env/.smtp_password
cat /home/kdrogaieva/Prod/airflow_env/.env
```

### 8.4 Ensure containers can read secrets

Your `docker-compose.yml` must:
- run services as `user: "1002:0"` (Airflow(kdrogaieva user) UID, root group)
- include `group_add: ["<GID>"]` where `<GID>` is `airflow_secrets` (example `1004`)

---

## 9) One-time Airflow setup

### 9.1 Make scripts executable

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
chmod +x *.sh
```

### 9.2 Build the image

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
docker build -t airflow-dbt:2.10.2-py3.12 .
```

### 9.3 Initialize Airflow DB + admin user, then start services

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
./init_airflow.sh
```

This performs:
1) `docker compose up airflow-init` (migrations + admin user; container exits)
2) `docker compose up -d airflow-webserver airflow-scheduler` (starts services)

### 9.4 Verify health

Wait ~1–2 minutes:

```bash
curl http://localhost:8080/health
```

---

## 10) Access Airflow UI from laptop (PuTTY tunnel)

PuTTY:
- Host: EC2 public DNS/IP
- Port: 22

Connection → SSH → Tunnels:
- Source port: `8080`
- Destination: `localhost:8080`
- Type: **Local**
- Add

Then open on laptop:

```
http://localhost:8080
```

---

## 11) Start Airflow on reboot (systemd)

### 11.1 Configure airflow-docker service

```bash
sudo cp /home/kdrogaieva/Prod/airflow_runtime/airflow-docker.service /etc/systemd/system/airflow-docker.service
sudo systemctl daemon-reload

sudo systemctl enable airflow-docker
sudo systemctl start airflow-docker
sudo systemctl status airflow-docker
```

### 11.2 Reboot test

```bash
sudo reboot
```

After reboot:

```bash
sudo docker ps
sudo systemctl status airflow-docker.service
```

---

## 12) Monitor missing/unhealthy containers (cron + alert script)

### 12.1 Schedule alert script

```bash
crontab -e
```

Add:

```cron
0 */4 * * * /home/kdrogaieva/Prod/airflow_runtime/alert_airflow_docker.sh >/dev/null 2>&1

#ESC :wq
```

Verify:

```bash
crontab -l
```

UTC → PST (UTC−8 winter) → PDT (UTC−7 summer)

00:00 → 16:00 (prev day) → 17:00 (prev day)

04:00 → 20:00 (prev day) → 21:00 (prev day)

08:00 → 00:00 → 01:00

12:00 → 04:00 → 05:00

16:00 → 08:00 → 09:00

20:00 → 12:00 → 13:00

### 8.2 What `alert_airflow_docker.sh` does

High-level behavior:
- Checks that key compose services exist and have running and healthy  containers.
- If a container is missing, not running, or unhealthy, it emails an alert with:
  - timestamp and hostname
  - `docker compose ps` output
  - recent container logs (`docker logs --tail ...`)

---

## 13) Daily operations (if needed for maintenance or whatever)

### 13.1 Start/stop

Start:

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
./start_airflow.sh
```

Stop:

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
./stop_airflow.sh
```

### 13.2 Status and logs

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
docker compose ps

docker compose logs -f airflow-webserver
docker compose logs -f airflow-scheduler
```

### 13.3 Health endpoint

```bash
curl http://localhost:8080/health
```

---

## 14) How restart/health works

- Services use `restart: unless-stopped` → containers usually come back after crashes or Docker restarts.
- Docker healthchecks mark containers `healthy/unhealthy` (visibility), **they do not restart containers by themselves**.
- Cron + `alert_airflow_docker.sh` provides the “notify me if unhealthy/missing” layer.

---

## 15) Run dbt manually (inside container)

Enter container:

```bash
cd /home/kdrogaieva/Prod/airflow_runtime
docker compose exec airflow-webserver bash
```

Inside container:

```bash
cd "$DBT_LCOM_DW_PROJECT_DIR"

dbt debug
dbt test
```

---

## 16) Notes about `deploy/` folder 

`/home/kdrogaieva/Prod/deploy` exists to provide:
- a stable location for deployment scripts
- persistent logs and locks across deployments

CI/CD behavior and release strategy are documented in a separate README.
