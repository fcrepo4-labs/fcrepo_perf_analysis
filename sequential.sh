#!/bin/bash

# Check that Rscript is installed
RS=$(which Rscript)
if [ -z ${RS} ]
then
  echo 'Rscript not found. Exiting.'
fi

# install required packages
${RS} 00-install-required-packages.r

# create raw-data directory if it doesn't already exist
mkdir -p raw-data/tars

# run analysis for a single data set
# params:
#  url to tar.gz on aws
#  name of test or analysis 
function get_data_from_s3() {
  url=$1
  prefix=$2
  filename=$(basename ${url})

  # only download if the doesn't already exist
  wget --directory-prefix raw-data/tars/${prefix} --no-clobber ${url} 

  # only unzip if the unpacked data doesn't exist.
  if [ ! -d raw-data/${prefix} ]
  then
    # can't be sure if we're getting a gzipped or non gzipped archive
    echo "unzipping ${filename}"
    tar -C raw-data -xf "raw-data/tars/${prefix}/${filename}"
    # Try renaming log directory
    mv -T raw-data/log raw-data/${prefix}
    # Try creating raw data directory and moving whatever perf.log into it.
    mkdir -p raw-data/${prefix}
    mv raw-data/*perf.log raw-data/${prefix}/perf.log
  fi
}

# run analysis for a single data set
# params:
#  path to a jmeter perf.log or .csv output
#  name of test or analysis 
function run_analysis() {
  input_file=$1
  prefix=$2

  echo "using raw data: ${input_file}"

  # run the analysis per readme.
  ${RS} 01-check-jmeter-log.r ${input_file}
  # Bail if check fails
  if [ $? != 0 ]
  then
    echo "************************* CHECK LOG FAILED *************************"
    echo "ABORTING FROM: ${input_file}"
    echo "********************************************************************"
    return
  fi

  mkdir -p processed-data
  ${RS} 10-jmeter-create-objects-preprocess.r ${input_file} > processed-data/${prefix}-subset.csv
  ${RS} 20-jmeter-create-objects-analysis.r processed-data/${prefix}-subset.csv
  ${RS} 21-jmeter-create-objects-plots.r processed-data/${prefix}-subset.csv
  ${RS} 30-knit-report.r './build' "${prefix}.md"

  # move the final report into a dist directory
  report_dir=dist/${prefix}
  report_files_dir=${report_dir}/${prefix}_files
  # make report directory if non-extant
  mkdir -p ${report_dir}
  # remove any old support files for the report (images)
  if [ -d ${report_files_dir} ]; then rm -r ${report_files_dir}; fi;

  # move the new built report into
  #  for debugging, can also do mv build/${prefix}.html ${report_dir}/${prefix}.html
  #  as the html version is easier to display locally
  mv build/${prefix}.html ${report_dir}/${prefix}.html
  mv build/${prefix}.md ${report_dir}/${prefix}.md
  mv -fT build/${prefix}_files ${report_files_dir}

  # clean build artifacts
  echo "Cleaning build artifacts"
  rm -r build/*
}

# take the url and prefix.
# coordinate getting the data and runnig analysis
function run_analysis_for(){
  URL=$1
  PREFIX=$2
  get_data_from_s3 "${URL}" "${PREFIX}"
  run_analysis "raw-data/${PREFIX}/perf.log" "${PREFIX}"
}

### TEST 1
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test1.vt.a.leveldb.tar.gz'       'test1.vt.a.leveldb'
# Bad: test1.vt.b.leveldb.tar Contains multiple testing sets themselves tar.gz archives.
# run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test1.vt.b.leveldb.tar'          'test1.vt.b.leveldb'
### TEST 2
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.vt.pqsl.tar.gz'            'test2.vt.pqsl'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.vt.mysql.tar.gz'           'test2.vt.mysql'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.vt.leveldb.tar.gz'         'test2.vt.leveldb'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.pu.leveldb.tar'            'test2.pu.leveldb'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.pu.postgres.tar'           'test2.pu.postgres'
# Bad: test2.pu.postgres-gc1.tar does not contain a perf.log
# run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.pu.postgres-gc1.tar'       'test2.pu.postgres-gc1'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test2.pu.postgres-mode5.tar'     'test2.pu.postgres-mode5'
# ## TEST 3
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test3.pu.postgres-mode5.tar'     'test3.pu.postgres-mode5'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test3.vt.leveldb.tar.gz'         'test3.vt.leveldb'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test3.vt.mysql.tar.gz'           'test3.vt.mysql'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test3.vt.pqsl.tar.gz'            'test3.vt.pqsl'
# ### TEST 4
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test4.pu.leveldb.tar.gz'         'test4.pu.leveldb'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test4.pu.postgres.tar.gz'        'test4.pu.postgres'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test4.pu.postgres-mode5.tar.gz'  'test4.pu.postgres-mode5'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test4.pu.postgres-mode51.tar.gz' 'test4.pu.postgres-mode51'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test4.vt.leveldb.tar.gz'         'test4.vt.leveldb'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test4.yu.leveldb.tar.gz'         'test4.yu.leveldb'
# ### TEST 5
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test5.vt.leveldb.tar.gz'         'test5.vt.leveldb'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test5.vt.mysql.tar.gz'           'test5.vt.mysql'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test5.vt.pqsl.tar.gz'            'test5.vt.pqsl'
run_analysis_for  'https://s3.amazonaws.com/f4-performance-results/test5.pu.postgres-mode5.tar.gz'  'test5.pu.postgres-mode5'

echo "Done."
