# ----------------------------------------------------------------------- #
# The OpenSim API is a toolkit for musculoskeletal modeling and           #
# simulation. See http://opensim.stanford.edu and the NOTICE file         #
# for more information. OpenSim is developed at Stanford University       #
# and supported by the US National Institutes of Health (U54 GM072970,    #
# R24 HD065690) and by DARPA through the Warrior Web program.             #
#                                                                         #   
# Copyright (c) 2005-2012 Stanford University and the Authors             #
#                                                                         #   
# Licensed under the Apache License, Version 2.0 (the "License");         #
# you may not use this file except in compliance with the License.        #
# You may obtain a copy of the License at                                 #
# http://www.apache.org/licenses/LICENSE-2.0.                             #
#                                                                         # 
# Unless required by applicable law or agreed to in writing, software     #
# distributed under the License is distributed on an "AS IS" BASIS,       #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         #
# implied. See the License for the specific language governing            #
# permissions and limitations under the License.                          #
# ----------------------------------------------------------------------- #
#
# Author(s): Jen Hicks
# Stanford University
#
# This script loads a model with Millard2012Equilibrium muscles and plots
# the muscles curves for one of the muscles. You can change the curve
# properties via the property editor and thenplot the new curves using this
# script.

# Get a handle to the model
myModel = getCurrentModel()

# Get a handle to one of the muscles (the first one)
myMuscle = modeling.Millard2012EquilibriumMuscle.safeDownCast(myModel.getMuscles().get(0))

# Plot the Tendon Force Length Curve
myFunction = myMuscle.getTendonForceLengthCurve()
myPlot = createPlotterPanel("Tendon Force Length Curve")
myPlot.setMaxX(1.05)
addFunctionCurve(myPlot,myFunction)

# Plot the Active Force Length Curve and Fiber Force Length Curve
myFunction = myMuscle.getActiveForceLengthCurve()
myPlot = createPlotterPanel("Active Force Length Curve")
myPlot.setMaxX(2)
addFunctionCurve(myPlot,myFunction)
myFunction = myMuscle.getFiberForceLengthCurve()
addFunctionCurve(myPlot,myFunction)

# Plot the Force Velocity Inverse Curve
myFunction = myMuscle.getForceVelocityCurve()
myPlot = createPlotterPanel("Force Velocity Curve")
myPlot.setMinX(-1)
myPlot.setMaxX(1)
addFunctionCurve(myPlot,myFunction)



