#!/bin/bash

# WORK IN PROGRESS
database_source='dilbert_stage5'
database_destination='dilbert_test'
touch ~/downloads/databases/${database_destination}.sql
ssh -i ~/.ssh/fetch dbfetch@hfstagedb301.amuniversal.com "mysqldump --single-transaction ${database_source}" >~/downloads/databases/${database_destination}.sql
# ssh -l user remoteserver "mysqldump -mysqldumpoptions database | gzip -3 -c" > /localpath/localfile.sql.gz
# ssh hfstagedb301 -e "mysqldump $database_source" | mysql $database_destination
# mysql -e "create database $database_destination;"
