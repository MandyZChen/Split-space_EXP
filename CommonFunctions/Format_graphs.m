function Format_graphs
h_a=gca;
h_f=gcf;
h1=h_a(1);
h1_f=h_f(1);
set(h1,'FontSize',12);
% set(h1,'FontWeight',['bold']);
% axis equal
% xlim([0,16]);
% set(h1,'LineWidth',[3]);

%set(findobj(h1_f,'BackgroundColor','uicontrol'),[1,1,1]);
 set(h1_f,{'Color'},{[1,1,1]});
 set(h1,'Box','on');
% set(h1,'xticklabel',{'1','2','3','4','5','6','7','8','9'});
%  xlabel('Duration(seconds)','FontSize',24);
% ylabel('Probability density','FontSize',24);
% 
% g=text(1.7,0.45,'N=2352','FontSize',20);
% set(g,'FontWeight','bold');
% g1=text(1.7,0.45,'a=2.01, b=0.48','FontSize',20);
% set(g1,'FontWeight','bold');
% g2=text(1.7,0.42,'R squared= 0.98','FontSize',20);
% set(g2,'FontWeight','bold');
% g2=text(1.7,0.42,'Mean= 1698','FontSize',20);
% set(g2,'FontWeight','bold');
% g2=text(1.7,0.42,'Std= 790','FontSize',20);
% set(g2,'FontWeight','bold');

end

% binwidth=0.125;
% xRange=3.25;
% [hout,xx] = hist(Duration_all_clean,0:binwidth:xRange);
% yy=hout/(binwidth*sum(hout));
% 
% yresid = yy' - evaluateresults(:,2);
% SSresid = sum(yresid.^2);
% SStotal = (length(yy)-1) * var(yy);
% rsq = 1 - SSresid/SStotal