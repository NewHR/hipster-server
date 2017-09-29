#!/bin/sh
###
echo "Init env"
mkdir -pv /var/log/nginx

###
echo "Enviroument variables"
echo "TIMEZONE=$TIMEZONE"
echo "LETSENCRYPT=$LETSENCRYPT"
echo "LE_EMAIL=$LE_EMAIL"
echo "LE_DNAME=$LE_DNAME"
echo "LE_RT=$LE_RT"

###
echo "init and start server daemon"

###
echo "setup time zone to ${TIMEZONE?Not defined!}"
cp -v /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo $TIMEZONE > /etc/timezone && \

FIRST_FQDN=$(echo "${LE_DNAME?Not defined!}" | cut -d"," -f1)

###
echo "nginx config dir ${NGDIR:=/etc/nginx}"
echo "nginx web root dir ${WEBROOT:=/usr/share/nginx/html}"

###
echo "setup ssl"
echo "ssl refresh time ${LE_RT:=80d}"
echo "ssl files: key=${SSL_KEY:=key.pem}, cert=${SSL_CRT:=crt.pem}"

SSL_KEY=${NGDIR}/ssl/${SSL_KEY}
SSL_CRT=${NGDIR}/ssl/${SSL_CRT}

###
cp -vf ${NGDIR}/services/*.conf ${NGDIR}/conf.d/
for f in `ls ${NGDIR}/conf.d/*.conf`
do
    echo "Parse $f"
    sed -i "s|DOMAINNAME|${FIRST_FQDN}|g;s|WEBROOT|${WEBROOT}|g" $f
    sed -i "s|SSL_KEY|${SSL_KEY}|g;s|SSL_CRT|${SSL_CRT}|g"       $f
done

###
echo "check dhparams.pem"
if [ ! -f "${NGDIR}/ssl/dhparams.pem" ]; then
    echo "make dhparams"
    cd ${NGDIR}/ssl/
    openssl dhparam -out dhparams.pem 2048
    chmod 600 dhparams.pem
fi

###
echo "disable all services"
mv -v ${NGDIR}/conf.d ${NGDIR}/conf.d.disabled

###
(
    echo "await starting nginx daemon 5 seconds ..."
    sleep 5
    echo "start letsencrypt updater"
    while :
    do
	    echo "trying to update letsencrypt ..."
                
        if [ "true" != "${LETSENCRYPT}" ]
        then
            echo "letsencrypt renew certificates disabled"
        else
            certbot \
                certonly -tn --agree-tos --renew-by-default --webroot \
                        --email "${LE_EMAIL}" \
                        -w "${WEBROOT}" \
                        -d "${LE_DNAME}" \

            cp -fv /etc/letsencrypt/live/${FIRST_FQDN}/privkey.pem   $SSL_KEY
            cp -fv /etc/letsencrypt/live/${FIRST_FQDN}/fullchain.pem $SSL_CRT        
        fi

        echo "return back and enable all services"
        mv -v ${NGDIR}/conf.d.disabled ${NGDIR}/conf.d
        echo "reload nginx with ssl and http/2"
        nginx -s reload
        sleep ${LE_RT}
    done
) &
nginx -g "daemon off;"

#EOF#