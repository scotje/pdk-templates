#!/bin/bash
set -x # echo commands with vars expanded
set -e # exit immediately on error

TEMPLATE_PR_DIR=$PWD

pdk new module new_module --template-url="file://$TEMPLATE_PR_DIR" --skip-interview
pushd new_module
cp "$TEMPLATE_PR_DIR/.travis/fixtures/new_provider_sync.yml" ./.sync.yml
pdk new class new_module
pdk new defined_type testtype
pdk new provider testprovider
pdk new task testtask
pdk validate
pdk test unit
popd

pdk new module convert_from_last_release --skip-interview
pushd convert_from_last_release
pdk convert --template-url="file://$TEMPLATE_PR_DIR" --skip-interview --force
cat convert_report.txt
popd

git clone --depth=1 --branch=master https://github.com/puppetlabs/pdk-templates.git ../master-pdk-templates
pdk new module convert_from_master --template-url="file://$TEMPLATE_PR_DIR/../master-pdk-templates" --skip-interview
pushd convert_from_master
pdk convert --template-url="file://$TEMPLATE_PR_DIR" --skip-interview --force
cat convert_report.txt
popd
