# ApacheDS

This Docker image provides an [ApacheDS](https://directory.apache.org/apacheds/) LDAP server. Optionally it could be used to provide a [Kerberos server](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html#kerberos-server) as well.

The project sources can be found on [GitHub](https://github.com/openmicroscopy/apacheds-docker). The Docker image on [Docker Hub](https://registry.hub.docker.com/u/openmicroscopy/apacheds/).


## Build

    git clone https://github.com/openmicroscopy/apacheds-docker.git
    docker build -t openmicroscopy/apacheds:2.0.0.AM27 apacheds-docker


## Installation

The folder */var/lib/apacheds* contains the runtime data and thus has been defined as a volume. The image uses exactly the file system structure defined by the [ApacheDS documentation](https://directory.apache.org/apacheds/advanced-ug/2.2.1-debian-instance-layout.html).

The local container that was built in the previous steps by issing the following command:

    docker run --name ldap --platform linux/amd64 -dit -p 389:10389 openmicroscopy/apacheds:2.0.0.AM27

The container can be started using a pre-built remote image by issuing the following command:

    docker run --name ldap --platform linux/amd64  -d -p 389:10389 openmicroscopy/apacheds


## Usage

You can manage the ldap server with the admin user *uid=admin,ou=system* and the default password *secret*. The *default* instance comes with a pre-configured partition *dc=openmicroscopy,dc=org*.

An individual admin password should be set following [this manual](https://directory.apache.org/apacheds/basic-ug/1.4.2-changing-admin-password.html).

Then you can import entries into that partition via your own *ldif* file:

    ldapadd -v -h <your-docker-ip>:389 -c -x -D uid=admin,ou=system -w <your-admin-password> -f sample.ldif


## Customization

### Custom Root DC

This image uses `openmicroscopy.org` as the root DC. To customize Apache with a different root DC, you will need
to extend and rebuild your image.

First find and replace a number of strings within `ome.ldif`, `instance/config.ldif` and `instance/ads-contextentry.decoded`.
Specifically find and replace `dc=org`, `dc: org`, `openmicroscopy.org` and `openmicroscopy` e.g for a custom root DC of `example.com`:

```shell
$ sed -i 's/openmicroscopy/example/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
$ sed -i 's/dc=org/dc=com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
$ sed -i 's/dc: org/dc: com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
```

Then [build](##-Build), [install](##-Installation) and [use](##-Usage) as you normally would.

### Custom Apache DS instances

It is also possible to start up your own defined Apache DS *instance* with your own configuration for *partitions* and *services* - see
[the ApacheDS documentation](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html) for more details.
You need to mount your `config.ldif` replacing the [default](https://github.com/openmicroscopy/apacheds-docker/blob/master/instance/config.ldif)
and set the *APACHEDS_INSTANCE* environment variable properly.

In the provided sample configuration, the instance is named *default*. Assuming your custom instance is called *yourinstance* the following command will do the trick:

    docker run --name ldap -d -p 389:10389 -e APACHEDS_INSTANCE=yourinstance -v /path/to/your/config.ldif:/bootstrap/conf/config.ldif:ro openmicroscopy/apacheds


It would be possible to use this ApacheDS image to provide a [Kerberos server](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html#kerberos-server) as well. Just provide your own *config.ldif* file for that. Don't forget to expose the right port, then.

Also other services are possible. For further information read the [configuration documentation](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html).
