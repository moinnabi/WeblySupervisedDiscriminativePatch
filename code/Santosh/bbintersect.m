function bb = bbintersect( bb1, bb2 )

n1=size(bb1,1); n2=size(bb2,1);
if(n1==0 || n2==0), bb=zeros(0,4); return, end
if(n1==1 && n2>1), bb1=repmat(bb1,n2,1); n1=n2; end
if(n2==1 && n1>1), bb2=repmat(bb2,n1,1); n2=n1; end
assert(n1==n2);
lcsE=min(bb1(:,1:2)+bb1(:,3:4),bb2(:,1:2)+bb2(:,3:4));
lcsS=max(bb1(:,1:2),bb2(:,1:2)); empty=any(lcsE<lcsS,2);
bb=[lcsS lcsE-lcsS]; bb(empty,:)=0;
end