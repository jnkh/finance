%single layer network-------------------------------------------------
clear all

load('r4iresultstog.mat')
load('r4iresultsmse.mat')
load('r4iresultsdel.mat')
load('r4iresultstog.mat')
load('r4iresultsdiff.mat')
load('r4iresultsr.mat')


sizem=10; 
numnet=5; 

numcell=5; 

%initializing  cells
%column 1 is for average, 2 for std, 3 for max, 4 for min
c=cell(numcell,4); 
r4avresultsr=c;
r4avresultsmse=c;
r4avresultstog=c ;
r4avresultsdel=c;
r4avresultsdiff=c; 

clear c

for n=1:numcell; 
    for m=1:4; 
    initial=zeros(7,6); 
   r4avresultsr{n,m}=initial;
    r4avresultsmse{n,m}=initial;
    r4avresultstog{n,m}=initial ;
    r4avresultsdel{n,m}=initial;
    r4avresultsdiff{n,m}=initial; 
   
    end
end

%obtaining averaged results for each type of output
sinitial=size(initial);
indx=sinitial(1)*sinitial(2); 
v=zeros(sizem,indx); 
for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsr{i}{j}(k); %linearize matrix
      end
    end
    mx=max(v); 
    mn=min(v); 
    v=std(v);
    
      for k=1:indx;
        [x,y]=ind2sub([sinitial(1),sinitial(2)],k); 
        r4avresultsr{j,2}(x,y)=v(k); 
        r4avresultsr{j,3}(x,y)=mx(k);
        r4avresultsr{j,4}(x,y)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsmse{i}{j}(k); %linearize matrix
      end
    end
    mx=max(v); 
    mn=min(v); 
    v=std(v); 
      for k=1:indx;
        [x,y]=ind2sub([sinitial(1),sinitial(2)],k); 
        r4avresultsmse{j,2}(x,y)=v(k); 
        r4avresultsmse{j,3}(x,y)=mx(k);
        r4avresultsmse{j,4}(x,y)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultstog{i}{j}(k); %linearize matrix
      end
    end
     mx=max(v); 
    mn=min(v); 
    v=std(v);
      for k=1:indx;
        [x,y]=ind2sub([sinitial(1),sinitial(2)],k); 
        r4avresultstog{j,2}(x,y)=v(k); 
        r4avresultstog{j,3}(x,y)=mx(k);
        r4avresultstog{j,4}(x,y)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsdel{i}{j}(k); %linearize matrix
      end
    end
     mx=max(v); 
    mn=min(v); 
    v=std(v);
      for k=1:indx;
        [x,y]=ind2sub([sinitial(1),sinitial(2)],k); 
        r4avresultsdel{j,2}(x,y)=v(k); 
        r4avresultsdel{j,3}(x,y)=mx(k);
        r4avresultsdel{j,4}(x,y)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsdiff{i}{j}(k); %linearize matrix
      end
    end
     mx=max(v); 
    mn=min(v); 
    v=std(v); 
      for k=1:indx;
        [x,y]=ind2sub([sinitial(1),sinitial(2)],k); 
        r4avresultsdiff{j,2}(x,y)=v(k); 
        r4avresultsdiff{j,3}(x,y)=mx(k);
        r4avresultsdiff{j,4}(x,y)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsr{j,1}=r4avresultsr{j,1}+iresultsr{i}{j,1}; 
    end
    r4avresultsr{j,1}= r4avresultsr{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsmse{j,1}=r4avresultsmse{j,1}+iresultsmse{i}{j,1}; 
    end
    r4avresultsmse{j,1}= r4avresultsmse{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultstog{j,1}=r4avresultstog{j,1}+iresultstog{i}{j,1}; 
    end
    r4avresultstog{j,1}= r4avresultstog{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsdel{j,1}=r4avresultsdel{j,1}+iresultsdel{i}{j,1}; 
    end
    r4avresultsdel{j,1}= r4avresultsdel{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsdiff{j,1}=r4avresultsdiff{j,1}+iresultsdel{i}{j,1}; 
    end
    r4avresultsdiff{j,1}= r4avresultsdiff{j,1}/sizem; 
end

save('r4avresultsr','r4avresultsr')
save('r4avresultsmse','r4avresultsmse')
save('r4avresultstog','r4avresultstog')
save('r4avresultsdel','r4avresultsdel')
save('r4avresultsdiff','r4avresultsdiff')