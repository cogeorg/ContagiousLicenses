#!/usr/local/bin/python3
# -*- coding: utf-8 -*-

__author__="""Co-Pierre Georg (co-pierre.georg@uct.ac.za)"""

import sys
import os
import codecs
import datetime

# ###########################################################################
# METHODS
# ###########################################################################

def sanitize(token):
    components = token.split("/")
    if len(components) > 1:
        # token = components[0].replace("@", "") + "-" + components[1]
        token = components[1]
    token = token.replace('"','')
    return token


# -------------------------------------------------------------------------
# do_run(file_name)
# -------------------------------------------------------------------------
def do_run(input_file_name, project_file_name, repo_file_name, output_file_name):
    print("<<<<<< WORKING ON: ", input_file_name, project_file_name, repo_file_name, output_file_name)
    _count = 0
    _found = 0
    _error = 0

    projects = {}
    repos = {}

    out_text = "from_repo;to_repo\n"
    out_file = open(output_file_name, "w")
    out_file.write(out_text)
    out_file.close()
    out_file = open(output_file_name, "a")

    # PROJECT MATCHES
    with open(project_file_name, encoding="utf-8", errors='replace') as project_file:
        project_file.readline()  # ignore header projectid;repoid
        for project in project_file:
            tokens = project.strip().split(";")
            projects[tokens[0].strip()] = tokens[1].strip()
    project_file.close()
    if False:
        print(projects)
    print("    << " + str(datetime.datetime.now()) + "  " + "PROJECT MATCHES:", len(projects))
        
    # REPO CUTS
    with open(repo_file_name, encoding="utf-8", errors='replace') as repo_file:
        for repo in repo_file:
            repos[repo.strip()] = ""
    repo_file.close()
    if False:
        print("repos:" , repos)
    print("    << " + str(datetime.datetime.now()) + "  " + "REPO MATCHES:", len(repos))

    # NOW THE MAIN FILE
    with open(input_file_name, encoding="utf-8", errors='replace') as input_file:
        input_file.readline()
        for line in input_file:
            _count += 1
            if _count % 1000000 == 0:
                print("    << " + str(datetime.datetime.now()) + "   COUNT: " + str(_count) + " FOUND: " + str(_found))
            tokens = line.strip().split(";")
            try:
                if tokens[2].strip() in repos:
                    from_repo = tokens[2].strip()
                    if tokens[5].strip() in projects:
                        _found += 1
                        to_repo = projects[tokens[5].strip()]
                        out_file.write(from_repo + ";" + to_repo + "\n")
            except:
                pass
    out_file.close()

    print("    >>> FOUND: " + str(_found) + " OF TOTAL: " + str(_count) + " ENTRIES")
    print("    >>> FILE WRITTEN TO:" + output_file_name)
    print(">>>>>> FINISHED")
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
#
#  MAIN
#
# -------------------------------------------------------------------------
if __name__ == '__main__':
#
# VARIABLES
#
    args = sys.argv
    input_file_name = args[1]
    project_file_name = args[2]
    repo_file_name = args[3]
    output_file_name = args[4]

#
# CODE
#
    do_run(input_file_name, project_file_name, repo_file_name, output_file_name)
