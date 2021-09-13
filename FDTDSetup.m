%FDTDSetup

%Allocate array space and initialize fields
% NX, NY, and NZ are defined in "input" inline function
ex = zeros(NX - 1, NY, NZ);
ey = zeros(NX, NY - 1, NZ);
ez = zeros(NX, NY, NZ - 1); 

hx = zeros(NX, NY -1, NZ -1);
hy = zeros(NX -1, NY, NZ -1);
hz = zeros(NX -1, NY - 1, NZ);

% Constants
c = physconst('LightSpeed');
eta_o = 376.7303134617706554679;
mu = eta_o / c;
eps = 1 / (eta_o * c);

% Field array of epsilons
% consider: 1. load eps array from a .mat file.
epsx = zeros(NX - 1, NY, NZ) + eps;
epsy = zeros(NX, NY - 1, NZ) + eps;
epsz = zeros(NX, NY, NZ - 1) + eps;

% Field array of permeabilities
mu_x = zeros(NX, NY -1, NZ -1) + mu;
mu_y = zeros(NX -1, NY, NZ -1) + mu;
mu_z = zeros(NX -1, NY - 1, NZ) + mu;

% solving for dx,dy,dz,dt
dx = DX / (NX-1);
dy = DY / (NY-1);
dz = DZ / (NZ-1);
dt = CFLN / (c * sqrt(1/dx^2 + 1/dy^2 + 1/dz^2));

% maxts from total simulation time or for casex < 4
if (casex < 4)
    maxts = floor(4e-7 / dt);
    %maxts = 2;
end
if (userinput_x == 1)
        maxts = floor(((simtime*10^(-6)) / dt)); %simtime is in microns
end

% Create output vectors
% initialize all 6 E and H fields here
ex_out = zeros(maxts,1);
ey_out = zeros(maxts,1);
ez_out = zeros(maxts,1);
hx_out = zeros(maxts,1);
hy_out = zeros(maxts,1);
hz_out = zeros(maxts,1);
Jzz_out = zeros(maxts,1);

% Solve for fractional lengths and areas
% NOTE: cylinder 1 iterates different than cylinder2 (j,i) instead of (i,j)
cylinder2;   

% Adjusting x-directional mu with fractional areas
% Since we are only working with one configuration of the cylinder
% that is a z-oriented one, then the fractional area of the circle face
% will not effect the x or y mu components, it will effect the z mu
% component. The x and y components will require a different approach,
% though similar in that we still need to find the fractional
% areas... maybe.
% counter = 1;
% for i = 1:NX
%     counter = 1;
%     for j = 1:NY-1
%         for k = 1:NZ-1
%             if(face_change(j,k) == 0)
%                 mu_x(i,j,k) = mu_x(i,j,k)*FA(counter);
%                 counter = counter+1;
%             end
%         end
%     end
% end

% 9/12
% This part may not be neccessary as I should use the fractional lengths
% in the E-update equations. 
% Adjusting x-directional permittivity with fractional lengths
% 5/15 LEFT OFF HERE epsilons array not matching fractional arrays
% xxx = zeros(1,numofmarkedboxes);
% counter = 1;
% for k = 1:NZ
%     counter = 1;
%     for i = 1:NX-1
%         for j = 1:NY-1
%             if(face_change(i,j) == 0)
%                 epsx(i,j,k) = epsx(i,j,k)/frac_length(1,counter);
%                 xxx(counter) = frac_length(1,counter);
%                 counter = counter+1;
%             end
%         end
%     end
% end

        
