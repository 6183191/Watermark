[C1,BC1] = hist(bd);
[C2,~] = hist(crd);
Cdiff = C1-C2; %This may need to be abs unless you know one will be greater every time
bar(BC1,Cdiff)
