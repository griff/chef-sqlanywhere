name             "sqlanywhere"
maintainer       "Brian Olsen"
maintainer_email "brian@maven-group.org"
license          "Apache 2.0"
description      "Installs/Configures SQLAnywhere and adds LWRPs to manage databases and users"
long_description "Please refer to README.md (it's long)."
version          "1.1.0"

recipe "sqlanywhere",         "Installs SQLAnywhere"
recipe "sqlanywhere::server", "Installs SQLAnywhere and sets up the database server to run as a network service"

depends "openssl", "~> 1.0.2"
depends "database", "~> 1.3.12"
depends "build-essential", "~> 1.3.4"

supports 'ubuntu'
  