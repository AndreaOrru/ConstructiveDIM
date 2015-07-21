function maxsubplot(rows,cols,i)
%Create subplots that are much larger than that produced by the standard subplot command,
%Good for plots with no axis labels, tick labels or titles.

%*NOTE*, unlike subplot new axes are drawn on top of old ones; use clf first
%if you don't want this to happen.

%*NOTE*, unlike subplot the first axes are drawn at the bottom-left of the
%window.

%axes('Position',[fix((i-1)/rows)/cols,rem(i-1,rows)/rows,0.95/cols,0.95/rows]); 
axes('Position',[0.025/cols+rem(i-1,cols)/cols,0.025/rows+fix((i-1)/cols)/rows,0.95/cols,0.95/rows]); 

%  axis('equal','tight'); set(gca,'XTick',[],'YTick',[]); colormap('gray');
