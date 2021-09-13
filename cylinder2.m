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



face_change = zeros(NX-1,NY-1);
numofmarkedboxes = 0;
% now to mark the actual boxes that must be changed
% NOTE: This implimentation will not work if cylinder center is on
% an actual grid point. It was not something considered here. 
mask = ones(5,6)*2;
for i = 1:NX-1
    for j = 1:NY-1
        
        % Is it inside PEC? -1
        if (face_index(i,j) <= 0 ...
                && face_index(i+1, j) <= 0 ...
                && face_index(i, j+1) <= 0 ...
                && face_index(i+1 , j+1) <= 0)
            face_change(i,j) = -1;
        
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



counter = 1;
cross = zeros(4, numofmarkedboxes);
lengths = zeros(4, numofmarkedboxes);
grid_lengths = zeros(4, numofmarkedboxes);
for i = 1:NX-1
    for j = 1:NY-1
        
        x1 = (i-1)*dx;
        x2 = i*dx;
        y1 = (j-1)*dy;
        y2 = j*dy;
        
        % If the grid block is inside the PEC we set 'cross' = 0.
        if(face_change(i,j) == -1)
            cross(1, counter) = 0;
            cross(2, counter) = 0;
        end
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
            if(cross(1, counter) > x2 ...
                    || cross(1, counter) < x1 ...
                    || imag(cross(1, counter))~=0) %isreal returns 0 if imaginary
                cross(1, counter) = -1;
            end
            
            if(cross(2, counter) > x2 ...
                    || cross(2, counter) < x1 ...
                    || imag(cross(2, counter))~=0) %isreal returns 0 if imaginary
                cross(2, counter) = -1;
            end
            
            if(cross(3, counter) > y2 ...
                    || cross(3, counter) < y1 ...
                    || imag(cross(3, counter))~=0) %isreal returns 0 if imaginary
                cross(3, counter) = -1;
            end
            
            if(cross(4, counter) > y2 ...
                    || cross(4, counter) < y1 ...
                    || imag(cross(4, counter))~=0) %isreal returns 0 if imaginary
                cross(4, counter) = -1;
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
            
            if(cross(4,counter)==-1) % right side of box
                lengths(4,counter) = dy;
            else if(cross(1,counter)==0)
                    lengths(1,counter) = 0;
            else if(y1 < y_c) 
                lengths(4,counter) = cross(4,counter)-y1;
            else
                lengths(4,counter) = y2 - cross(4,counter);
                end
            end

            counter = counter + 1;
        end
    end
end

% fractional lengths array
frac_length = zeros(4, numofmarkedboxes);
frac_length(1:2,1:numofmarkedboxes) = lengths(1:2,1:numofmarkedboxes)/dx;
frac_length(3:4,1:numofmarkedboxes) = lengths(3:4,1:numofmarkedboxes)/dy;

% fractional area
Area = zeros(1, numofmarkedboxes);
FA = zeros(1,numofmarkedboxes); % Fractional areas
calculate_frac_area2;
FA = Area / (dx*dy);

counter = 1;
epx_mask = zeros(5,6);
for i = 1:NX-1
    for j = 1:NY
        % use epx_mask and use the lower side fractional length
        if(mask(i,j) == 0)
            epx_mask(i,j) = frac_length(1, counter);
            counter = counter + 1;
        else if(mask(i,j) == -1)
                epx_mask(i,j) = 0;
            else 
                epx_mask(i,j) = 1;
            end
        end
    end
end