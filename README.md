# ViconMarkerless2Opensim
Matlab pipeline to run opensource pose estimation (e.g. Mediapipe) on multicamera, vicon calibrated system and then convert this to 3D marker trajectories to apply to a full body Opensim model in order to output 3D kinematics

1. Setup MediaPipe through Python - https://google.github.io/mediapipe/getting_started/python.html
2. Setup Opensim matlab integration - https://simtk-confluence.stanford.edu:8443/display/OpenSim/Scripting+with+Matlab
3. Download folder and add to Matlab Path 
4. Data folder requires each video file named with the name of each camera (from Vicon) and XCP (vicon calibration) file
5. Run media_pipe_3D_reconstruction.m file

