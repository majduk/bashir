The package contains some good practice based scripts grouped into a framework simplifying creating BASH based applications.

INSTALLATION

Please use the RPM / DEB pakage.

1) create user p4app and group p4app
Home Directory: /home/p4app
Shell: /bin/bash

2) go to /home

3) unpack p4app-common-<version>.tar.gz

4) chown -R p4app:p4app /home/p4app

5) go to /home/p4app/COMMON

6) chmod 700 bin/*

7) chmod 700 etc/*

8) chmod 700 lib/*

9) change user: 
su - p4app

10) edit crontab for p4app and add:
MAILTO=""
FRAMEWORK_COMMON=/home/p4app/COMMON
* * * * * bash  $FRAMEWORK_COMMON/bin/env.sh
 
11) configure SMS notifications in /home/p4app/.bash_profile:
export SEND_SMS_HOST=smshost
export SEND_SMS_PORT=smsport
export SEND_SMS_USER=smsuser
export SEND_SMS_PASS=smspass



Copyright (C) 2011  Michal Ajduk

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
