clear all
[a,b,c]=xlsread('eurusd.xlsx');
close=a(:,4); 
targets=con2seq(close'); 

[a2,b2,c2]=xlsread('eurusd2.xlsx'); 
close2=a2(:,4); 
targets2=con2seq(close2'); 

resultsr=zeros(60,11); 
resultsr2=zeros(60,11); 
resultstog=zeros(60,11); 
resultstog2=zeros(60,11); 
resultsdel=zeros(60,11); 
resultsdel2=zeros(60,11); 



for i=10:10:100; 
    size=i 
    for j=1:10; 


delay=j;
net=narnet([1:delay],size); 

%train for orignal data
[p,pi,ai,t]=preparets(net,{},{},targets); 
[net,tr]=train(net,p,t,pi); 
output=net(p,pi); 
nntraintool('close');

%train for different data
% [p,pi,ai,t]=preparets(net,{},{},targets2); 
% [net,tr2]=train(net,p,t,pi);
% output2=net(p,pi); 
% nntraintool('close');

%output for different data
[p,pi,ai,t]=preparets(net,{},{},targets2); 
output2=net(p,pi); 
nntraintool('close');

%diagnostics for same data
tsOut = output(tr.testInd);
tsTarg = targets(tr.testInd);
whichstats={'rsquare'}; 
stats=regstats(cell2mat(tsOut),cell2mat(tsTarg),'linear',whichstats); 
r=stats.rsquare; 
resultsr(i/10,j)=r; 

%diagnostics for different data
tsOut = output2(tr.testInd);
tsTarg = targets2(tr.testInd);
whichstats={'rsquare'}; 
stats=regstats(cell2mat(tsOut),cell2mat(tsTarg),'linear',whichstats); 
r=stats.rsquare; 
resultsr2(i/10,j)=r; 

%convert targets to right size
targetmat=cell2mat(targets); 
targetmat=targetmat(1+delay:end); 

target2mat=cell2mat(targets2); 
target2mat=target2mat(1+delay:end); 

%test ups and downs
targetsdiff=diff(targetmat); 
outputdiff=diff(cell2mat(output)); 
numuptog=sum((targetsdiff>0).*(outputdiff>0)); 
numdowntog=sum((targetsdiff<0).*(outputdiff<0));
numtog=numuptog+numdowntog; 
resultstog(i/10,j)=numtog; 

targets2diff=diff(target2mat); 
output2diff=diff(cell2mat(output2)); 
numuptog2=sum((targets2diff>0).*(output2diff>0)); 
numdowntog2=sum((targets2diff<0).*(output2diff<0));
numtog2=numuptog2+numdowntog2; 
resultstog2(i/10,j)=numtog2; 
    end
end

%computing how good this thing is
resultstog=resultstog/500; 
resultstog2=resultstog2/500; 
max1=max(max(resultstog)); 
max2=max(max(resultstog2));

%regression on deltas
whichstats={'rsquare'}; 
stats=regstats(targetsdiff,outputdiff,'linear',whichstats); 
r=stats.rsquare; 
resultsdel(i/10,j)=r; 

whichstats={'rsquare'}; 
stats=regstats(targetsdiff,outputdiff,'linear',whichstats); 
r=stats.rsquare; 
resultsdel2(i/10,j)=r; 


