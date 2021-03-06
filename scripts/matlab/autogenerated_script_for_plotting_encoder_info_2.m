function createfigure(X1, Y1, X2, Y2, X3, YMatrix1, Y3, Y4, YMatrix2, Y5, Y6, YMatrix3)
%CREATEFIGURE(X1, Y1, X2, Y2, X3, YMATRIX1, Y3, Y4, YMATRIX2, Y5, Y6, YMATRIX3)
%  X1:  vector of x data
%  Y1:  vector of y data
%  X2:  vector of x data
%  Y2:  vector of y data
%  X3:  vector of x data
%  YMATRIX1:  matrix of y data
%  Y3:  vector of y data
%  Y4:  vector of y data
%  YMATRIX2:  matrix of y data
%  Y5:  vector of y data
%  Y6:  vector of y data
%  YMATRIX3:  matrix of y data

%  Auto-generated by MATLAB on 04-Feb-2020 11:31:14

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.118827157182458 0.742170147019577 0.58 0.22]);
hold(axes1,'on');

% Create plot
plot(X1,Y1,'Parent',axes1,'Color',[0 0 0]);

% Create plot
plot(X2,Y2,'Parent',axes1,'LineStyle','--','Color',[0 0 0]);

% Create multiple lines using matrix input to plot
plot1 = plot(X3,YMatrix1,'Parent',axes1,'Color',[0 0 0]);
set(plot1(1),'LineStyle','-.');
set(plot1(2),'Marker','*');
set(plot1(3),'Marker','square');

% Create ylabel
ylabel('LE');

% Create title
title('Logic Cell Utilization');

%% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[0 16]);
% Set the remaining axes properties
set(axes1,'XTick',[0 2 4 6 8 10 12 14 16]);
% Create axes
axes2 = axes('Parent',figure1,...
    'Position',[0.121141971997273 0.411793457508821 0.58 0.22]);
hold(axes2,'on');

% Create plot
plot(X1,Y3,'Parent',axes2,'DisplayName','m = 4','Color',[0 0 0]);

% Create plot
plot(X2,Y4,'Parent',axes2,'DisplayName','m = 5','LineStyle','--',...
    'Color',[0 0 0]);

% Create multiple lines using matrix input to plot
plot2 = plot(X3,YMatrix2,'Parent',axes2,'Color',[0 0 0]);
set(plot2(1),'DisplayName','m = 6','LineStyle','-.');
set(plot2(2),'DisplayName','m = 7','Marker','*');
set(plot2(3),'DisplayName','m = 8','Marker','square');

% Create ylabel
ylabel('RE');

% Create title
title('Register Utilization');

%% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes2,[0 16]);
% Set the remaining axes properties
set(axes2,'XTick',[0 2 4 6 8 10 12 14 16]);
% Create legend
legend1 = legend(axes2,'show');
set(legend1,...
    'Position',[0.750400131062408 0.0665353031381508 0.201388886750296 0.134111946052788],...
    'FontName','Arial');

% Create axes
axes3 = axes('Parent',figure1,...
    'Position',[0.141975305330606 0.0663106796116506 0.58 0.22]);
hold(axes3,'on');

% Create plot
plot(X1,Y5,'Parent',axes3,'Color',[0 0 0]);

% Create plot
plot(X2,Y6,'Parent',axes3,'LineStyle','--','Color',[0 0 0]);

% Create multiple lines using matrix input to plot
plot3 = plot(X3,YMatrix3,'Parent',axes3,'Color',[0 0 0]);
set(plot3(1),'LineStyle','-.');
set(plot3(2),'Marker','*');
set(plot3(3),'Marker','square');

% Create ylabel
ylabel('F_{max} (kHz)');

% Create title
title(' Maximum clock frequency');

%% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes3,[0 16]);
% Set the remaining axes properties
set(axes3,'XTick',[0 2 4 6 8 10 12 14 16]);
% Create textbox
annotation(figure1,'textbox',...
    [0.400327801827795 -0.000485597222892393 0.0648148135730514 0.0404530737102996],...
    'String',{'c'},...
    'FontName','Arial',...
    'FontAngle','italic',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.379494468494465 0.675889807307851 0.0671296283188794 0.0404530737102996],...
    'String',{'a'},...
    'FontName','Arial',...
    'FontAngle','italic',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.384124098124092 0.33770210504248 0.0671296283188794 0.0404530737102997],...
    'String',{'b'},...
    'FontName','Arial',...
    'FontAngle','italic',...
    'EdgeColor','none');

