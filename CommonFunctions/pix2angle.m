function ang=pix2angle(display,n)
%ANGLE2PIX
%n=angle2pix(display,ang)
%returns width of square in pixels for visual angle ang

% n=round(2*display.distance*tan(ang*pi/360)/display.pixelSize);

ang=360*atan(display.pixelSize*(n)/(display.distance*2)/pi);
