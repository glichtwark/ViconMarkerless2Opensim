# -*- coding: utf-8 -*-
"""
Created on Thu Feb  3 18:50:37 2022

@author: Glen Lichtwark
"""

# %%%
import cv2
import mediapipe as mp
import numpy as np
import csv
from pathlib import Path

mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

def mediapipe_video_analysis(file_path):
    
    p = Path(file_path)

    # %%%
    cap = cv2.VideoCapture(file_path)
    
    fileout = p.stem + '.csv'
    
    dt = 1/cap.get(cv2.CAP_PROP_FPS)
    
    # Check if camera opened successfully
    if (cap.isOpened()== False):
      print("Error opening video stream or file")
    
    
    # %%%
    landmarklist = ['Frame Number', 'Time (s)'] + list(np.array([[lmark.name+'_X', lmark.name+'_Y', lmark.name+'_Z', lmark.name+'_C'] for lmark in mp_pose.PoseLandmark]).flatten())
    
    # Export to CSV
    with open(fileout, mode='w', newline='') as f:
        csv_writer = csv.writer(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(landmarklist) 
     
    scale_percent = 100 # percent of original size
    
    ## Setup mediapipe instance
    with mp_pose.Pose(static_image_mode = False, min_detection_confidence=0.65, min_tracking_confidence=0.8, model_complexity=2, smooth_landmarks=False) as pose:
        while cap.isOpened():
            ret, frame = cap.read()
            
            if ret == True:
            
                frameId = int(cap.get(1)) # get current frame ID
                
                width = int(frame.shape[1] * scale_percent / 100)
                height = int(frame.shape[0] * scale_percent / 100)
                dim = (width, height)
                  
                # resize image
                resized = cv2.resize(frame, dim, interpolation = cv2.INTER_AREA)
            
            
                # Recolor image to RGB
                image = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
                image.flags.writeable = False
              
                # Make detection
                results = pose.process(image)
            
                # Recolor back to BGR
                image.flags.writeable = True
                image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
                
                # Extract landmarks
                try:
                    landmarks = results.pose_landmarks.landmark
                    
                    frame_time_list = [frameId, frameId*dt]
                    landmarks_row =  frame_time_list + list(np.array([[landmark.x*width, landmark.y*height, 0, landmark.visibility] for landmark in landmarks]).flatten())
                    
                    # Export to CSV
                    with open(fileout, mode='a', newline='') as f:
                        csv_writer = csv.writer(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                        csv_writer.writerow(landmarks_row) 
                               
                except:
                    pass
            else:
                break
    
    cap.release()                                                  
    