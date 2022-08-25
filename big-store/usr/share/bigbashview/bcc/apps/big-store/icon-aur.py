#!/usr/bin/env python3
# coding=UTF-8

import json
import subprocess
import requests
import os
import locale
import sys

# Import gettext module
import gettext

response = requests.get('https://aur.archlinux.org/rpc/', params={'v': '5', 'type': 'info', 'arg': sys.argv[1]})
data = json.loads(response.text)
for p in data['results']:

    if os.path.exists('icons/' + sys.argv[1] + '.png'):
        print ('<div class=icon_middle>' + '<img class="icon_view" src="icons/' + sys.argv[1] + '.png">' + '</div>')
    else:
        print ('<div class=icon_middle><div class=avatar_aur>' + sys.argv[1][0:3] + '</div></div>')


