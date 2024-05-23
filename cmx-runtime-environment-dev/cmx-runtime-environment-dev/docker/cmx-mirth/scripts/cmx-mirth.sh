#! /bin/bash
function throwErrors()
{
    set -e
}

function ignoreErrors()
{
    set +e
}

if [ "$1" = 'java' ]; then
    ignoreErrors
    chown -f -R mirth /opt/mirth-connect/appdata
    chown -f -R mirth /opt/mirth-connect/custom-lib
    chown -f -R mirth /opt/mirth-connect/conf
    throwErrors

    # Add values to mirth.properties file from environment variables
    # Note (PCD): I don't love this, but I tried to do this several other ways and
    # this was the only approach I could find that worked.
    echo "database.url = " $MIRTH_DB_URL >> /opt/mirth-connect/conf/mirth.properties
    echo "database.username = " $MIRTH_DB_USERNAME >> /opt/mirth-connect/conf/mirth.properties
    echo "database.password = " $MIRTH_DB_PASSWORD >> /opt/mirth-connect/conf/mirth.properties
    echo "database.max-connections = " $MIRTH_DB_MAX_CONNECTIONS >> /opt/mirth-connect/conf/mirth.properties
    echo "administrator.maxheapsize = " $MIRTH_MAX_HEAP_SIZE >> /opt/mirth-connect/conf/mirth.properties

    # "Step down" from root
    exec sudo -E -u mirth "$@"
fi

throwErrors
exec "$@"
