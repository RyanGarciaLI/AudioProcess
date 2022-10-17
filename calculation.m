% Calculate questions in Assignment 1 with the help of matlab functions
% Copyright © RyanGarciaLI

clear all; close all; clc;  

% question 1
freq = 22050;
75 / (1/freq) * 16 / 8

% quesiton 2
clear all;
freq = 44100;
569 * 10^(-3) / (1/freq) * 0.8

% question 5
clear all;
X=[1,2,6,2,6,7,2,8,3,4,6,7,8,5,8];
order = 3;
autocor = zeros(1,order+1);
for j=0:order
    for k=j:length(X)-1
        autocor(j+1) = autocor(j+1) + X(k+1) * X(k+1-j);
    end
end
autocor

% question 6
clear all;
X=[1,2,6,2,6,7,2,8,3,4,6,7,8,5,8];
[a,g] = lpc(X,4);
a % diff sign

% question 7
clear all;
X=[1.1 2.1
   0.3 0.7
   0.2 0.6
   1.4 5.6
   4.5 7.8
   2.3 2.6
   5.5 5.6
   5.7 8.9
   1.2 3.4
   4.5 4.7];
cx = sum(X(:,1)) / length(X(:,1));
cy = sum(X(:,2)) / length(X(:,2));
exy1 = [cx, cy] * (1+0.01);
exy2 = [cx, cy] * (1-0.01);
sum(exy1) + sum(exy2)

% question 8
clear all;
Reference =  [5 7 9 6 4 2 0 1 3 6]; %reference sound segment
input = [ 1 3 5 8 4 3 4 2 5 1]; %input segment
la = length(input);
lb = length(Reference);
distort_mat = zeros(la, lb);
for i=1:la
    for j=1:lb
        distort_mat(i,j) = (input(i) - Reference(j))^2;
    end
end

accum_mat = zeros(la, lb);
for i=1:la
    for j=1:lb
        preceding = Inf(1,3);
        if i >= 2
            preceding(1) = accum_mat(i-1,j);
        end
        if j >= 2
            preceding(2) = accum_mat(i,j-1);
        end
        if i >= 2 && j >= 2
            preceding(3) = accum_mat(i-1, j-1);
        end
        minimum = min(preceding);
        if minimum == Inf
            minimum = 0;
        end
        accum_mat(i,j) = distort_mat(i,j) + minimum;
    end
end

% distort_mat
accum_mat

% question 9
clear all;
2595*log10(1+707/700) - 2595 *log10(1+100/700)

% question 10
clear all;
s = [1 4 5 6 4 3 1 5 7 9 5 4 3 6 7 8 7 4 0 2 3 6 ];
y = fft(s);
m = abs(y)

% question 11
(0.75 * 1000 - 30) / 10 + 1

 
