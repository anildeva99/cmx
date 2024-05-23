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

    # "Step down" from root
    exec sudo -E -u mirth "$@"
fi

throwErrors
exec "$@"
