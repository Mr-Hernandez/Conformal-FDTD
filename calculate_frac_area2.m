% Calculating the Fractional Areas

hit = zeros(1,numofmarkedboxes); % tally used for 5 node boxes
m = zeros(1,numofmarkedboxes); % tallies nodes for each box.
nodes = zeros(2, 5, numofmarkedboxes);

box_n = 1;
for i = 1:NX-1
    for j = 1:NY-1
        
         % Does this box need a fractional area found?
         if(face_change(i,j) == 0)
                          
             %Is the first node of the box outside PEC?
             if (face_index(i,j) == 1)
                 m(box_n) = m(box_n) + 1;     
                 nodes(1, m(box_n), box_n) = (i-1)*dx;
                 nodes(2, m(box_n), box_n) = (j-1)*dy;
             else
                 hit(box_n) = 1;
             end
             
             %Now check if lx bottom intersection exists.
             if(cross(1, box_n) ~= -1)
                 m(box_n) = m(box_n) + 1;
                 nodes(1, m(box_n), box_n) = cross(1, box_n);
                 nodes(2, m(box_n), box_n) = (j-1)*dy;             
             end
             
             
              %Is the bottomright node of the box outside PEC?
             if (face_index(i+1,j) == 1)
                 m(box_n) = m(box_n) + 1;
                 nodes(1, m(box_n), box_n) = (i)*dx;
                 nodes(2, m(box_n), box_n) = (j-1)*dy;  
             else
                 hit(box_n) = 2; 
             end
             
              %Now check if ly right intersection exists.
             if(cross(4, box_n) ~= -1)
                 m(box_n) = m(box_n) + 1;
                 nodes(1, m(box_n), box_n) = (i)*dx;
                 nodes(2, m(box_n), box_n) = cross(4, box_n); 
             end
             
             %Is the topright node of the box outside PEC?
             if (face_index(i+1,j+1) == 1)
                 m(box_n) = m(box_n) + 1; 
                 nodes(1, m(box_n), box_n) = (i)*dx;
                 nodes(2, m(box_n), box_n) = (j)*dy;     
             else
                 hit(box_n) = 3; 
             end
             
             %Now check if lx top intersection exists.
             if(cross(2, box_n) ~= -1)
                 m(box_n) = m(box_n) + 1;
                 nodes(1, m(box_n), box_n) = cross(2, box_n);
                 nodes(2, m(box_n), box_n) = (j)*dy;                 
             end
             
             %Is the topleft node of the box outside PEC?
             if (face_index(i, j+1) == 1)
                 m(box_n) = m(box_n) + 1; 
                 nodes(1, m(box_n), box_n) = (i-1)*dx;
                 nodes(2, m(box_n), box_n) = (j)*dy; 
             else
                 hit(box_n) = 4; 
             end
             
             %Now check if ly left intersection exists.
             if(cross(3, box_n) ~= -1)
                 m(box_n) = m(box_n) + 1;
                 nodes(1, m(box_n), box_n) = (i-1)*dx;
                 nodes(2, m(box_n), box_n) = cross(3, box_n);
             end
             
             box_n = box_n + 1;
         end
    end
end
 
 %node difference function.
 diff = @(a, b) abs(sqrt((b(1)-a(1))^2 + (b(2)-a(2))^2));
 ss = @(a,b,c) (diff(a,b)+diff(b,c)+diff(c,a))/2;
%  aa = diff(nodes(1:2,1,box_n), nodes(1:2,2,box_n));
%  bb = diff(nodes(1:2,2,box_n), nodes(1:2,3,box_n));
%  cc = diff(nodes(1:2,3,box_n), nodes(1:2,1,box_n));
 tri_area = @(a, b, c) sqrt((ss(a,b,c)*(ss(a,b,c)-diff(a,b)) ...
     *(ss(a,b,c)-diff(b,c))*(ss(a,b,c)-diff(c,a))));
 % node(first coord:2ndcoord, node index for 1 box, box number)
 % diff(nodes(1:2,3,1), nodes(1:2,4,1)) %
 
 % Here we use the number of nodes on or outside the circle to determine
 % which method to use to approximate the area in the circle.
 % 3 nodes: Approximate using a triangle
 % 4 nodes: Approximate using a rectangle
 % 5 nodes: Approximate using 3 triangles
 for box_n = 1:numofmarkedboxes
     switch m(box_n)
         case 3
             disp('c');
%              aa = diff(nodes(1:2,1,box_n), nodes(1:2,2,box_n));
%              bb = diff(nodes(1:2,2,box_n), nodes(1:2,3,box_n));
%              cc = diff(nodes(1:2,3,box_n), nodes(1:2,1,box_n));
%              ss = (aa+bb+cc)/2;
%              Area(box_n) = sqrt(ss*(ss-aa)*(ss-bb)*(ss-cc));
               Area(box_n) = tri_area(nodes(1:2,1,box_n), nodes(1:2,2,box_n), ...
                   nodes(1:2,3,box_n));
         case 4
             disp('c2');
             aa = diff(nodes(1:2,1,box_n), nodes(1:2,2,box_n));
             bb = diff(nodes(1:2,2,box_n), nodes(1:2,3,box_n));
             Area(box_n) = aa*bb;
         case 5
             switch hit(box_n)
                 case 1
                     Area(box_n) = tri_area(nodes(1:2,1,box_n), nodes(1:2,2,box_n), ...
                                   nodes(1:2,3,box_n)) ...
                     + tri_area(nodes(1:2,1,box_n), nodes(1:2,3,box_n), ...
                                   nodes(1:2,5,box_n)) ...
                     + tri_area(nodes(1:2,3,box_n), nodes(1:2,4,box_n), ...
                                   nodes(1:2,5,box_n));
                    
                 case 2
                     Area(box_n) = tri_area(nodes(1:2,1,box_n), nodes(1:2,2,box_n), ... 
                                   nodes(1:2,5,box_n)) ...
                     + tri_area(nodes(1:2,2,box_n), nodes(1:2,3,box_n), ...
                                   nodes(1:2,5,box_n)) ...
                     + tri_area(nodes(1:2,3,box_n), nodes(1:2,4,box_n), ...
                                   nodes(1:2,5,box_n));
                               
                 case 3
                     Area(box_n) = tri_area(nodes(1:2,1,box_n), nodes(1:2,2,box_n), ...
                                   nodes(1:2,3,box_n)) ...
                     + tri_area(nodes(1:2,1,box_n), nodes(1:2,3,box_n), ...
                                   nodes(1:2,4,box_n)) ...
                     + tri_area(nodes(1:2,1,box_n), nodes(1:2,4,box_n), ...
                                   nodes(1:2,5,box_n));
                 case 4
                     Area(box_n) = tri_area(nodes(1:2,1,box_n), nodes(1:2,2,box_n), ...
                                   nodes(1:2,5,box_n)) ...
                     + tri_area(nodes(1:2,2,box_n), nodes(1:2,4,box_n), ...
                                   nodes(1:2,5,box_n)) ...
                     + tri_area(nodes(1:2,2,box_n), nodes(1:2,3,box_n), ...
                                   nodes(1:2,4,box_n));
             end
     end
             

 end
 
          