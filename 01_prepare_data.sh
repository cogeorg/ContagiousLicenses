#!/usr/bin/env bash
LANGUAGE="$1"
BASEDIR="$2"
STEP="$3"

VERSION=1.6.0-2020-01-12
GITDIR=~/Git/SoftwareUpdates/


# ###########################################################################
#
# PRODUCTION RUN 1.6.0
#
# ###########################################################################
# USES libraries-1.6.0-2020-01-12.tar.gz
if [ "$LANGUAGE" == "JavaScript" ]; then
    BASENAME=NPM
    DEPFILE=dependencies_$BASENAME.csv
    VERSFILE=versions_$BASENAME.csv
fi

if [ "$LANGUAGE" == "Rust" ]; then
    BASENAME=Cargo
    DEPFILE=dependencies_$BASENAME.csv
    VERSFILE=versions_$BASENAME.csv
fi 

if [ "$LANGUAGE" == "Python" ]; then
    BASENAME=Pypi
    DEPFILE=dependencies_$BASENAME.csv
    VERSFILE=versions_$BASENAME.csv
fi

if [ "$LANGUAGE" == "r" ]; then
    BASENAME=Cran
    DEPFILE=dependencies_$BASENAME.csv
    VERSFILE=versions_$BASENAME.csv
fi


#
# PART 1: PREPARE RAW DATA
#
if [ "$STEP" == "10" ]; then
./10_prepare_repositories.py \
  $BASEDIR \
  libraries-$VERSION/repositories-$VERSION.csv \
  $BASENAME/repositories_$BASENAME.csv \
  $LANGUAGE
fi 

if [ "$STEP" == "11" ]; then
./11_prepare_projects.py \
  $BASEDIR \
  libraries-$VERSION/projects-$VERSION.csv \
  $BASENAME/projects_$BASENAME.csv \
  $BASENAME
fi

if [ "$STEP" == "12" ]; then
./12_prepare_versions.py \
  $BASEDIR \
  libraries-$VERSION/versions-$VERSION.csv \
  $BASENAME/versions_$BASENAME.csv \
  $BASENAME
fi

#
# PART 2: PREPARE REPO-LEVEL DEPENDENCIES
#

# CAREFUL: CAN TAKE LONG FOR NPM
# repo_dependencies_NPM.csv is very large ~61GB and might be in external storage only (/Volumes/Transcend/Data/NPM/) 
# EXAMPLE:
# Pierres-Air:SoftwareProductionNetworks pierregeorg$ head /Volumes/Transcend/Data/NPM/repo_dependencies_NPM.csv 
# ID;ProjectName;RepoID;DependencyProjectName;DependencyRequirements;DependencyProjectID
# 48593236;brianmhunt/knockout-modal;1;gulp;^3.8.8;287937
# 48593241;brianmhunt/knockout-modal;1;gulp-autoprefixer;^1.0.0;154595
# 48593245;brianmhunt/knockout-modal;1;gulp-bump;^0.1.11;287978
#
# ./15_match_repositories.py \
#     /Volumes/Transcend/Data/$BASENAME/repo_dependencies_$BASENAME-test.csv \
#     $BASEDIR/$BASENAME/projectid_repoid-cuts-test.csv \
#     $BASEDIR/$BASENAME/repoid-cuts-test.csv \
#     $BASEDIR/$BASENAME/repo_dependencies_$BASENAME-cuts-test.csv 
if [ "$STEP" == "15" ]; then
    ./15_match_repositories.py \
        /Volumes/Transcend/Data/$BASENAME/repo_dependencies_$BASENAME.csv \
        $BASEDIR/$BASENAME/projectid_repoid-cuts.csv \
        $BASEDIR/$BASENAME/repoid-cuts.csv \
        $BASEDIR/$BASENAME/repo_dependencies_$BASENAME-cuts.csv 
fi

#
# PART 3: CREATE AND ANALYZE DEPENDENCY GRAPH
#
# FIRST: RUN CODE IN "HOOK #1: REPO DEPENDENCIES -- CUTS"
if [ "$STEP" == "30" ]; then
    ./30_create_dependency_graph.py $BASEDIR/$BASENAME/ repo_dependencies_$BASENAME-cuts.csv repo_dependencies_$BASENAME-cuts 0.0
fi
# NOTE: CREATE CENTRALITIES USING GEPHI WITH THE LCC FILE
if [ "$STEP" == "80" ]; then
    ./80_analyze_graph.py $BASEDIR/$BASENAME/ repo_dependencies_$BASENAME-cuts False False False False 
fi

#
# OPTIONAL: SPLIT INPUT FILES BY MONTH
#
if [ "$STEP" == "20" ]; then
    rm -rf $BASEDIR/$BASENAME/20_time_split/repositories/* 2>/dev/null
    ./20_split_files.py $BASEDIR/$BASENAME repositories_$BASENAME.csv $BASEDIR/$BASENAME/20_time_split/repositories/ 8

    rm -rf $BASEDIR/$BASENAME/20_time_split/versions/* 2>/dev/null
    ./20_split_files.py $BASEDIR/$BASENAME versions_$BASENAME.csv $BASEDIR/$BASENAME/20_time_split/versions/ 3

    rm -rf $BASEDIR/$BASENAME/20_time_split/projects/* 2>/dev/null
    ./20_split_files.py $BASEDIR/$BASENAME projects_$BASENAME.csv $BASEDIR/$BASENAME/20_time_split/projects/ 2
fi