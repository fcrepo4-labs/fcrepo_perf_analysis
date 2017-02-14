#!/bin/bash

# Check that Rscript is installed
RS=$(which Rscript)
if [ -z ${RS} ]
then
  echo 'Rscript not found'
fi

# Create raw-data directory if it doesn't already exist
mkdir -p raw-data

# wget and unpack test 2 results from virginia tech
if [ ! -e raw-data/test2.vt.pqsl.tar.gz ]
then
  wget -O raw-data/test2.vt.pqsl.tar.gz  https://s3.amazonaws.com/f4-performance-results/test2.vt.pqsl.tar.gz 
fi
tar -C raw-data -xzf raw-data/test2.vt.pqsl.tar.gz
mv -T raw-data/log raw-data/test2.vt.pqsl

if [ ! -e raw-data/test2.vt.mysql.tar.gz ]
then
  wget -O raw-data/test2.vt.mysql.tar.gz   https://s3.amazonaws.com/f4-performance-results/test2.vt.mysql.tar.gz 
fi
tar -C raw-data -xzf raw-data/test2.vt.mysql.tar.gz
mv -T raw-data/log raw-data/test2.vt.mysql

if [ ! -e raw-data/test2.vt.leveldb.tar.gz ]
then
  wget -O raw-data/test2.vt.leveldb.tar.gz https://s3.amazonaws.com/f4-performance-results/test2.vt.leveldb.tar.gz 
fi
tar -C raw-data -xzf raw-data/test2.vt.leveldb.tar.gz
mv -T raw-data/log raw-data/test2.vt.leveldb

# Follow USE instructions from Readme
# Install R packages
${RS} 00-install-required-packages.r

# Check the headers of the data
Rscript 01-check-jmeter-log.r raw-data/test2.vt.pqsl/perf.log
Rscript 01-check-jmeter-log.r raw-data/test2.vt.mysql/perf.log
Rscript 01-check-jmeter-log.r raw-data/test2.vt.leveldb/perf.log

# Create processed data and reports directory
mkdir -p processed-data
mkdir -p reports

# Pre-process and sub sample data
cat raw-data/test2.vt.pqsl/perf.log    | ${RS} 10-jmeter-create-objects-preprocess.r > processed-data/test2.vt.pqsl-subset.csv
cat raw-data/test2.vt.mysql/perf.log   | ${RS} 10-jmeter-create-objects-preprocess.r > processed-data/test2.vt.mysql-subset.csv
cat raw-data/test2.vt.leveldb/perf.log | ${RS} 10-jmeter-create-objects-preprocess.r > processed-data/test2.vt.leveldb-subset.csv

# Perform analysis and generate graphs for each subsampled dataset
mkdir -p reports
cat processed-data/test2.vt.pqsl-subset.csv    | ${RS} 20-jmeter-create-objects-analysis.r
cat processed-data/test2.vt.pqsl-subset.csv    | ${RS} 21-jmeter-create-objects-plots.r
mv reports reports-test2.vt.pqsl

mkdir -p reports
cat processed-data/test2.vt.mysql-subset.csv   | ${RS} 20-jmeter-create-objects-analysis.r
cat processed-data/test2.vt.mysql-subset.csv   | ${RS} 21-jmeter-create-objects-plots.r
mv reports reports-test2.vt.mysql

mkdir -p reports
cat processed-data/test2.vt.leveldb-subset.csv | ${RS} 20-jmeter-create-objects-analysis.r
cat processed-data/test2.vt.leveldb-subset.csv | ${RS} 21-jmeter-create-objects-plots.r
mv reports reports-test2.vt.leveldb

