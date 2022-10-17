clear all; close all; clc;
fileIndex = [0, 1, 4, 5, 7, 8];
for i=1:6
    for j=1:6
        fileA = ['audios/s' num2str(fileIndex(i),"%d") 'A.wav'];
        fileB = ['audios/s' num2str(fileIndex(j),"%d") 'B.wav'];
        value = speechRecog(fileA, fileB);
        fprintf("%7.3f ", value);
    end
    fprintf("\n");
end

