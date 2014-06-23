clear all

%reading in data for training
%targets will not be placed in cells
[a,~,~]=xlsread('input/eurusd1000.xlsx');
% a=a(201:end,:); 
close=a(:,4); 
targets=con2seq(close'); 
vol=a(:,2); 
max=a(:,6); 
coninput=con2seq([vol'; max']); 

 

[a2,~,~]=xlsread('input/eurusd10002.xlsx'); 
% a2=a2(201:end,:); 
close2=a2(:,4); 
targets2=con2seq(close2');
vol2=a2(:,2); 
max2=a2(:,6);
coninput2=con2seq([vol2';max2']); 


%reading in data for generalization
[a3,~,~]=xlsread('input/eurusd10003.xlsx'); 
% a3=a3(201:end,:); 
close3=a3(:,4); 
targets3=con2seq(close3');
vol3=a3(:,2); 
max3=a3(:,6);
coninput3=con2seq([vol3';max3']); 

%reading in another data set, which will not be used for generalization
[a4,~,~]=xlsread('input/gbpusd1000.xlsx'); 
% a4=a4(201:end,:); 
close4=a4(:,4); 
targets4=con2seq(close4');
vol4=a4(:,2); 
max4=a4(:,6);
coninput4=con2seq([vol4';max4']); 

%cleaning up extras
clear vol max vol2 max2 vol3 max3 vol4 max4 close close2 close3 close4 a a2 a3 a4

%trial iterations----------------------------------------------------
iter=3; 
d=cell(iter,1); 
iresults=struct('r',{d},'mse',{d},'tog',{d},'del',{d},'diff',{d}); 
clear d

%defining constants
numnet=5; 
maxn=60; 
stepsizen=10; 
minn=50; 

maxd=60; 
stepsized=10; 
mind=10; 

for numiter=1:iter

%initializing results matrices
%last two rows of cells resultsr and resultsmse will remain emtpy because
%generalization data is not being collected for them



c=cell(numnet,1); 
resultsr=c;
resultsmse=c;
resultstog=c ;
resultsdel=c;
resultsdiff=c;
clear c
for n=1:numnet; 
    initial=zeros((maxn-minn)/stepsizen+1,(maxd-mind)/stepsized+1); 
    resultsr{n}=initial; 
    resultsmse{n}=initial;
    resultstog{n}=initial;
    resultsdel{n}=initial;
    resultsdiff{n}=initial; 
end



% testing loop definition
%this is specific to two hidden-layer nets

 
for i=minn:stepsizen:maxn; 
    size1=i
    for j=mind:stepsized:maxd; 


delay=j
net1=narxnet([1:delay],[1:delay],[size1]); 
net2=narxnet([1:delay],[1:delay],[size1]); 
net4=narxnet([1:delay],[1:delay],[size1]); 

%defining indices
numhid=(i-40)/10; 
numdelay=j/10; 



%define cells
%row 1, 2, and 5 are self-tests on data sets 1, 2, and 5; 3 is 13 and 4 is 23
output=cell(numnet,1); 
targetsdiff=cell(numnet,1);
outputdiff=cell(numnet,1); 


%train for data set 1
[p,pi,ai,t]=preparets(net1,coninput,{},targets); 
[net1,tr]=train(net1,p,t,pi); 
% net.trainParam.showWindow=0; 
nntraintool('close')
output{1}=net1(p,pi); 


%train for data set 2
[p,pi,ai,t]=preparets(net2,coninput2,{},targets2); 
[net2,tr2]=train(net2,p,t,pi);
output{2}=net2(p,pi); 
nntraintool('close');

%train for data set 3
[p,pi,ai,t]=preparets(net4,coninput4,{},targets4); 
[net4,tr4]=train(net4,p,t,pi);
output{5}=net4(p,pi); 
nntraintool('close');

%output for different data
[p,pi,ai,t]=preparets(net1,coninput3,{},targets3); 
output{3}=net1(p,pi); 

[p,pi,ai,t]=preparets(net2,coninput3,{},targets3); 
output{4}=net2(p,pi); 


%diagnostics for data set 1
tsOut = output{1}(tr.testInd);
tsTarg = targets(tr.testInd);
whichstats={'rsquare','mse'}; 
stats=regstats(cell2mat(tsOut),cell2mat(tsTarg),'linear',whichstats); 
resultsr{1}(numhid,numdelay)=stats.rsquare; 
resultsmse{1}(numhid,numdelay)=stats.mse; 


%diagnostics for data set 2
tsOut = output{2}(tr.testInd);
tsTarg = targets2(tr.testInd);
% whichstats={'rsquare'}; 
stats=regstats(cell2mat(tsOut),cell2mat(tsTarg),'linear',whichstats); 
resultsr{2}(numhid,numdelay)=stats.rsquare; 
resultsmse{2}(numhid,numdelay)=stats.mse;

%diagnostics for data set 3
tsOut = output{5}(tr.testInd);
tsTarg = targets4(tr.testInd);
% whichstats={'rsquare'}; 
stats=regstats(cell2mat(tsOut),cell2mat(tsTarg),'linear',whichstats); 
resultsr{5}(numhid,numdelay)=stats.rsquare; 
resultsmse{5}(numhid,numdelay)=stats.mse;

%convert targets to right size
targetmat=cell(numnet,1); 
targetmat{1}=cell2mat(targets); 
targetmat{1}=targetmat{1}(1+delay:end); 

targetmat{2}=cell2mat(targets2); 
targetmat{2}=targetmat{2}(1+delay:end); 

targetmat{3}=cell2mat(targets3); 
targetmat{3}=targetmat{3}(1+delay:end); 

targetmat{4}=targetmat{3}; 

targetmat{5}=cell2mat(targets4); 
targetmat{5}=targetmat{5}(1+delay:end); 

%test ups and downs
for n=1:numnet; 
    
targetsdiff{n}=diff(targetmat{n}); 
outputdiff{n}=diff(cell2mat(output{n})); 
numuptog=sum((targetsdiff{n}>0).*(outputdiff{n}>0)); 
numdowntog=sum((targetsdiff{n}<0).*(outputdiff{n}<0));
numtog=numuptog+numdowntog; 
resultstog{n}(numhid,numdelay)=numtog; 

end


%regression on deltas
for n=1:numnet; 
whichstats={'rsquare'}; 
stats=regstats(targetsdiff{n},outputdiff{n},'linear',whichstats); 
resultsdel{n}(numhid,numdelay)=stats.rsquare;
end

for n=1:numnet; 
    %ups only
    differ=(targetmat{n}(2:end)-cell2mat(output{n}(2:end))) ; 
differ=differ(logical((targetsdiff{n}>0).*(outputdiff{n}>0)));
differ=differ<.001; 
resultsdiff{n}(numhid,numdelay)=sum(differ); 

%downs only
differ=(targetmat{n}(2:end)-cell2mat(output{n}(2:end))) ; 
differ=differ(logical((targetsdiff{n}<0).*(outputdiff{n}<0)));
differ=differ<.001; 
resultsdiff{n}(numhid,numdelay)=resultsdiff{n}(numhid,numdelay)+sum(differ); 
end

    end
end


%computing how good this thing is
for n=1:numnet; 
    for k=1:numdelay; 
     resultstog{n}(:,k)=resultstog{n}(:,k)/(1000-k*10-1); 
     resultsdiff{n}(:,k)=resultsdiff{n}(:,k)/(1000-k*10-1); 
    end
end
%processing resultstog
% meandelay=cell(numcell,1); 
% meanlayersize=cell(numcell,1);
% for n=1:numcell; 
%     meandelay{n}=mean(resultstog{n}); 
%     meanlayersize{n}=mean(resultstog{n},2); 
% end

iresults.r{numiter}=resultsr;
iresults.mse{numiter}=resultsmse;
iresults.tog{numiter}=resultstog ;
iresults.del{numiter}=resultsdel;
iresults.diff{numiter}=resultsdiff; 
end

save('r6iresults','iresults')

%analysing data

%single layer network-------------------------------------------------


%initializing  cells
%column 1 is for average, 2 for std, 3 for max, 4 for min
c=cell(numnet,4); 
avresults=struct('r',{c},'mse',{c},'tog',{c},'del',{c},'diff',{c}); 
clear c

for n=1:numnet; 
    for m=1:4; 
   
   avresults.r{n,m}=initial;
    avresults.mse{n,m}=initial;
    avresults.tog{n,m}=initial ;
    avresults.del{n,m}=initial;
    avresults.diff{n,m}=initial; 
   
    end
end

%obtaining averaged results for each type of output

%all except average
sinitial=size(initial);
indx=sinitial(1)*sinitial(2); 
v=zeros(iter,indx); 
names=fieldnames(avresults); 

for a=1:numel(fieldnames(avresults)); 
for j=1:numnet; 
    for i=1:iter;
      for k=1:indx; 
          v(i,k)=iresults.(names{a}){i}{j}(k); %linearize matrix
      end
    end
    mx=max(v); 
    mn=min(v); 
    v=std(v);
    
      for k=1:indx;
        [x,y]=ind2sub([sinitial(1),sinitial(2)],k); 
        avresults.(names{a}){j,2}(x,y)=v(k); 
        avresults.(names{a}){j,3}(x,y)=mx(k);
        avresults.(names{a}){j,4}(x,y)=mn(k);
      end
end
end

for a=1:numel(fieldnames(avresults)); 
for j=1:numnet; 
    for i=1:iter; 
        avresults.(names{a}){j,1}=avresults.(names{a}){j,1}+iresults.(names{a}){i}{j,1}; 
    end
    avresults.(names{a}){j,1}= avresults.(names{a}){j,1}/iter; 
end
end

save('r6avresults','avresults')

