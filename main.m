% %main
% 3D-FDTD
% Main FDTD Routine:

% !cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
% ! Three-dimensional FDTD simulator based on a regular
% ! orthogonal grid.
% !cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
clear             % clear workspace
Input;            % Read input data
FDTDSetup;        % initialize fields to zero
% 
% for n = 1:maxts   % maxts means max number of time steps
%   Eupdate;        % update e-field over all space
%   
%   for nn = 1:(numofsources-numofsources_M)
%     Esource;
%   end
%   
% % Eouterboundary; % update e-fields on exterior boundaries (ABC, PEC/PMC)
%   Hupdate;        % update h-field over all space
%   
%   for nn = 1:(numofsources_M)
%    Hsource;  % eq needs fixing maybe?
%   end
%   
%   output;         % write data to file
%   
% end
% if (casex < 4)    % Post processing requ ires tweaking for each case
% post_processing;  % Post processing of output
% else
%     output2;
% end
