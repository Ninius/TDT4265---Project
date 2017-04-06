%Create multiple MAT-files for class(-es)

clear 
clc

prohibitoryClassIds = [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 15, 16];
mandatoryClassIds = [33, 34, 35, 36, 37, 38, 39, 40];
dangerClassIds = [11, 18, 19, 20 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31];

positiveInstances = createMATfileForMultiClass(dangerClassIds);

