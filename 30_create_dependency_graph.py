#!/usr/local/bin/python3
# -*- coding: utf-8 -*-

__author__="""Co-Pierre Georg (co-pierre.georg@uct.ac.za)"""

import sys
import os
import re
import datetime
import random

import networkx as nx

# ###########################################################################
# METHODS
# ##########################################################################

# -------------------------------------------------------------------------
# do_run(file_name)
# -------------------------------------------------------------------------
def do_run(base_directory, input_file_name, output_identifier, sample_size):
    print(str(datetime.datetime.now()) + " <<<<<< START WORKING ON: " + base_directory + input_file_name + " USING _NO_ SAMPLE SIZE: " + str(sample_size))
    H = nx.read_edgelist(base_directory + input_file_name, delimiter=";", create_using=nx.DiGraph)
    G = nx.DiGraph()

    if True:  # debugging
        print("    << " + str(datetime.datetime.now()) + " H: # Nodes: " + str(len(H.nodes())) + " # Edges: " + str(len(H.edges())))
    for u, v in H.edges():
        if u != v:
            if u != "from_repo":
                G.add_edge(u,v)
    if True:  # debugging
        print("    << " + str(datetime.datetime.now()) + " G: # Nodes: " + str(len(G.nodes())) + " # Edges: " + str(len(G.edges())) + " AFTER REMOVING SELF-LOOPS")
    
    # if sample_size != 0.0:
    #     print("    << " + str(datetime.datetime.now()) + " H: # Nodes: " + str(len(H.nodes())) + " # Edges: " + str(len(H.edges())))
    #     nx.write_gexf(H, base_directory + "sampled-" + str(sample_size) + "_" + output_identifier + ".gexf")
    # else:
    nx.write_gexf(G, base_directory + output_identifier + ".gexf")  # TODO: FOR SOME REASON THE SOURCE INDICATED THE REFERENCED PACKAGE, NOT THE REFERENCING PACKAGE
    print("    << " + str(datetime.datetime.now()) + " FILE WRITTEN TO " + base_directory + output_identifier + ".gexf")
    nx.write_edgelist(G, base_directory + output_identifier + ".edgelist")  
    print("    << " + str(datetime.datetime.now()) + " FILE WRITTEN TO " + base_directory + output_identifier + ".edgelist")

    print(str(datetime.datetime.now()) + " >>>>>> FINISHED")
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
    base_directory = args[1]
    input_file_name = args[2]
    output_identifier = args[3]
    sample_size = float(args[4])

#
# CODE
#
    do_run(base_directory, input_file_name, output_identifier, sample_size)
