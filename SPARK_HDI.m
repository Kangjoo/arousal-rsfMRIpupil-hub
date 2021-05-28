function [HDI]=SPARK_HDI(high_rs_data,low_rs_data)
% Compute Hub Disruption Index (HDI) for k-hubness 
%
% SYNTAX:
% [HDI] = SPARK_HDI(high_rs_data,low_rs_data)
% 
% _________________________________________________________________________
% INPUTS
%
%   high_rs_data
%      (array) a (subjects x space) k-hubness matrix.
%   low_rs_data
%      (array) a (subjects x space) k-hubness matrix.
%
% OUTPUTS
%
%   HDI
%      (scalar value) a hub disruption index
%




% group average k-hubness
high_rs_data_grp  =  mean(high_rs_data);
low_rs_data_grp   =  mean(low_rs_data);


% assign color-codes for 11 pre-defined large-scale networks
load(['11network_definition_shen268.mat'],'whole_net')
tag{1}='MF';  % 1 MF, medial frontal
tag{2}='FP'; % 2 FP, frontoparietal
tag{3}='DMN'; % 3 DMN, default mode
tag{4}='Mot'; % 4 Mot, Motor
tag{5}='VI'; % 5 VI, visual I
tag{6}='VII'; % 6 VII, visual II
tag{7}='VAs'; % 7 VAs, visual association
tag{8}='Lim'; % 8 Lim, limbic
tag{9}='BG'; % 9 BG, basal ganglia (including thalamus and striatum)
tag{10}='CBL';% 10 CBL, cerebellum
tag{11}='BS'; % manual. brainstem,
hFig = figure(1);
c3=[255 0 0; ...
    255 210 82; ...
    255 255 0; ...
    0 255 0; ...
    0 0 255; ...
    205 172 230; ...
    0 255 255; ...
    124 104 39; ...
    255 121 43; ...
    112 17 93; ...
    255 0 255];
c3=c3./255;




% Draw a scatter plot and find parameters of linear regression model
x_axis_data=high_rs_data_grp;
y_axis_data=low_rs_data_grp - high_rs_data_grp;
xtag='high';
ytag='low - high';
figure
scatter(x_axis_data,y_axis_data)
h=lsline;
Gkappa = polyfit(x_axis_data,y_axis_data,1);
x=get(h,'xdata'); 
x=linspace(x(1),x(2),100);
close; clear h



% Display
hFig=gscatter(x_axis_data,y_axis_data,whole_net,c3,'o',8);
for y=1:11
    hFig(y).MarkerFaceColor=c3(y,:);
    hFig(y).MarkerEdgeColor=[0 0 0];
end
hold on
y=x*Gkappa(1) + Gkappa(2);
h=plot(x,y,'k'),set(h,'LineWidth',3);
axis([0 2 -2 2]) 
box off
set(gcf, 'Position',  [100, 100, 530, 500])
set(gca,'TickDir','out','LineWidth',2);
xlabel([xtag ', group k-hubness']); ylabel([ytag ', group k-hubness']);
title(['HDI=' num2str(Gkappa(1))])
legend('hide')
% saveas(gcf,outfilen,'jpg');
close; clear hFig




HDI=Gkappa(1);

