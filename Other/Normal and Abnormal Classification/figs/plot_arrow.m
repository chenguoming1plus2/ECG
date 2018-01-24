function plot_arrow(Xdata,Ydata, str)
%Xdata = [2 5]; %The x range of the arrow
%Ydata = [1 4];  % y range of the arrow
 pos = get(gca, 'Position') ;% [0.1300, 0.1100, 0.7750, 0.8150] (default)
 x_normalized = (Xdata - min(xlim))/diff(xlim) * pos(3) + pos(1);
 y_normalized =  (Ydata - min(ylim))/diff(ylim) * pos(4) + pos(2);
    
 annotation('doublearrow', x_normalized, y_normalized);
 width = 0.1;
 height = 0.1;
 dim = [sum(x_normalized)/2-width/3 sum(y_normalized)/2-height/3 width height];
 hold on
 annotation('textbox', dim, 'String',str,'FitBoxToText','on','LineStyle','none', 'FontSize',14);
end