#!/bin/bash

branch=$1

if [[ ! -z ${KUBE_ENV} ]]
then
    git config remote.origin.url https://github.com/kevinstl/lightning-kube-lnd.git
    git config --global credential.helper store
    jx step git credentials

    ls -al

#    git add .

    git checkout $branch

#    git commit -m "pushing from local jenkins"

    git pull origin
#    git pull origin $branch
#    git fetch origin $branch


#    git push -u origin $branch

#    git remote add local /host-home/Developer/projects/lightning-kube-lnd

#    git push local $branch
    git push origin $branch
fi


#if [ $? -eq 0 ]
#then
#  echo "Deploy Success"
#else
##  echo "Deploy Error" >&2
#  echo "Deploy Error: " $?
#fi
