#!/bin/bash
# this script configure HAproxy and SSL certificates in the early testing
# later this will be ignored and ansible will do the work
touch /tmp/touched
sudo su - 
export DOMAIN='youcef.store'
apt install haproxy -y
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot certonly --standalone --non-interactive --agree-tos --domain $DOMAIN --email lahouel.youssouf@gmail.com
mkdir -p /etc/haproxy/certs/
cat /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem > /etc/haproxy/certs/$DOMAIN.pem
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup

cat <<EOF > /etc/haproxy/haproxy.cfg
global
    daemon
    # Set this to your desired maximum connection count.
    maxconn 2048
    # https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#3.2-tune.ssl.default-dh-param
    # bit setting for Diffie - Hellman key size.
    tune.ssl.default-dh-param 2048

defaults
    option forwardfor
    option http-server-close

    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

# In case it's a simple http call, we redirect to the basic backend server
# which in turn, if it isn't an SSL call, will redirect to HTTPS that is
# handled by the frontend setting called 'www-https'.
frontend www-http
    # Redirect HTTP to HTTPS
    bind *:80
    # Adds http header to end of end of the HTTP request
    reqadd X-Forwarded-Proto:\ http
    # Sets the default backend to use which is defined below with name 'www-backend'
    default_backend www-backend

# If the call is HTTPS we set a challenge to letsencrypt backend which
# verifies our certificate and than direct traffic to the backend server
# which is the running hugo site that is served under https if the challenge succeeds.
frontend www-https
    # Bind 443 with the generated letsencrypt cert.
    bind *:443 ssl crt /etc/haproxy/certs/youcef.store.pem
    # set x-forward to https
    reqadd X-Forwarded-Proto:\ https
    # set X-SSL in case of ssl_fc <- explained below
    http-request set-header X-SSL %[ssl_fc]
    # Select a Challenge
    acl letsencrypt-acl path_beg /.well-known/acme-challenge/
    # Use the challenge backend if the challenge is set
    use_backend letsencrypt-backend if letsencrypt-acl
    default_backend www-backend

backend www-backend
   # Redirect with code 301 so the browser understands it is a redirect. If it's not SSL_FC.
   # ssl_fc: Returns true when the front connection was made via an SSL/TLS transport
   # layer and is locally deciphered. This means it has matched a socket declared
   # with a "bind" line having the "ssl" option.
   redirect scheme https code 301 if !{ ssl_fc }
   # Server for the running hugo site.
   server www 10.0.0.4:80

backend letsencrypt-backend
   # Lets encrypt backend server
   server letsencrypt 10.0.0.4:80
EOF

systemctl enable --now haproxy.service
systemctl status haproxy.service

#ss -tuna
#telnet $DOMAIN 443