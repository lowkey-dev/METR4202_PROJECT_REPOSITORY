%Test2
abort(3);
%Sequence = [[120, 250, 0], [135, 220, 0], [145, 200, 0], [155, 180, 0],[170, 155, 0], [165, 130, 0], [160, 100, 0], [160, 80, 0]]; 

%Across middle
%Sequence = [[-100, 300, 0], [-73, 287, 0], [-44, 274, 0], [-17, 261, 0], [25, 241, 0], [50, 229, 0], [68, 221, 0]];
%Reverse
%ACTS WEIRD FROM POSITIVE TO NEGATIVE
%Sequence = [[68, 221, 0], [50, 229, 0], [30, 241, 0], [-17, 261, 0],[-44, 274, 0], [-73, 287, 0], [-100, 300, 0]];
%[10, 247,0]


%           check out the function getCoords(getCoords(190, 190, 125, portNumber)

Sequence = [[-100, 300, 0], [-90, 290, 0], [-80, 280, 0], [-70, 270, 0], [-60, 260, 0], [-50, 250, 0], [-40, 240, 0], [-30, 230, 0], [-20, 220, 0], [20, 210, 0], [30, 200, 0], [40, 190, 0], [50, 180, 0], [60, 170, 0], [70, 160, 0]]; 
DragDomino(3, [0, 451, 0], Sequence);