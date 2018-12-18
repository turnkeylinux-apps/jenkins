Jenkins - Continuous integration
================================

`Jenkins`_ is an award-winning application that monitors executions of
repeated jobs, such as building a software project or jobs run by cron.
Among those things, current Jenkins focuses on building/testing software
projects continuously (e.g., like CruiseControl) and monitoring
executions of externally-run jobs.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Jenkins configurations:

   - Jenkins is installed from the `Long Term Support`_ package
     repository managed directly by the Jenkins project. 
     
     **Security note**: Updates to Jenkins may require supervision so
     they **ARE NOT** configured to install automatically. See below for
     updating Jenkins.

   - Jenkins is preconfigured to use PAM authentication.
   - Includes all popular VCS clients and related Jenkins plugins for
     Git, Bazaar, Mercurial and Subversion.
   - JENKINS\_HOME configured in environment: /var/lib/jenkins.
   - jenkins-cli bash wrapper script - can now use 'jenkins-cli' instead of
     'java -jar path/to/jenkins-cli.jar' (convenience).

- SSL support out of the box.
- Includes postfix MTA (bound to localhost) for sending of email (e.g.
  password recovery).
- Webmin modules for configuring Apache and Postfix.

Supervised Manual Jenkins Update
--------------------------------

Before upgrading it is recommended that you consult the relevant `upgrade
guide`_. Once satisfied, you can upgrade to the latest version of Jenkins
from the command line::

    apt-get update
    apt-get install jenkins

We recommend subscribing to the `Jenkins Security Advisories`_ mailing list.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**
-  Jenkins: default username is email set at first boot

.. _Jenkins: http://jenkins-ci.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Long Term Support: http://pkg.jenkins-ci.org/debian-stable/
.. _upgrade guide: https://jenkins.io/doc/upgrade-guide/
.. _Jenkins Security Advisories: https://groups.google.com/forum/#!forum/jenkinsci-advisories
