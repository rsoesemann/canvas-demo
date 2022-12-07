#!/bin/bash
source `dirname $0`/config.sh

echo "Set default Dev Hub"
execute sfdx force:config:set defaultdevhubusername=$DEV_HUB_ALIAS

echo "Deleting old scratch org"
sfdx force:org:delete -p -u $SCRATCH_ORG_ALIAS

echo "Creating scratch ORG"
execute sfdx force:org:create -a $SCRATCH_ORG_ALIAS -s -f ./config/project-scratch-def.json -d 14

echo "Pushing changes to scratch org"
execute sfdx force:source:push

echo "Assigning permission"
execute sfdx force:user:permset:assign -n Admin

echo "Make sure Org user is english"
sfdx force:data:record:update -s User -w "Name='User User'" -v "Languagelocalekey=en_US"

echo "Running Apex Tests"
execute sfdx force:apex:test:run -l RunLocalTests -w 30 -c -r human

echo "Running CLI Scanner"
execute sfdx scanner:run --target "force-app" --pmdconfig "ruleset.xml"

if [ -f "package.json" ]; then
  echo "Running jest tests"
  execute npm install
  execute npm run test:unit
fi