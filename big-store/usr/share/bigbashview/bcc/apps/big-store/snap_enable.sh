#!/bin/bash

systemctl start snapd
systemctl enable snapd
systemctl start apparmor
systemctl enable apparmor
