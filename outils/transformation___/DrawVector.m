function DrawVector(p0, p1, color)
%Arrowline 3-D vector plot.
%   vectarrow(p0,p1) plots a line vector with arrow pointing from point p0
%   to point p1. The function can plot both 2D and 3D vector with arrow
%   depending on the dimension of the input
%
%   Example:
%       3D vector
%       p0 = [1 2 3];   % Coordinate of the first point p0
%       p1 = [4 5 6];   % Coordinate of the second point p1
%       vectarrow(p0,p1)
%
%       2D vector
%       p0 = [1 2];     % Coordinate of the first point p0
%       p1 = [4 5];     % Coordinate of the second point p1
%       vectarrow(p0,p1)
%
%   See also Vectline

%   Rentian Xiong 4-18-05
%   $Revision: 1.0
  


  if max(size(p0))==3
      if max(size(p1))==3
          x0 = p0(1);
          y0 = p0(2);
          z0 = p0(3);
          x1 = p1(1);
          y1 = p1(2);
          z1 = p1(3);
          hold on;
          axis equal;
          plot3([x0;x1],[y0;y1],[z0;z1], color);   % Draw a line between p0 and p1
          plot3(p1(1),p1(2),p1(3), 'O k')  % Plot arrow head
          grid on
          xlabel('x')
          ylabel('y')
          zlabel('z')
          
      else
          error('p0 and p1 must have the same dimension')
      end
  elseif max(size(p0))==2
      if max(size(p1))==2
          x0 = p0(1);
          y0 = p0(2);
          x1 = p1(1);
          y1 = p1(2);
          hold on
          axis equal;
          plot([x0;x1],[y0;y1], color);   % Draw a line between p0 and p1
          plot3(p1(1),p1(2),p1(3), 'O')  % Plot arrow head
          grid on
          xlabel('x')
          ylabel('y')
           
         
      else
          error('p0 and p1 must have the same dimension')
      end
  else
      error('this function only accepts 2D or 3D vector')
  end