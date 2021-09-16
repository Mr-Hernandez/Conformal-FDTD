% Cylinder Stuff

%clear

% Temporary variables for testing
%DX = 1; DY = 1; DZ = 1;
%NX = 6; NY = 6; NZ = 6;% Nx is an even number so we get odd num of cells per axis


% These will be user input

% Center points of the cylinder's round face. It is assumed the cylinder
% is oriented such that its face is in the center of the bounding box.
% Only 2 (in this case x_c and y_c) will be used. 
x_c = DX / 2;
y_c = DY / 2;
z_c = DZ / 2;

radius = 0.25;
warning("The case where the circle line goes in and out of same side of box is ignored (should be small effect)");
r_arr = zeros(NX, NY); % this will contain the length to the
                       % center of cylinder from each grid point.
                       % Only one face needs to be calculated.
                       
face_index = zeros(NX, NY);

% due to time I'll restrict this case to a specific cylinder orientation
% otherwise this might change if Nx,Ny,Nz are not equal + other issues too.
% Finding distance from grid point to center of circle
for i = 1:NX
    for j = 1:NY
        %for k = 1:Nz-1 not needed for this specific case
            r_arr(i,j) = sqrt(((i-1)*dx-x_c)^2 + ((j-1)*dy-y_c)^2);
            face_index(i,j) = r_arr(i,j) - radius;
            
% Marking whether grid point is inside, on, or outside the cylinder
            % KEY: -1: in PEC, 0: border, 1: free space
            % 0 will also count as -1 for some applications
            if (face_index(i,j) < 0) face_index(i,j) = -1;
            else if (face_index(i,j) > 0) face_index(i,j) = 1;
            else face_index(i,j) = 0;
            end
            end
            
    end
end


% We'll want to mark how many squares need to be changed and in this we 
% will also mark how many are inside the circle so we can change their
% values to 0, or something else if they are not PEC's later on.
face_change = zeros(NX-1,NY-1);
numofmarkedboxes = 0;
insidePEC = 0; % marks how many squares are.
% NOTE: This implimentation will not work if cylinder center is on
% an actual grid point. It was not something considered here. 
mask = ones(NX-1,NY)*2;
for i = 1:NX-1
    for j = 1:NY-1
        
        % Is it inside PEC? -1
        if (face_index(i,j) <= 0 ...
                && face_index(i+1, j) <= 0 ...
                && face_index(i, j+1) <= 0 ...
                && face_index(i+1 , j+1) <= 0)
            face_change(i,j) = -1;
            insidePEC = insidePEC+1;
        
        % Is it Outside PEC
        else if (face_index(i,j) > 0 ...
                && face_index(i+1, j) > 0 ...
                && face_index(i, j+1) > 0 ...
                && face_index(i+1 , j+1) > 0)
            face_change(i,j) = 1;
            
        % The rest are cells with faces that need to be conformed
            else
                face_change(i,j) = 0;
                numofmarkedboxes = numofmarkedboxes + 1;
            end
            
        end
        mask(i,j) = face_change(i,j);
    end
end


% In this for loop what we do for now is find whether the lower side of 
% the grid square is to be conformed and whether it is inside or outside 
% of the PEC. 
% So we cycle through each grid square and use its lower length (as in
% bottom, not value) to create an NX-1 by NY mask which we will then be
% able to use in the E-update equations or apply it to the epsilon vector
% directly, though the second method may not work for non PEC material.
counter = 1;
cross = zeros(4, numofmarkedboxes + insidePEC);
lengths = zeros(4, numofmarkedboxes + insidePEC);
for i = 1:NX-1
    for j = 1:NY-1
        
        % The coordinates of the current grid square
        x1 = (i-1)*dx;
        x2 = i*dx;
        y1 = (j-1)*dy;
        y2 = j*dy;
        
        % If the grid block is inside the PEC we set 'cross' = -2.
        % so we can identify it later
        if(face_change(i,j) == -1)
            cross(1, counter) = -2;
            cross(2, counter) = -2;
            cross(3, counter) = -2;
            cross(4, counter) = -2;
            counter = counter + 1;
        end
        
        % If we need to conform then we solve for each side of square.
        if(face_change(i,j) == 0)
            % Solving for x-coordinate of crosspoints on x-axis of the box.
            if(x1 < x_c) 
                cross(1, counter) = x_c - sqrt(radius^2 - ((j-1)*dy - y_c)^2);
                cross(2, counter) = x_c - sqrt(radius^2 - (j*dy - y_c)^2);
            else
                cross(1, counter) = x_c + sqrt(radius^2 - ((j-1)*dy - y_c)^2);
                cross(2, counter) = x_c + sqrt(radius^2 - (j*dy - y_c)^2);
            end
            
            % Solving for y-coordinates of crosspoints on y-axis of face.
            if(y1 < y_c) 
                cross(3, counter) = y_c - sqrt(radius^2 - ((i-1)*dx - x_c)^2);
                cross(4, counter) = y_c - sqrt(radius^2 - (i*dx - x_c)^2);
            else
                cross(3, counter) = y_c + sqrt(radius^2 - ((i-1)*dx - x_c)^2);
                cross(4, counter) = y_c + sqrt(radius^2 - (i*dx - x_c)^2);
            end
            
            % Checking validity of values found for xi, yi.
            if(cross(1, counter) == -2) cross(1, counter) = 0; % case if inside PEC
            else if(cross(1, counter) > x2 ...
                    || cross(1, counter) < x1 ...
                    || imag(cross(1, counter))~=0) %isreal returns 0 if imaginary
                cross(1, counter) = -1;
                end
            % This if statement deals with the special case where there were no crosspoints
            % on the lower or upper sides of the grid square. It determines
            % if the lower side of the grid square is completely inside or
            % outside the PEC circle.
              if(cross(1, counter) == -1 && sqrt((x_c - (i-1)*dx)^2 ...
                  + (y_c - (j-1)*dy)^2) < radius)
                  cross(1, counter) = 0;
              end
            end
            
            if(cross(2, counter) == -2) cross(2, counter) = 0;
            else if(cross(2, counter) > x2 ...
                    || cross(2, counter) < x1 ...
                    || imag(cross(2, counter))~=0) %isreal returns 0 if imaginary
                cross(2, counter) = -1;
            end
            end
            
            if(cross(3, counter) == -2) cross(3, counter) = 0;
            else if(cross(3, counter) > y2 ...
                    || cross(3, counter) < y1 ...
                    || imag(cross(3, counter))~=0) %isreal returns 0 if imaginary
                cross(3, counter) = -1;
            end
            end
            
            if(cross(4, counter) == -2) cross(4, counter) = 0;
            else if(cross(4, counter) > y2 ...
                    || cross(4, counter) < y1 ...
                    || imag(cross(4, counter))~=0) %isreal returns 0 if imaginary
                cross(4, counter) = -1;
            end
            end
            % At this point the coordinates are solved and stored
            % Now the next part finds the fractional lengths
            
            % length of lower side of box
            if(cross(1,counter)==-1)
                lengths(1,counter) = dx;
            else if(cross(1,counter)==0)
                    lengths(1,counter) = 0;
            else if(x1 < x_c) 
                lengths(1,counter) = cross(1,counter)-x1;
            else
                lengths(1,counter) = x2 - cross(1,counter);
                end
                end
            end
            
            if(cross(2,counter)==-1) % upper side of box
                lengths(2,counter) = dx;
            else if(cross(2,counter)==0)
                    lengths(2,counter) = 0;
            else if(x1 < x_c) 
                lengths(2,counter) = cross(2,counter)-x1;
            else
                lengths(2,counter) = x2 - cross(2,counter);
                end
                end
            end
            
            if(cross(3,counter)==-1) % left side of box
                lengths(3,counter) = dy;
            else if(cross(3,counter)==0)
                    lengths(3,counter) = 0;
            else if(y1 < y_c) 
                lengths(3,counter) = cross(3,counter)-y1;
            else
                lengths(3,counter) = y2 - cross(3,counter);
                end
                end
            end
            
            if(cross(4,counter)==-1) % right side of box
                lengths(4,counter) = dy;
            else if(cross(4,counter)==0)
                    lengths(4,counter) = 0;
            else if(y1 < y_c) 
                lengths(4,counter) = cross(4,counter)-y1;
            else
                lengths(4,counter) = y2 - cross(4,counter);
                end
                end
            end

            counter = counter + 1;
        end
    end
end

% fractional lengths array
frac_length = zeros(4, numofmarkedboxes + insidePEC);
frac_length(1:2,1:numofmarkedboxes+ insidePEC) = lengths(1:2,1:numofmarkedboxes+ insidePEC)/dx;
frac_length(3:4,1:numofmarkedboxes+ insidePEC) = lengths(3:4,1:numofmarkedboxes+ insidePEC)/dy;

% fractional area
Area = zeros(1, numofmarkedboxes+ insidePEC );
FA = zeros(1,numofmarkedboxes+ insidePEC); % Fractional areas
calculate_frac_area2;
FA = Area / (dx*dy);

counter = 1;
epx_mask = zeros(NX-1,NY);
muz_mask = zeros(NX-1,NY-1); % H-fields coming out of z-plane.
for i = 1:NX-1
    for j = 1:NY
        % use epx_mask and use the lower side fractional length
        if(mask(i,j) == 0 || mask(i,j) == -1)
            epx_mask(i,j) = frac_length(1, counter);
            if(j < NY)
                muz_mask(i,j) = FA(counter);
            end
            counter = counter + 1;
            else 
                epx_mask(i,j) = 1;
                if(j < NY)
                    muz_mask(i,j) = 1;
                end
            end
        end
end

% Here we copy the first side of the epx_mask and muz_mask to the second
% half. Use for testing different methods and their outcomes for now.
muz_mask2 = muz_mask;
for i = 1:NX-1
    for j =  1:((NY+1)/2)-1 %only for even NXYZ initial values.
        muz_mask2(i,NX-j) = muz_mask(i,j);
    end
end
