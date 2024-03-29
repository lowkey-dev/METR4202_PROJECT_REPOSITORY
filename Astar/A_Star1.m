function Optimal_path = A_Star1(start, target, obstructionMap)
% get required image
resize = 0.025;

xStart = start(1) * resize;
yStart = start(2) * resize;
xStart=round(xStart);%Starting Position
yStart=round(yStart);%Starting Position
if xStart == 0
    xStart = 1;
end
if yStart == 0
    yStart = 1;
end

xTarget = target(1) * resize;
yTarget = target(2) * resize;
xTarget=round(xTarget)%X Coordinate of the Target
yTarget=round(yTarget)%Y Coordinate of the Target
if xTarget == 0
    xTarget = 1;
end
if yTarget == 0
    yTarget = 1;
end

clear Optimal_path
% mapskies = flipud(obstructionMap);
mapskies = obstructionMap;
mapskies = imresize(mapskies, resize);
obstructionSize = size(mapskies);
%DEFINE THE 2-D MAP ARRAY
MAX_X = obstructionSize(2);
MAX_Y = obstructionSize(1); 

MAX_VAL=54;
%This array stores the coordinates of the map and the 
%Objects in each coordinate

% Process map.
% Obtain Obstacle, Target and Robot Position
% Initialize the MAP with input values
% Obstacle=-1,Target = 0,Robot=1,Space=2
MAP = 2 .* int8(mapskies);

% axis([1 MAX_X+1 1 MAX_Y+1])
% grid on 
% hold on

for i = 1:MAX_X
    for j = 1:MAX_Y
        if MAP(j,i) == 0;
%             plot(i, j, 'ro');
%             hold on;
            MAP(j,i) = -1;
        end
    end
end

j=0;
x_val = 1;
y_val = 1;

n=0;%Number of Obstacles



% BEGIN Interactive Obstacle, Target, Start Location selection

% h=msgbox('Please Select the Target using the Left Mouse button');
% uiwait(h,5);
% if ishandle(h) == 1
%     delete(h);
% end
% xlabel('Please Select the Target using the Left Mouse button','Color','black');
% but=0;
% % while (but ~= 1) %Repeat until the Left button is not clicked
% %     [xval,yval,but]=ginput(1);
% % end
% xval=floor(xval);
% yval=floor(yval);

MAP(yTarget,xTarget)=0;%Initialize MAP with location of the target
% plot(xTarget+.5,yTarget+.5,'gd');
% text(xTarget+1,yTarget+.5,'Target')

% h=msgbox('Select Obstacles using the Left Mouse button,to select the last obstacle use the Right button');
%   xlabel('Select Obstacles using the Left Mouse button,to select the last obstacle use the Right button','Color','blue');
% uiwait(h,10);
% if ishandle(h) == 1
%     delete(h);
% end
% while but == 1
%     [xval,yval,but] = ginput(1);
%     xval=floor(xval);
%     yval=floor(yval);
%     MAP(xval,yval)=-1;%Put on the closed list as well
%     plot(xval+.5,yval+.5,'ro');
%  end%End of While loop
%  

% h=msgbox('Please Select the Vehicle initial position using the Left Mouse button');
% uiwait(h,5);
% if ishandle(h) == 1
%     delete(h);
% end
% xlabel('Please Select the Vehicle initial position ','Color','black');
% but=0;
% while (but ~= 1) %Repeat until the Left button is not clicked
%     [xval,yval,but]=ginput(1);
%     xval=floor(xval);
%     yval=floor(yval);
% end
% xStart=xval;%Starting Position
% yStart=yval;%Starting Position
MAP(yStart,xStart)=1;
%  plot(xStart+.5,yStart+.5,'bo');
%End of obstacle-Target pickup


% FIRST CHECK STRAIGHT LINE PLAUSIBILITY 
x = [xStart xTarget];
y = [yStart yTarget];
theta = atan2(y(2)-y(1), x(2)-x(1));
angle = double(theta * (180/pi));
p = polyfit(x, y, 1);
i = 1;

if xTarget == xStart
    x = xStart;
    y = yStart;
    Optimal_path(1,1) = xStart;
    Optimal_path(1,2) = yStart;
    while y ~= yTarget
        if yTarget > yStart
            y = y + 1;
        else 
            y = y - 1;
        end
        if MAP(y,x) == 2 || MAP(y,x) == 0 || MAP(y,x) == 1
            Optimal_path(i,1) = xStart;
            Optimal_path(i,2) = y;
            i = i + 1;
        elseif MAP(y,x) == -1
            clear Optimal_path x y i 
            break 
        end
    end
else
    x = xStart;
    Optimal_path(1,1) = xStart;
    Optimal_path(1,2) = yStart;
    while x ~= xTarget
        if xTarget > xStart
            x = x + 1;
        else 
            x = x - 1;
        end
        y = x*p(1) + p(2);
        y = round(y);
        if MAP(y,x) == 2 || MAP(y,x) == 0 || MAP(y,x) == 1
            Optimal_path(i,1) = x;
            Optimal_path(i,2) = y;
            i = i + 1;
        elseif MAP(y,x) == -1
            clear Optimal_path x y i 
            break 
        end
    end
end
    
if exist('Optimal_path', 'var')
    Optimal_path = Optimal_path .* 40;
    Optimal_path = [[start(1) start(2)]; Optimal_path];
    Optimal_path = [Optimal_path; [target(1) target(2)]];
%     plot(Optimal_path(:,1), Optimal_path(:,2));
    
    disp('Straight line taken')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LISTS USED FOR ALGORITHM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OPEN LIST STRUCTURE
%--------------------------------------------------------------------------
%IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
%--------------------------------------------------------------------------
OPEN=[];
%CLOSED LIST STRUCTURE
%--------------
%X val | Y val |
%--------------
% CLOSED=zeros(MAX_VAL,2);
CLOSED=[];

%Put all obstacles on the Closed list
k=1;%Dummy counter
for i=1:MAX_X
    for j=1:MAX_Y
        if(MAP(j,i) == -1)
            CLOSED(k,1)=i; 
            CLOSED(k,2)=j; 
            k=k+1;
        end
    end
end
CLOSED_COUNT=size(CLOSED,1);
%set the starting node as the first node
xNode=xStart;
yNode=yStart;
OPEN_COUNT=1;
path_cost=0;
goal_distance=distance(xNode,yNode,xTarget,yTarget);
OPEN(OPEN_COUNT,:)=insert_open(xNode,yNode,xNode,yNode,path_cost,goal_distance,goal_distance);
OPEN(OPEN_COUNT,1)=0;
CLOSED_COUNT=CLOSED_COUNT+1;
CLOSED(CLOSED_COUNT,1)=xNode;
CLOSED(CLOSED_COUNT,2)=yNode;
NoPath=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START ALGORITHM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while((xNode ~= xTarget || yNode ~= yTarget) && NoPath == 1)
%  plot(xNode+.5,yNode+.5,'go');
 exp_array=expand_array(xNode,yNode,path_cost,xTarget,yTarget,CLOSED,MAX_X,MAX_Y);
 exp_count=size(exp_array,1);
 %UPDATE LIST OPEN WITH THE SUCCESSOR NODES
 %OPEN LIST FORMAT
 %--------------------------------------------------------------------------
 %IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
 %--------------------------------------------------------------------------
 %EXPANDED ARRAY FORMAT
 %--------------------------------
 %|X val |Y val ||h(n) |g(n)|f(n)|
 %--------------------------------
 for i=1:exp_count
    flag=0;
    for j=1:OPEN_COUNT
        if(exp_array(i,1) == OPEN(j,2) && exp_array(i,2) == OPEN(j,3) )
            OPEN(j,8)=min(OPEN(j,8),exp_array(i,5)); %#ok<*SAGROW>
            if OPEN(j,8)== exp_array(i,5)
                %UPDATE PARENTS,gn,hn
                OPEN(j,4)=xNode;
                OPEN(j,5)=yNode;
                OPEN(j,6)=exp_array(i,3);
                OPEN(j,7)=exp_array(i,4);
            end;%End of minimum fn check
            flag=1;
        end;%End of node check
%         if flag == 1
%             break;
    end;%End of j for
    if flag == 0
        OPEN_COUNT = OPEN_COUNT+1;
        OPEN(OPEN_COUNT,:)=insert_open(exp_array(i,1),exp_array(i,2),xNode,yNode,exp_array(i,3),exp_array(i,4),exp_array(i,5));
     end;%End of insert new element into the OPEN list
 end;%End of i for
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %END OF WHILE LOOP
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %Find out the node with the smallest fn 
  index_min_node = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget);
  if (index_min_node ~= -1)    
   %Set xNode and yNode to the node with minimum fn
   xNode=OPEN(index_min_node,2);
   yNode=OPEN(index_min_node,3);
   path_cost=OPEN(index_min_node,6);%Update the cost of reaching the parent node
  %Move the Node to list CLOSED
  CLOSED_COUNT=CLOSED_COUNT+1;
  CLOSED(CLOSED_COUNT,1)=xNode;
  CLOSED(CLOSED_COUNT,2)=yNode;
  OPEN(index_min_node,1)=0;
  else
      %No path exists to the Target!!
      NoPath=0;%Exits the loop!
  end;%End of index_min_node check
end;%End of While Loop
%Once algorithm has run The optimal path is generated by starting of at the
%last node(if it is the target node) and then identifying its parent node
%until it reaches the start node.This is the optimal path

i=size(CLOSED,1);
Optimal_path=[];
xval=CLOSED(i,1);
yval=CLOSED(i,2);
i=1;
Optimal_path(i,1)=xval;
Optimal_path(i,2)=yval;
i=i+1;

if ( (xval == xTarget) && (yval == yTarget))
    inode=0;
   %Traverse OPEN and determine the parent nodes
   parent_x=OPEN(node_index(OPEN,xval,yval),4);%node_index returns the index of the node
   parent_y=OPEN(node_index(OPEN,xval,yval),5);
   
   while( parent_x ~= xStart || parent_y ~= yStart)
           Optimal_path(i,1) = parent_x;
           Optimal_path(i,2) = parent_y;
           %Get the grandparents:-)
           inode=node_index(OPEN,parent_x,parent_y);
           parent_x=OPEN(inode,4);%node_index returns the index of the node
           parent_y=OPEN(inode,5);
           i=i+1;
   end
%  j=size(Optimal_path,1);
 
 



 
 %Plot the Optimal Path!
%  p=plot(Optimal_path(j,1)+.5,Optimal_path(j,2)+.5,'bo');
%  j=j-1;
%  for i=j:-1:1
% 
%  plot(Optimal_path(i,1)+.5,Optimal_path(i,2)+.5);
%  end;
%  plot(Optimal_path(:,1)+.5,Optimal_path(:,2)+.5);
% else
% 
%  h=msgbox('Sorry, No path exists to the Target!','warn');
%  uiwait(h,5);
% end

end


disp('getting here')
Optimal_path = Optimal_path .* 40;
Optimal_path = flipud(Optimal_path);
Optimal_path = [[start(1) start(2)]; Optimal_path];
Optimal_path = [Optimal_path; [target(1) target(2)]];

end






