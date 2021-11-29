#!/bin/bash

# This script will copy a repo to ${REPOSPATH}

if [ $# -le 0 ]
then
    echo "Usage: ./reposync.sh repoid"
    exit 1
fi

REPOID=${1}
REPOSPATH=/data/repos

mkdir -p ${REPOSPATH}/${REPOID}
cd ${REPOSPATH}/${REPOID}
rm -f *xml.gz *xml.bz2

yum -q -y install yum-utils createrepo

# Do this for each repo-id or channel-id, this example is for ${REPOID}
rm -rf ${REPOSPATH}/${REPOID}/repodata
reposync -d -l -n --downloadcomps --download-metadata -p ${REPOSPATH} -r ${REPOID}

if [ -e ${REPOSPATH}/${REPOID}/comps.xml ]
then
    createrepo --update --compress-type gz -v ${REPOSPATH}/${REPOID}/ -g comps.xml
else
    createrepo --update --compress-type gz -v ${REPOSPATH}/${REPOID}/
fi
# Now add security information
yum list-sec
cp -p /var/cache/yum/x86_64/7Server/${REPOID}/*updateinfo.xml.gz ${REPOSPATH}/${REPOID}/repodata 2> /dev/null
gzip -d ${REPOSPATH}/${REPOID}/repodata/*updateinfo.xml.gz 2> /dev/null
mv ${REPOSPATH}/${REPOID}/repodata/*updateinfo.xml ${REPOSPATH}/${REPOID}/repodata/updateinfo.xml 2> /dev/null
modifyrepo ${REPOSPATH}/${REPOID}/repodata/updateinfo.xml ${REPOSPATH}/${REPOID}/repodata/ 2> /dev/null
find ${REPOSPATH}/${REPOID} -type d |xargs chmod a+rx
find ${REPOSPATH}/${REPOID} -type f |xargs chmod a+r
