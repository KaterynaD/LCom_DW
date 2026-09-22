## 1. Create `Prod_Prefect` Directory and Shared Admin Group

Create a dedicated Linux group for users who need administrative access to the LCom DW production environment.

The group name is intentionally generic so it can continue to be used if `Prod_Prefect` is later renamed to `Prod`.

```bash
sudo groupadd -f lcom_dw_admins
sudo usermod -aG lcom_dw_admins kdrogaieva
```

Create the new production environment directory:

```bash
sudo mkdir -p /home/kdrogaieva/Prod_Prefect
```

Set the directory owner and shared administrative group:

```bash
sudo chown kdrogaieva:lcom_dw_admins /home/kdrogaieva/Prod_Prefect
```

Set permissions:

```bash
sudo chmod 2775 /home/kdrogaieva/Prod_Prefect
```

`2775` provides:

- Full access for the owner.
- Read/write/execute access for members of `lcom_dw_admins`.
- Read/execute access for other users.
- The setgid bit (`2`) causes newly created files and directories to inherit the `lcom_dw_admins` group.

Activate the new group membership in the current shell if needed:

```bash
newgrp lcom_dw_admins
```

Verify the directory:

```bash
ls -ld /home/kdrogaieva/Prod_Prefect
```

Expected result:

```text
drwxrwsr-x. ... kdrogaieva lcom_dw_admins ... /home/kdrogaieva/Prod_Prefect
```

Verify group membership:

```bash
getent group lcom_dw_admins
```

Example:

```text
lcom_dw_admins:x:1006:kdrogaieva
```

Additional administrators can later be granted access by adding them to the same group:

```bash
sudo usermod -aG lcom_dw_admins <username>
```

If the self-hosted GitHub Actions runner is already installed and running, restart the runner service after adding `kdrogaieva` to the `lcom_dw_admins` group. A running service does not automatically pick up new Linux group membership.

```bash
sudo systemctl restart actions.runner.learningcom-transformations.airflow-ec2-runner.service
```
Verify that the runner restarted successfully:
```bash
systemctl status actions.runner.learningcom-transformations.airflow-ec2-runner.service
```

Expected status: Active: active (running)

## 2. Create Persistent Runtime Directories

Create the top-level directories used by the Prefect/dbt production environment.

These directories live outside individual releases so persistent configuration, secrets, logs, and dbt artifacts are not removed when old releases are deleted.

```bash
cd /home/kdrogaieva/Prod_Prefect

mkdir -p \
  releases \
  dbt_profile \
  dbt_logs \
  dbt_target \
  env \
  deploy/bin \ 
  deploy/logs \ 
  deploy/locks
```

Directory purposes:

- `releases/` — versioned application releases.
- `dbt_profile/` — production dbt `profiles.yml`.
- `dbt_logs/` — persistent dbt logs.
- `dbt_target/` — persistent dbt target artifacts.
- `env/` — protected production environment/secret files, such as `.smtp_password`.
- `deploy/` — persistent deployment infrastructure independent of individual releases. 
- `deploy/bin/` — stable deployment scripts called by GitHub Actions or manually from the EC2 host. 
- `deploy/logs/` — persistent deployment execution logs. 
- `deploy/locks/` — deployment lock files used to prevent concurrent deployments.

Because `/home/kdrogaieva/Prod_Prefect` has the setgid bit enabled, the directories inherit the `lcom_dw_admins` group.

Verify:

```bash
ls -la /home/kdrogaieva/Prod_Prefect
```

The directories should be owned by:

```text
kdrogaieva lcom_dw_admins
```


## 3. Create the Python Virtual Environment

The EC2 system default Python is:

```bash
python3 --version
```

```text
Python 3.9.25
```

Do **not** change the system/default Python version. System utilities may depend on the Python version provided by the operating system.

Python 3.12 is already installed separately:

```bash
python3.12 --version
```

```text
Python 3.12.13
```

Python **3.12** is used for the Prefect production environment because:

- It is a mature and widely supported Python version.
- It provides good compatibility with Prefect, dbt, and their Python dependencies.
- There is no need to use the newest Python version in production.
- It allows the production runtime to be upgraded independently from the EC2 system Python.
- Future dbt versions may use a standalone executable, making Python primarily the Prefect runtime.

Create a dedicated virtual environment outside the individual application releases:

```bash
cd /home/kdrogaieva/Prod_Prefect

python3.12 -m venv /home/kdrogaieva/Prod_Prefect/.venv
```

The `.venv` belongs to the production runtime rather than a particular code release. This avoids duplicating Python environments for every retained release.

Activate the environment:

```bash
source /home/kdrogaieva/Prod_Prefect/.venv/bin/activate
```

Verify the Python version inside the virtual environment:

```bash
python --version
```

Expected:

```text
Python 3.12.13
```

The EC2 system Python remains unchanged at Python 3.9, while Prefect and other production Python dependencies run in the isolated Python 3.12 environment:

```text
EC2 system
└── Python 3.9

/home/kdrogaieva/Prod_Prefect
└── .venv
    └── Python 3.12
```



## 4. Install Python Packages

Activate the production virtual environment:

```bash
source /home/kdrogaieva/Prod_Prefect/.venv/bin/activate
```

Install the Python packages required by the current dbt and Prefect orchestration environment:

```bash
python -m pip install \
  dbt-colibri \
  dbt-core==1.12.2 \
  dbt-redshift \
  pytest \
  prefect \
  prefect-dbt \
  prefect-sqlalchemy \
  sqlalchemy-redshift \
  psycopg2-binary
```

The environment requires:

- `dbt-colibri` — generates dbt lineage artifacts.
- `dbt-core` — dbt runtime.
- `dbt-redshift` — Amazon Redshift dbt adapter.
- `pytest` — automated testing.
- `prefect` — workflow orchestration.
- `prefect-dbt` — Prefect integration with dbt.
- `prefect-sqlalchemy` — Prefect SQLAlchemy integration.
- `sqlalchemy-redshift` — Redshift SQLAlchemy dialect.
- `psycopg2-binary` — PostgreSQL/Redshift database driver.

Verify dbt:

```bash
dbt --version
```

Expected versions:

```text
Core:
  - installed: 1.12.2

Plugins:
  - postgres: 1.11.0
  - redshift: 1.11.0
```

Verify that the installed Python packages have no broken dependencies:

```bash
python -m pip check
```

Expected:

```text
No broken requirements found.
```

The production environment currently uses:

```text
Python:        3.12.13
dbt Core:      1.12.2
dbt Redshift:  1.11.0
```




## 5. Create and Protect the SMTP Password File

The SMTP password used by Prefect email notifications is stored outside application releases so it persists across deployments and is never included in source control.

Create the password file:

```bash
sudo nano /home/kdrogaieva/Prod_Prefect/env/.smtp_password
```

Store **only the SMTP password** in the file.

Set ownership to `root` and the shared LCom DW administrators group:

```bash
sudo chown root:lcom_dw_admins /home/kdrogaieva/Prod_Prefect/env/.smtp_password
```

Restrict access so only `root` and members of `lcom_dw_admins` can read the password:

```bash
sudo chmod 640 /home/kdrogaieva/Prod_Prefect/env/.smtp_password
```

Verify permissions without displaying the secret:

```bash
ls -l /home/kdrogaieva/Prod_Prefect/env/.smtp_password
```

Expected pattern:

```text
-rw-r-----. 1 root lcom_dw_admins ... /home/kdrogaieva/Prod_Prefect/env/.smtp_password
```

Permissions:

- `root` — read/write.
- `lcom_dw_admins` — read.
- Other users — no access.
- The password remains outside `releases/` and survives application deployments and rollbacks.



## 6. Create and Protect the dbt Production Profile

The production dbt profile is stored outside application releases so database configuration and credentials persist across deployments and are never included in release directories.

Create the dbt profile:

```bash
sudo nano /home/kdrogaieva/Prod_Prefect/dbt_profile/profiles.yml
```

Add the production dbt configuration and credentials to `profiles.yml`.

Set ownership to `root` and the shared LCom DW administrators group:

```bash
sudo chown root:lcom_dw_admins /home/kdrogaieva/Prod_Prefect/dbt_profile/profiles.yml
```

Restrict access:

```bash
sudo chmod 640 /home/kdrogaieva/Prod_Prefect/dbt_profile/profiles.yml
```

Verify permissions without displaying the profile contents:

```bash
ls -l /home/kdrogaieva/Prod_Prefect/dbt_profile/profiles.yml
```

Expected pattern:

```text
-rw-r-----. 1 root lcom_dw_admins ... /home/kdrogaieva/Prod_Prefect/dbt_profile/profiles.yml
```

Permissions:

- `root` — read/write.
- `lcom_dw_admins` — read.
- Other users — no access.
- The profile remains outside `releases/` and survives deployments and rollbacks.


## 7 Configure Linux Environment Variables

Development on Windows uses a project `.env` file. Production on Linux uses persistent OS/user environment variables instead.

The application code supports both approaches:

- Windows development loads values from `.env`.
- Linux production reads variables from the process environment.
- No production `.env` file is required.
- The SMTP password itself remains in the separately protected `.smtp_password` file.

Edit the Linux user profile:

```bash
nano ~/.bash_profile
```

Add the LCom DW production environment variables:

```bash
# LCom DW Prefect production environment

export SMTP_HOST="email-smtp.us-west-2.amazonaws.com"
export SMTP_PORT="587"
export SMTP_USER="XYZ"
export SMTP_FROM="reportinganalytics@learning.com"
export SMTP_PASSWORD_FILE="/home/kdrogaieva/Prod_Prefect/env/.smtp_password"

export DBT_LCOM_DW_PROJECT_DIR="/home/kdrogaieva/Prod_Prefect/current/dbt/LCom_DW"
export DBT_TARGET_PATH="/home/kdrogaieva/Prod_Prefect/dbt_target"
export PROD_STATE_DIR="/home/kdrogaieva/Prod_Prefect/dbt_target/prod_state"
export DBT_PROFILES_DIR="/home/kdrogaieva/Prod_Prefect/dbt_profile"

export DBT_LOG_PATH="/home/kdrogaieva/Prod_Prefect/dbt_logs"
```

`DBT_LCOM_DW_PROJECT_DIR` points through the `current` symlink. Therefore, dbt and Prefect always use the currently active release without requiring environment-variable changes during deployments.

Create the persistent production state directory:

```bash
mkdir -p /home/kdrogaieva/Prod_Prefect/dbt_target/prod_state
```

Load the variables into the current shell:

```bash
source ~/.bash_profile
```

Verify the configuration without displaying SMTP credentials:

```bash
env | grep -E '^(SMTP_HOST|SMTP_PORT|SMTP_FROM|SMTP_PASSWORD_FILE|DBT_)|^PROD_STATE_DIR'
```

Expected paths include:

```text
DBT_PROFILES_DIR=/home/kdrogaieva/Prod_Prefect/dbt_profile
DBT_LCOM_DW_PROJECT_DIR=/home/kdrogaieva/Prod_Prefect/current/dbt/LCom_DW
PROD_STATE_DIR=/home/kdrogaieva/Prod_Prefect/dbt_target/prod_state
SMTP_PORT=587
SMTP_PASSWORD_FILE=/home/kdrogaieva/Prod_Prefect/env/.smtp_password
DBT_TARGET_PATH=/home/kdrogaieva/Prod_Prefect/dbt_target
SMTP_FROM=reportinganalytics@learning.com
SMTP_HOST=email-smtp.us-west-2.amazonaws.com
```

The `SMTP_USER` variable is deliberately excluded from the verification output.

> **Note:** `DBT_LCOM_DW_PROJECT_DIR` will not resolve to an existing directory until the first release is created and `/home/kdrogaieva/Prod_Prefect/current` is created as a symlink to that release.




## 8. Create the Git Mirror

Create a dedicated bare mirror repository for the new Prefect production environment.

The mirror is independent from the existing `Prod` environment and will be used to create versioned releases from the `prefect` branch.

```bash
cd /home/kdrogaieva/Prod_Prefect

git clone --mirror \
  git@github.com:learningcom/transformations.git \
  /home/kdrogaieva/Prod_Prefect/repo-mirror.git
```

Verify the configured remote:

```bash
cd /home/kdrogaieva/Prod_Prefect/repo-mirror.git

git remote -v
```

Expected:

```text
origin  git@github.com:learningcom/transformations.git (fetch)
origin  git@github.com:learningcom/transformations.git (push)
```

Verify that the `prefect` branch exists in the mirror:

```bash
git branch -a | grep prefect
```

Expected:

```text
prefect
```

The `prefect` branch will be used as the source branch for production releases in this environment.



## 9. Create the First Release and Activate It

Create the first Prefect production release from the current `prefect` branch.

Change to the Git mirror and fetch the latest repository state:

```bash
cd /home/kdrogaieva/Prod_Prefect/repo-mirror.git

git fetch --prune origin
```

Resolve the commit SHA currently associated with the `prefect` branch:

```bash
INITIAL_SHA="$(git rev-parse prefect)"
echo "$INITIAL_SHA"
```

Create a Git worktree for that exact commit under the persistent `releases` directory:

```bash
git worktree add \
  "/home/kdrogaieva/Prod_Prefect/releases/$INITIAL_SHA/transformations" \
  "$INITIAL_SHA"
```

Each release is therefore identified by its Git commit SHA:

```text
/home/kdrogaieva/Prod_Prefect/releases/
└── <commit-sha>/
    └── transformations/
```

Create the `current` symlink to activate the release:

```bash
cd /home/kdrogaieva/Prod_Prefect

ln -sfn \
  "/home/kdrogaieva/Prod_Prefect/releases/$INITIAL_SHA/transformations" \
  current
```

Verify the active release:

```bash
readlink -f /home/kdrogaieva/Prod_Prefect/current
```

Example:

```text
/home/kdrogaieva/Prod_Prefect/releases/161cb4a057f383fb38f82f84e7469212c67b2264/transformations
```

The new Prefect environment has its own `current` path and does not modify the existing `/home/kdrogaieva/Prod` environment.

The production environment variable `DBT_LCOM_DW_PROJECT_DIR` points through this symlink:

```text
/home/kdrogaieva/Prod_Prefect/current/dbt/LCom_DW
```

Verify that the configured dbt project is now accessible:

```bash
ls "$DBT_LCOM_DW_PROJECT_DIR/dbt_project.yml"
```

Expected:

```text
/home/kdrogaieva/Prod_Prefect/current/dbt/LCom_DW/dbt_project.yml
```

Future deployments can create a new SHA-based release and switch `current` to the new release without changing the configured dbt project path.


## 10 Connect EC2 to Prefect Cloud

The Prefect installation on EC2 must be authenticated with Prefect Cloud so flows can communicate with the LCom DW Prefect workspace.

The EC2 host does not support browser-based authentication, so use a **Prefect Cloud API key**.

### Create an API Key in Prefect Cloud

In the Prefect Cloud UI:

1. Open your user/account settings.
2. Go to **API Keys**.
3. Create a new API key.
4. Give the key a recognizable name for this EC2 production environment.
5. Copy the generated API key.

> The API key is a secret. Do not add it to the repository, `.env`, shell scripts, or README.

### Authenticate EC2

Activate the production virtual environment if it is not already active:

```bash
source /home/kdrogaieva/Prod_Prefect/.venv/bin/activate
```

Run:

```bash
prefect cloud login
```

Select the option to authenticate using an **API key** and paste the newly created key when prompted.

Select the appropriate Prefect Cloud workspace.

### Verify the Active Workspace

```bash
prefect cloud workspace ls
```

Expected:

```text
┏━━━━━━━━━━━━━━━━━━┓
┃ Workspaces:      ┃
┡━━━━━━━━━━━━━━━━━━┩
│ * lcomdw/default │
└──────────────────┘
 * active workspace
```

The `*` confirms that `lcomdw/default` is the active Prefect Cloud workspace.

Prefect stores the authentication information in the local Prefect profile for the Linux user. The API key therefore does not need to be added to `.bash_profile` or the application environment variables.

Do not store or display the API key in this README.

````markdown
## Install the Deployment Script on EC2

The deployment shell script is maintained in the GitHub `transformations` repository at:

```text
deploy/bin/deploy_release_from_actions.sh
```

The script is part of the repository for source control, but the EC2 deployment process uses a stable copy outside individual releases.

The runtime copy must be located at:

```text
/home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh
```

This allows GitHub Actions to call the same stable deployment entrypoint regardless of which application release is currently active.

### 11. Create or Update the Runtime Copy 
 
Open the runtime deployment script: 
 
```bash 
nano /home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh 
``` 
 
Copy the contents of: 
 
```text 
transformations/deploy/bin/deploy_release_from_actions.sh 
``` 
 
from the repository into the EC2 file. 
 
Save and exit `nano`: 
 
```text 
Ctrl+O 
Enter 
Ctrl+X 
``` 
 
### Make the Script Executable 
 
```bash 
chmod 755 /home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh 
``` 
 
Verify: 
 
```bash 
ls -l /home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh 
``` 
 
Expected permissions: 
 
```text 
-rwxr-xr-x 
``` 
 
The file should be owned by: 
 
```text 
kdrogaieva lcom_dw_admins 
``` 
 
### Validate Bash Syntax 
 
```bash 
bash -n /home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh 
``` 
 
No output means the Bash syntax is valid. 
 
Optionally verify the exit code: 
 
```bash 
echo $? 
``` 
 
Expected: 
 
```text 
0 
``` 
 
### Test Basic Script Execution 
 
Run the script without arguments: 
 
```bash 
/home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh 
``` 
 
Expected: 
 
```text 
ERROR: Missing args. 
Usage: /home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh <sha> <branch> 
``` 
 
Verify the exit code: 
 
```bash 
echo $? 
``` 
 
Expected: 
 
```text 
2 
``` 
 
Exit code `2` is expected because the deployment script requires both a Git commit SHA and branch name. 
 
At this point the deployment script is installed, executable, and syntactically valid. 
 
Do not run it with a real Git SHA until the deployment environment and paths have been validated.

### Test with the Existing Release SHA

Get the SHA of the currently active release:

```bash
CURRENT_SHA="$(basename "$(dirname "$(readlink -f /home/kdrogaieva/Prod_Prefect/current)")")"
echo "$CURRENT_SHA"
```

Expected output is the current Git commit SHA, for example:

```text
161cb4a057f383fb38f82f84e7469212c67b2264
```

Run the deployment script using the existing SHA and the `prefect` branch:

```bash
/home/kdrogaieva/Prod_Prefect/deploy/bin/deploy_release_from_actions.sh \
  "$CURRENT_SHA" \
  prefect
```

Expected output:

```text
Starting release deployment.
Requested SHA=<current-sha> BRANCH=prefect
Current SHA=<current-sha>
Fetching prefect from Git mirror.
No changes: NEW_SHA == OLD_SHA == <current-sha>. Nothing to deploy.
```

Because the requested SHA is already the active release, the script should exit without creating or deploying a new release.

Verify the exit code:

```bash
echo $?
```

Expected:

```text
0
```

Verify that `current` still points to the same release:

```bash
readlink -f /home/kdrogaieva/Prod_Prefect/current
```

Expected pattern:

```text
/home/kdrogaieva/Prod_Prefect/releases/<current-sha>/transformations
```

Verify that the deployment log was created:

```bash
ls -lt /home/kdrogaieva/Prod_Prefect/deploy/logs | head
```

Expected latest log pattern:

```text
deploy_<timestamp>_prefect_<current-sha>.log
```

A successful no-change test confirms that the deployment script can identify the current release, fetch the `prefect` branch, recognize that no deployment is required, create a deployment log, and exit successfully without changing the active release.
