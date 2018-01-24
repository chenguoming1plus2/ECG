Recently, I sorted the code for normal and abnormal classification and added comments to make it easy to understand. The code includes four parts, the data processing originating from the online MITDB, feature extraction, classification and the display of the results. Several important files are introduced as follows.

'ReadSaveMITDB_Rpeaks.m' reads the original ecg data information, such as raw ecg signal and annotations, and saves desired information into the '.mat' file.

'main_beat_QRS.m' conducts the classification task, where 'RQST_extraction_m3.m' extracts features.

Folder 'data' stores the original data and extracted feature data. However, the size of MITDB is as large as 90 Mb, which I couldn't include in the zip file but you can easily download from Physionet using the way I showed you on Monday.

Folder 'figs' includes 'drawing.m' to draw important figures used in my paper using the data saved from the 'main_beat_QRS.m'.
