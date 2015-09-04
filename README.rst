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
   
   - Installed from upstream Debian archive.
   - Jenkins is preconfigured to use PAM authentication.
   - Includes all popular VCS clients and related Jenkins plugins for
     Git, Bazaar, Mercurial and Subversion.
   - JENKINS\_HOME configured in environment: /var/local/lib/jenkins.

- SSL support out of the box.
- Includes postfix MTA (bound to localhost) for sending of email (e.g.
  password recovery).
- Webmin modules for configuring Apache and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL, Adminer: username **root**
-  Jenkins: default username is email set at first boot


.. _Jenkins: http://jenkins-ci.org/
.. _TurnKey Core: http://www.turnkeylinux.org/core
