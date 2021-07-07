clear
close all
clc

fileId1 = fopen('filename','w'); %open file for writing; discard existing contents
fprintf(fileId1,'# vtk DataFile Version 2.0 \n');
fprintf(fileId1,'Unstructured Grid - canitlever_beam_3d_pointload \n');

%read data
etable = dlmread('element_table.txt');% get the element-nodes connectivity
result_table= dlmread('result_table.txt'); 
element_type = fgets(fopen('element_type.txt'));
element_type = str2num(element_type(9:end));

%convert it to array
U_star = result_table(:,5);
nodal_coordinates = result_table(:,[2 3 4]);
etable = int64((etable));

etable(:,all(etable == 0))=[]; % remove all the zero columns
etable=etable-1; % because the indexing in paraview starts from 0 not from 1
etable_vtk = etable ;
nodes_per_element = length(etable(1,:))-1 ;
etable_vtk(:,1) = nodes_per_element; % insert the number of nodes for element in the first column

if  element_type == 181 
    cell_type = 9;
elseif element_type == 182 
    cell_type = 9;
elseif element_type == 185
    cell_type = 12;
elseif element_type == 186
    cell_type = 25;
elseif element_type == 187
    cell_type = 24;    
end
%%
fprintf(fileId1,'ASCII \n');
fprintf(fileId1,'DATASET UNSTRUCTURED_GRID \n');
% Define points - nodal coordinates
fprintf(fileId1,'\nPOINTS %d float \n', length(nodal_coordinates(:,1)));
for i =1 :length(nodal_coordinates(:,1))
    fprintf(fileId1,'%d ',nodal_coordinates(i,:));
    fprintf(fileId1,'\n ');
end
% define cells - elements
fprintf(fileId1,'\nCELLS %d %d \n', length(etable(:,1)), size(etable,1)*size(etable,2));

for i =1 :length(etable_vtk(:,1))
    fprintf(fileId1, '%d ', etable_vtk(i,:));   % order is changed because of the format
    fprintf(fileId1,'\n ');
end
%%
% define cell data - element type
fprintf(fileId1,'\nCELL_TYPES %d \n',length(etable(:,1)));
for i =1 :length(etable(:,1))
    fprintf(fileId1,'%d \n', cell_type );
end
% define scalar data - U* data
fprintf(fileId1,'POINT_DATA %d \n',length(U_star(:,1)));
fprintf(fileId1,'SCALARS U_star float 1 \n');
fprintf(fileId1,'LOOKUP_TABLE default \n');
for i= 1:length(U_star(:,1))
    fprintf(fileId1,'%d \n', U_star(i) );
end

figure
plot3(nodal_coordinates(:,1),nodal_coordinates(:,2),nodal_coordinates(:,3),'*')
hold on
% text(nlist(:,2),nlist(:,3),nlist(:,4),string(nlist(:,1)))
axis equal