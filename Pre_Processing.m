% Pre-Processing

% Create file names for use in outputting to different directories
file1 = fullfile('Output_Cases', 'Case1', 'output_ezout.txt'); % output folder path
file2 = fullfile('Output_Cases', 'Case1', 'output_eyout.txt');
file3 = fullfile('Output_Cases', 'Case1', 'output_exout.txt');
file4 = fullfile('Output_Cases', 'Case1', 'output_hzout.txt');
file5 = fullfile('Output_Cases', 'Case1', 'output_hyout.txt');
file6 = fullfile('Output_Cases', 'Case1', 'output_hxout.txt');

% Delete old output files          
delete Output_Cases\Case1\output_ezout.txt
delete(file2, file3, file4, file5, file6);
