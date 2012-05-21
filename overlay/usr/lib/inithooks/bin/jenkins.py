#!/usr/bin/python
"""Set Jenkins admin password and email

Option:
    --pass=     unless provided, will ask interactively
    --email=    unless provided, will ask interactively

"""

import os
import sys
import getopt

import hashlib
import string
import random

import xml.dom.minidom

from dialog_wrapper import Dialog
from executil import system

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

class JenkinsUserConfig:
    JENKINS_HOME = "/var/local/lib/jenkins"

    def __init__(self, username):
        self.path = os.path.join(self.JENKINS_HOME, 'users', username, 'config.xml')
        self.doc = xml.dom.minidom.parse(self.path).documentElement
    
    def update(self, name, value):
        node = self.doc.getElementsByTagName(name)[0]
        childnode = node.childNodes[0]
        childnode.data = value

    def write(self):
        fh = file(self.path, "w")
        print >> fh, "<?xml version='1.0' encoding='utf-8'?>"
        self.doc.writexml(fh)
        print >> fh, "\n"
        fh.close()

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass=', 'email='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    email = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val
        elif opt == '--email':
            email = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Jenkins Password",
            "Enter new password for the Jenkins 'admin' account.")

    if not email:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        email = d.get_email(
            "Jenkins Email",
            "Enter email address for the Jenkins 'admin' account.",
            "admin@example.com")

    salt = ''.join((random.choice(string.letters+string.digits) for x in range(6)))
    hashpass = hashlib.sha256(password+"{"+salt+"}").hexdigest()
    salthash = salt+":"+hashpass

    admin = JenkinsUserConfig('admin')
    admin.update('passwordHash', salthash)
    admin.update('emailAddress', email)
    admin.write()

    # restart tomcat if running so password change will take effect
    try:
        system("/etc/init.d/tomcat6 status >/dev/null")
        system("/etc/init.d/tomcat6 restart")
    except:
        pass


if __name__ == "__main__":
    main()

