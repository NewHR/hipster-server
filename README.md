# Hipster Server

### Simple modern Nginx server image based Debian with Let's Encrypt integrated and Google Page Speed module support

Hipster Server - a modern Nginx web and proxy server docker container image with automatic [Let's Encrypt](https://letsencrypt.org) certificates, HTTP/2 and [Google Page Speed module](https://developers.google.com/speed/pagespeed/module/) module supports.

## How to use

- get docker-compose.yml and change things for enable automatic SSL and HTTP/2
    - set `LETSENCRYPT=true` if you want automatic certificate install and renewal
    - `LE_EMAIL` should be your email
    - `LE_DNAME` should be your main domain name
- pull image - `docker-compose pull`
- if you don't want pre-built image, make you own. `docker-compose build` will do it
- start it `docker-compose up`

## Via NPM

If you install NPM, you can run commands via NPM:

- `npm run build` alias for `docker-compose build;docker images`
- `npm start` alias for `docker-compose up -d;docker ps`
- `npm stop` alias for `docker-compose stop && docker rm $(docker ps -qa);docker ps -a`
- `npm run clean` alias for `docker rmi $(docker images | grep none | awk '{print $3}');docker images`

## Interface

### Ports

- HTTP (80)
- HTTPS (443)

### Paths/Volumes

- `/etc/nginx/` nginx configuration
- `/etc/letsencrypt` let's encrypt folder with certificates and information
- `/var/pagespeed` pagespeed cache files
- `/www/sites` static files, usually one subfolder per site.


## Some implementation details

- image based on [okdocker/nginx image](https://okdocker.github.io/nginx.html) with compiled nginx (version depends on image tag, either mainline or stable)
and ngx_pagespeed module.
- image uses debian's `certbot` package.
- `script/entrypoint.sh` requests LE certificate and will refresh every 70 days (default value).
- hipster-server on [docker-hub](https://hub.docker.com/)


## About
Created for hipsetrs in New.HR by developers of this company :)

### Need a JOB?
See our job list: http://vacancy.new.hr
