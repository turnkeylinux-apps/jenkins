#!/usr/bin/python3
"""Set Jenkins admin password

Option:
    --pass=     unless provided, will ask interactively
"""

import sys
import getopt
import string
import subprocess

from libinithooks import inithooks_cache
from libinithooks.dialog_wrapper import Dialog

def usage(s=None):
    if s:
        print("Error:", s, file=sys.stderr, **kwargs)
    print("Syntax: %s [options]" % sys.argv[0], file=sys.stderr)
    print(__doc__, file=sys.stderr)
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h", ['help', 'pass='])
    except getopt.GetoptError as e:
        usage(e)

    password = ""

    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Jenkins Password",
            "Enter new password for the Jenkins 'admin' account.")

    subprocess.run(["/usr/lib/inithooks/bin/jenkins_password.sh", password])

if __name__ == "__main__":
    main()
