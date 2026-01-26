#!/usr/bin/env bash
set -euo pipefail

cd /home/kdrogaieva/Prod/docs

# Make sure we are on the docs branch and up to date
git fetch origin
git checkout docs
git pull --rebase origin docs

cp /home/kdrogaieva/Prod/dbt_target/static_index.html index.html
cp /home/kdrogaieva/Prod/dbt_target/index.html colibri_index.html

git add index.html colibri_index.html
git commit -m "Update dbt docs"
git push origin docs
