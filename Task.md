Summary
==================================================

Set up an environment on a Vagrant box VM containing a monitoring system, a web server and a simple application. Monitor one application parameter triggering an alert when this parameter exceeds a given threshold.

Time limits
==================================================

7 days to fulfill the tasks described below.

Tasks
==================================================

1. Prepare a Vagrant box with a minimal version of Linux installed
2. Provision the server using a configuration management tool and automate the whole setup as much as possible. All of the additional setup (packages, services, directories, settings, ...) should therefore be described as code
3. Write a simple application (e.g. JVM) that listens on a local port for HTTP requests. It should expose a single application metric for further monitoring (e.g. requests/per sec, load, connections count, etc.) that will grow when the application is put under load
4. Create an Ansible role, a Puppet module, a Chef recipe (or other encapsulation concept if other tool is used) for deploying and running your application
5. Set up basic monitoring system that monitors and keeps trends of basic server parameters (CPU, RAM, disk data)
6. Set up a web server in reverse proxy mode forwarding requests to your application. Expose the port it listens on, to the VM’s host machine, so that it will be accessible from it
7. Set up another virtual host for the web server to listen on another port. This virtual host should serve the monitoring system’s web UI Bonus points will be granted if you set up SSL for this port. Self-signed certificate will do. Expose this port to the host as well
8. Add monitoring to the application metric. Set up thresholds that would trigger an alarm in the monitoring system
9. Create a stress test for the application that would change the reported metric value when the test is launched

Deliverables
==================================================

1. Plain text file with short and sane instructions of: a. how to run stress test b. how to access monitoring system - url, credentials, etc
2. Vagrant project :
    1. should contain a working configuration, so that a simple "vagrant up" can be used to set up the project
    2. should contain all configuration management code that is required to set up environment
    3. should contain all the necessary extra files (if any)

Technical requirements
==================================================

1. Use Linux distribution of your choice, but install minimal version of it
2. Use Puppet, Chef, Ansible or Salt as a configuration management tool
3. Use configuration management tool locally as for a standalone host (without pulling configuration from server/master/etc)
4. Use Zabbix, Ganglia, Nagios or similar tool for monitoring
5. Monitoring system should only visually show alert in dashboard, no other action required
6. All documentation, comments, etc should be written in English

What gets evaluated
==================================================

* Tasks realisation according to the instructions and requirements
* Configuration management tool usage
* Code clarity and structure
* Modern practices, standards and conventions observance
* Documentation clarity
* Project setup easiness

