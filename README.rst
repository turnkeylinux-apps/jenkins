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
   
   - Installed from upstream source code to /var/lib/tomcat6/webapps
   - Jenkins is preconfigured with PrivateSecurityRealm, providing users
     full control once logged in. Signup is disabled by default.
   - Includes all popular VCS clients and related Jenkins plugins for
     Git, Bazaar, Mercurial and Subversion.
   - JENKINS\_HOME configured in environment: /var/local/lib/jenkins.

- Tomcat, Apache and Java configurations
   
   - OpenJDK and Tomcat installed and maintained from package
     management.
   - Apache2 Jk loadbalancer connector to Tomcat (performance).
   - JkMounts for jenkins, admin, manager, host-manager applications.
   - Configured Tomcat admin/manager roles and admin user.
   - Configured Tomcat AJP connector to bind to localhost (security).
   - Removed tomcat HTTP connector listener (security).
   - Tomcat and Java environment variables configuration system wide.

- SSL support out of the box.
- Includes postfix MTA (bound to localhost) for sending of email (e.g.
  password recovery).
- Webmin modules for configuring Apache and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL, phpMyAdmin: username **root**
-  Jenkins: default username **admin@example.com**


.. _Jenkins: http://jenkins-ci.org/
.. _TurnKey Core: http://www.turnkeylinux.org/core
