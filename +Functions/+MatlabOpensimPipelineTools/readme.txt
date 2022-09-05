Readme.txt

This  folder contains a bunch of functions which you 
might find useful for processing data from C3D files as well
as generating TRC files and making setup files for running 
Opensim Main programs (e.g. scale, ik, id) from the command line
in Matlab.

Once unzipped, add the folder and all subfolders to the Matlab
path using the function 'editpath' from the command window. For Matlab 
versions beyond 2012 the function 'pathtool' has replaced 'editpath'. 

Also download the example data from the Matlab_tools project 
page - https://simtk.org/home/matlab_tools
This folder contains data plus an example Matlab function which acts
like a pipeline to process data using a model that matches the data. 
Run the example pipeline (e.g. opensim_walking_pipeline.m) and use the data
from the ExampleData folder. 

Please  acknowledge Glen Lichtwark and any other relevant contributors
(for example the C3D functions and XML read/write functions)
for any work used in academic publications.

A big thank you must go to Tim Dorn (University of Melbourne)
for the inspiration for much of these tools with his excellent
C3Dextract toolbox - https://simtk.org/home/c3dtoolbox
