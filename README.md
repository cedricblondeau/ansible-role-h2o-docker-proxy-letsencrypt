# ansible-role-h2o-docker-proxy-letsencrypt

> Ansible role that sets up an automated [H2O](https://github.com/h2o/h2o) proxy for docker containers
with automatic creation of Let's Encrypt certificates using [docker-gen](https://github.com/jwilder/docker-gen).

I wrote about this on my blog: https://blog.cedricblondeau.com/2016/08/21/h2o-docker-reverse-proxy/.

## Prerequisites

- Ansible 2.1+
- A docker-enabled target

## Usage

First, clone this repository in your roles path (usually in a `roles` directory alongside your playbook) 
under the name `h2o-docker-proxy-letsencrypt`:

```bash
git submodule add https://github.com/cedricblondeau/ansible-role-h2o-docker-proxy-letsencrypt roles/h2o-docker-proxy-letsencrypt
```

Then, configure (`letsencrypt_email` is the only mandatory variable) and add the role to your playbook:

```yaml
---
- name: Set up an automated H2O proxy for docker containers with automatic creation of Let's Encrypt certificates
  hosts: all
  become: true
  vars:
    letsencrypt_email: youremail_here@domain.tld
  roles:
    - h2o-docker-proxy-letsencrypt
```

Finally, execute your playbook and deploy your apps.

Example :

```
docker pull training/webapp
docker run -d --name training_webapp -e "VIRTUAL_HOST=webapp.dev" training/webapp
```

The VIRTUAL_HOST environment variable is mandatory and is used for:

- Routing the HTTP requests to the containers
- Creating Let's encrypt certificates

The containers being proxied must expose the port to be proxied,
either by using the EXPOSE directive in their Dockerfile 
or by using the --expose flag to docker run or docker create.

If your container exposes multiple ports, 
the role will default to the service running on port 80.
If you need to specify a different port, 
you can set a VIRTUAL_PORT env var to select a different one.

## Deployed containers

The role uses two separated docker images:

- [lkwg82/h2o-http2-server](https://github.com/lkwg82/h2o.docker)
- [cedricbl/letsencrypt-webroot](https://github.com/cedricblondeau/docker-letsencrypt-webroot)

If you want to build the images yourself you can easily override the repositories:

```yaml
h2o_image: lkwg82/h2o-http2-server
letsencrypt_image: cedricbl/letsencrypt-webroot
```

## Dev

This role can easily be tested using Vagrant:

```ruby
Vagrant.configure(2) do |config|
  # Base config
  config.vm.box = "cedricblondeau/ubuntu-xenial64-docker"
  config.vm.hostname = "h2o-docker-proxy-devbox"
  config.vm.network "private_network", ip: "192.168.33.10"

  # Provisioning
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.verbose = "vvvv"
  end
end
```

## Thanks

- https://github.com/nyarla/h2o-proxy-letsencrypt
- https://github.com/jwilder/nginx-proxy
