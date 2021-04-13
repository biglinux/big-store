#!/usr/bin/env python3
# coding=UTF-8

import json
import requests
import sys

response = requests.get('https://aur.archlinux.org/rpc/', params={'v': '5', 'type': 'info', 'arg': sys.argv[1]})
data = json.loads(response.text)
for p in data['results']:
    if 'ID' in p:
        print(p['ID'])
    if 'Name' in p:
        print(p['Name'])
    if 'PackageBaseID' in p:
        print(p['PackageBaseID'])
    if 'PackageBase' in p:
        print(p['PackageBase'])
    if 'Version' in p:
        print(p['Version'])
    if 'Description' in p:
        print(p['Description'])
    if 'URL' in p:
        print(p['URL'])
    if 'NumVotes' in p:
        print(p['NumVotes'])
    if 'Popularity' in p:
        print(p['Popularity'])
    if 'OutOfDate' in p:
        print(p['OutOfDate'])
    if 'Maintainer' in p:
        print(p['Maintainer'])
    if 'FirstSubmitted' in p:
        print(p['FirstSubmitted'])
    if 'LastModified' in p:
        print(p['LastModified'])
    if 'URLPath' in p:
        print(p['URLPath'])
    if 'Depends' in p:
        print (p['Depends'])
    if 'MakeDepends' in p:
        print("Variable is not defined....!")
    if 'OptDepends' in p:
        print (p['OptDepends'])
    if 'CheckDepends' in p:
        print (p['CheckDepends'])
    if 'Conflicts' in p:
        print (p['Conflicts'])
    if 'Provides' in p:
        print (p['Provides'])
    if 'Replaces' in p:
        print (p['Replaces'])
    if 'Groups' in p:
        print (p['Groups'])
    if 'License' in p:
        print (p['License'])
    if 'Keywords' in p:
        print (p['Keywords'])

