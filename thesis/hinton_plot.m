function hinton\_plot(W, scale, colour, type, equal)
%function hinton\_plot(W, scale, colour, type, equal)
% type 0 = variable size boxes (size relates to strength)
% type 1 = image (color intensity relates to strength)
% type 2 = equal size squares (color intensity relates to strength)
% type 3 = same as type 0 but with outerboarder showing maximum size of box

W(find(W<0))=0;

if (type==1)
  %draw as an image: strength indicated by pixel darkness
  
  %W is true data value (greater than 0) and is scaled to be between 0 and 255
  imagesc(uint8(round((W./scale)*255)),[0,255]);%,'CDataMapping','scaled'),
  colormap(gray)
  map=colormap;
  map=flipud(map);
  map(1:64,colour)=map(1:64,colour)*0.0+1;
  colormap(map)
  axis on
  if(equal==1), axis equal, end
  if(equal==1), axis tight, end
  
elseif (type==0 | type==3)
  %draw as squares: strength indicated by size of square

  colstr=['r','g','b'];
  if(equal==0)
	%calc aspect ratio - if not going to set axis equal
	plot(size(W,2)+0.5,size(W,1)-0.5,'bx');
	hold on 
	plot(0.5,-0.5,'bx');
	axis equal
	a=axis;
	aspectX=size(W,2)/abs(a(2)-a(1));
	aspectY=size(W,1)/abs(a(4)-a(3));
	aspectXX=aspectX./max(aspectX,aspectY);
	aspectYY=aspectY./max(aspectX,aspectY);
	hold off
  else
	aspectXX=1;
	aspectYY=1;
  end
  for i=1:size(W,2)
	for j=1:size(W,1)
	  box\_widthX=aspectXX*0.5*W(j,i)/(scale);
	  box\_widthY=aspectYY*0.5*W(j,i)/(scale);
	  h=fill([i-box\_widthX,i+box\_widthX,i+box\_widthX,i-box\_widthX],size(W,1)+1-[j-box\_widthY,j-box\_widthY,j+box\_widthY,j+box\_widthY],colstr(colour));
	  hold on
	  if (isnan(W(j,i)))
		plot(i,size(W,1)+1-j,'kx','MarkerSize',20);
	  end
	  
	  if (type==3)
		set(h, 'EdgeColor','w');
		box\_widthX=aspectXX*0.5*1;
		box\_widthY=aspectYY*0.5*1;
		h=fill([i-box\_widthX,i+box\_widthX,i+box\_widthX,i-box\_widthX],size(W,1)+1-[j-box\_widthY,j-box\_widthY,j+box\_widthY,j+box\_widthY],'w','FaceAlpha',0);
	  end
	  
	end
  end
  %axis off
  %axis tight

  if(equal==1), axis equal, end
  axis([0.5,size(W,2)+0.5,+0.5,size(W,1)+0.5])

else
  %draw as equal sized squares: strength indicated by darkness of square

  if(equal==0)
	%calc aspect ratio - if not going to set axis equal
	plot(size(W,2)+0.5,size(W,1)-0.5,'bx');
	hold on 
	plot(0.5,-0.5,'bx');
	axis equal
	a=axis;
	aspectX=size(W,2)/abs(a(2)-a(1));
	aspectY=size(W,1)/abs(a(4)-a(3));
	aspectXX=aspectX./max(aspectX,aspectY);
	aspectYY=aspectY./max(aspectX,aspectY);
	hold off
  else
	aspectXX=1;
	aspectYY=1;
  end
  box\_widthX=aspectXX*0.33;
  box\_widthY=aspectYY*0.33;
  for i=1:size(W,2)
	for j=1:size(W,1)
	  fill([i-box\_widthX,i+box\_widthX,i+box\_widthX,i-box\_widthX],size(W,1)+1-[j-box\_widthY,j-box\_widthY,j+box\_widthY,j+box\_widthY],ones(1,4).*round((W(j,i)./scale)*255),'FaceColor','flat');
	  hold on
	end
  end
  colormap(gray)
  map=colormap;
  map=flipud(map);
  map(1:64,colour)=map(1:64,colour)*0.0+1;
  colormap(map)
  caxis([0,255])%if we remove this then each subplot is scaled independently
  %axis off
  %axis tight

  if(equal==1), axis equal, end
  axis([0.5,size(W,2)+0.5,+0.5,size(W,1)+0.5])
  
end
%set(gca,'YTickLabel',[' ';' ';' ';' ';' ';' ';' '])
%set(gca,'XTickLabel',[' ';' ';' ';' ';' ';' ';' '])
set(gca,'YTick',[])
set(gca,'XTick',[])
drawnow
