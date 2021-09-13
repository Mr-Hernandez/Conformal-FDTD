% INPUTFILE: User Input once

%-----------INSTRUCTIONS---------------------------------------
% Each case can be represented by a single input file and its
% corresponding sourceinput files. 
%
% The input file here should be modified and placed in the
% project folder along all the .m files, and it should be
% named "inputfile.m". Only one case can be run at a time for now.
%-----------------------------------------------------------------






%----------USER INPUTS-----------------------------------------------------
%Global Sampling Size: Dimensions of bounding box in meters
DX = 1;
DY = 1;
DZ = 1;

% Number of grid lines (6 grid lines means 5 dx lengths) dx=DX/(NX-1)
NX = 6; NY = 6; NZ = 6;

%Courant Number: stability at CFLN < 1
CFLN = 0.99;

% E and H Sources
numofsources = 1;   % total number of sources
numofsources_M = 0; % needed to know how many times to run loop for J and M sources

% time steps or total simulation time
userinput_x = 1;       % Enter 0 or 1 to use time steps or total simulation time
maxts = 1050;          % Enter number of time steps
simtime = 0.4;%us      % Enter total simulation time in microns

% Output options (Temporary hardcode, later will read this from an output
% options file.
ifld1 = 4;
jfld1 = 4;
kfld1 = 4;
ifld2 = 4;
jfld2 = 4;
kfld2 = 5;
% also needed here: which direction to output, E or H, output all option...
%-----------------------------------------------------------------------




%-------MAKING ARRAYS CONTAINING SOURCE GENERATOR INFORMATION-----------
indexM = zeros(numofsources_M, 1);         % keep track of J vs M sources
indexJ = zeros(numofsources-numofsources_M, 1);   %k keep track of J sources
typeofsource = zeros(numofsources,1);      % Choose type of source: 0 = J, 1 = M
directionofsource = zeros(numofsources,1); % Enter a direction for source: 0=x, 1=y, 2=z");
isrce1 = zeros(numofsources, 1);
jsrce1 = zeros(numofsources, 1);
ksrce1 = zeros(numofsources, 1);
isrce2 = zeros(numofsources, 1);
jsrce2 = zeros(numofsources, 1);
ksrce2 = zeros(numofsources, 1);
tw = zeros(numofsources, 1);
to = zeros(numofsources, 1);

for n = 1:numofsources                  % read in source data from files
%     disp("Source ", num2str(n), ":");
%     disp("----------------------------");
%     typeofsources(n) = input("Enter 0 for J or 1 for M");
%     directionofsource(n) = input("Enter a direction for source: 0=x, 1=y, 2=z");
%     isrce1(n) = input("Enter isrce1");
%     jsrce1(n) = input("Enter jsrce1");
%     ksrce1(n) = input("Enter ksrce1");
%     isrce2(n) = input("Enter isrce2");
%     jsrce2(n) = input("Enter jsrce2");
%     ksrce2(n) = input("Enter ksrce2");
%     tw(n) = input("Enter tw");
%     to(n) = input("Enter to");

    filename = sprintf("sourceinput%d.mat", n); 
    load(filename); % 1 file for each source
    warning("sourceinput# files must read from top folder. Change later to read from User_Input folder");
    typeofsource(n) = inputarr(1);
    directionofsource(n) = inputarr(2);
    isrce1(n) = inputarr(3);
    jsrce1(n) = inputarr(4);
    ksrce1(n) = inputarr(5);
    isrce2(n) = inputarr(6);
    jsrce2(n) = inputarr(7);
    ksrce2(n) = inputarr(8);
    tw(n) = inputarr(9);
    to(n) = inputarr(10);
    
    % Make an index of the sources
    if(typeofsource(n) == 1)
        indexM(n) = n;
    else 
        indexJ(n) = n;
    end
    
end
%--------------------------------------------------------------------------


