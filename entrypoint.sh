#!/bin/bash -l

# organization
ORG="SFLScientific"
# QA team and fallback QA team
# get team from project name
TEAM=$(echo "project"_$(basename $(pwd))"_qa" | tr '[:upper:]' '[:lower:]' | sed 's/-/_/g')
echo "Team is " $TEAM
FALLBACK_TEAM="QA"
# project manager team
PM_TEAM="ProjectManagers"

# name of file to write to
YAML_FILE="bot.yml"



# make 2 members.json files
function get_members(){
GITHUB_TOKEN=$(./print_token)

URL="https://api.github.com/orgs/$1/teams/$2/members"

echo $URL

# TODO if failed us QA as teams
curl -X GET -u $GITHUB_TOKEN:x-oauth-basic $URL | python -mjson.tool > /tmp/members.json

cat /tmp/members.json | grep '"message": "Not Found"'
GOT_QA_TEAM=$?

if [ $GOT_QA_TEAM -eq 0 ]; then
    rm members.json
    URL="https://api.github.com/orgs/$1/teams/$3/members"
    curl -X GET -u $GITHUB_TOKEN:x-oauth-basic $URL | python -mjson.tool > /tmp/members.json
    echo "{}" > /tmp/pm_members.json
else
    URL="https://api.github.com/orgs/$1/teams/$3/members"
    curl -X GET -u $GITHUB_TOKEN:x-oauth-basic $URL | python -mjson.tool > /tmp/pm_members.json
fi


}


function write_yml(){

    start="groupQA"
    stop=":"

    # start and end line numbers to replace
    START_LINE=0
    END_LINE=0

    INCREMENT_START=1
    INCREMENT_END=1

    STOP_INCREMENT_END=-1

    while IFS="" read -r p || [ -n "$p" ]
    do
      if [[ $p == *$start* ]]; then
        INCREMENT_START=0
      fi

      if [ $INCREMENT_START -eq 1 ]; then
        ((START_LINE=$START_LINE+1))

      else # if past start, check for increment end
         if [[ $p == *$stop* ]]; then
              ((STOP_INCREMENT_END=$STOP_INCREMENT_END+1))
         fi

      fi

      if [ $STOP_INCREMENT_END -eq 1 ]; then
         INCREMENT_END=0
      fi


      if [ $INCREMENT_END -eq 1 ]; then
         ((END_LINE=$END_LINE+1))
      fi

    done < $1
    ((START_LINE=$START_LINE+1))

  python3 - << EOF
import json

f = "$1"
start = int("$START_LINE")
end = int("$END_LINE")

pms = set()
with open("/tmp/pm_members.json", "r") as m:
    members = json.loads(m.read())
    for member in members:
        pms.add(member["login"])

names = set()
with open("/tmp/members.json", "r") as m:
    members = json.loads(m.read())
    for member in members:
        if member["login"] not in pms:
            names.add(member["login"])

all_lines = []
with open(f, "r") as rf:
    all_lines = rf.readlines()

prefix = "    - "
added_content = False

with open(f, "w") as wf:
    content = ""
    i = 0
    for l in all_lines:
        if not (i in range(start, end)):
            content += l
        else:
            if i >= start and not added_content:
                content_to_add = ""
                for name in names:
                    content_to_add += prefix + name + "\n"
                content+=content_to_add
                added_content = True
        i += 1
    wf.write(content)

EOF

}


get_members $ORG $TEAM $FALLBACK_TEAM $PM_TEAM


write_yml $YAML_FILE




