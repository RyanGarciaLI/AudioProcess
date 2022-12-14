% a speech recognition script or function using MFCC

% clear all; close all; clc; % comment to convert to function

function opt_value = speechRecog(wavFileA, wavFileB)%uncomment,become func
addpath('mfcc/mfcc');
% mfccA = wav2mfcc1('audios/s5A.wav'); % comment to convert to function
% mfccB = wav2mfcc1('audios/s5B.wav'); % comment to convert to function
mfccA = wav2mfcc1(wavFileA); % uncomment become func
mfccB = wav2mfcc1(wavFileB); % uncomment, become func

sizeA = size(mfccA);
sizeB = size(mfccB);
T_A = sizeA(2);
T_B = sizeB(2);

% build distortion matrix
distort_mat = zeros(T_A, T_B);
for i=1:T_A
    for j=1:T_B
        distort_mat(i,j) = sqrt(sum((mfccA(2:13,i) - mfccB(2:13,j)).^2));
    end
end

% build accumulation matrix
accum_mat = zeros(T_A, T_B);
for i=1:T_A
    for j=1:T_B
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

% find optimal value
opt_row = -1;
opt_col = -1;
opt_value = Inf;

for i=T_A-3:T_A
    if accum_mat(i,T_B) < opt_value
        opt_value = accum_mat(i,T_B);
        opt_row = i;
        opt_col = T_B;
    end
end

for j=T_B-3:T_B
    if accum_mat(T_A, j) < opt_value
        opt_value = accum_mat(T_A, j);
        opt_row = T_A;
        opt_col = j;
    end
end

% fprintf("optimal point %.3f at (%d,%d)\n", opt_value, opt_row, opt_col);

% find optimal path
max_path_len = T_A + T_B;
opt_path = zeros(max_path_len, 3); % value, row, col
opt_path(1,:) = [opt_value, opt_row, opt_col];
path_step = 2;
current_row= opt_row;
current_col = opt_col;
while current_row ~= 1 || current_col ~= 1
    minimum = Inf;
    next_row = -1;
    next_col = -1;
    if current_row >= 2 && current_col >= 2 && minimum > accum_mat(current_row-1, current_col-1)
        minimum = accum_mat(current_row, current_col);
        next_row = current_row - 1;
        next_col = current_col - 1;
    end
    if current_row >= 2 && minimum > accum_mat(current_row-1, current_col)
        minimum = accum_mat(current_row-1, current_col);
        next_row = current_row - 1;
        next_col = current_col;
    end
    if current_col >= 2 && minimum > accum_mat(current_row, current_col-1)
        minimum = accum_mat(current_row, current_col-1);
        next_row = current_row;
        next_col = current_col - 1;
    end

    if next_col == -1 || next_row == -1
        disp("Error !");
        fprintf("step %d, row %d, col %d\n", path_step, current_row, current_col);
    end

    opt_path(path_step, :) = [minimum, next_row, next_col];
    path_step = path_step + 1;
    current_row = next_row;
    current_col = next_col;
end

% uncomment to replace optimal path by Inf
% for i=1:length(opt_path)
%     if opt_path(i,1) == 0
%         break
%     end
% 
%     r = opt_path(i,2);
%     c = opt_path(i,3);
%     accum_mat(r, c) = Inf;
% end

% uncomment to print accumulation matrix
% for i=1:T_A
%     for j=1:T_B
%         fprintf("%9.2f ", accum_mat(i,j));
%     end
%     fprintf("\n");
% end
end




