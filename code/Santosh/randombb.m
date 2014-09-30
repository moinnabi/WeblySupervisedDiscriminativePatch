function bb = randombb( maxx, maxy, bbw, bbh, n )
% Uniformly generate n (integer) bbs that lie in [1 maxx]x[1 maxy].
%
% bbw either specifies a fixed width or a range of acceptable widths.
% Likewise bbh (for heights). A special case is bbh<0, in which case
% ar=-bbh, and the height of each generated bb is set so that w/h=ar.
%
% USAGE
%  bb = bbApply('random',maxx,maxy,bbw,bbh,n)
%
% INPUTS
%  maxx   - maximum right most bb location
%  maxy   - maximum bottom most bb location
%  bbw    - bb width, or range for bbw [min max]
%  bbh    - bb height, or range for bbh [min max]
%  n      - number of bbs to generate
%
% OUTPUTS
%  bb     - randomly generate bbs
%
% EXAMPLE
%  s=20; bb=bbApply('random',s,s,[1 s],5,10);
%  figure(1); clf; im(rand(s+1)); bbApply('draw',bb,'g');
%
% See also bbApply

if(all(bbh>0))
  [x w]=random1(n,maxx,bbw);
  [y h]=random1(n,maxy,bbh);
else
  ar=-bbh; bbw=min(bbw,maxy*ar); [x w]=random1(n,maxx,bbw);
  y=x; h=w/ar; for j=1:n, y(j)=random1(1,maxy,h(j)); end
end
bb=[x y w h];

  function [x w] = random1( n, maxx, rng )
    if( numel(rng)==1 )
      % simple case, generate 1<=x<=maxx-rng+1 and w=rng
      %x=randint2(n,1,[1,maxx-rng+1]); w=rng(ones(n,1));
      x=randint2(n,1,[1,maxx-rng+1]); w=rng(ones(n,1));
    else
      % generate random [x w] pairs until have n that fall in rng
      assert(rng(1)<=rng(2)); k=0; x=zeros(n,1); w=zeros(n,1);
      for i=0:10000
        t=1+floor(maxx*rand(n,2));
        x1=min(t(:,1),t(:,2)); w1=max(t(:,1),t(:,2))-x1+1;
        kp=(w1>=rng(1) & w1<=rng(2)); x1=x1(kp); w1=w1(kp);
        k1=length(x1); if(k1>n-k), k1=n-k; x1=x1(1:k1); w1=w1(1:k1); end
        x(k+1:k+k1,:)=x1; w(k+1:k+k1,:)=w1; k=k+k1; if(k==n), break; end
      end, assert(k==n);
    end
  end
end

function R = randint2( m, n, range )

R = rand( m, n );
R = range(1) + floor( (range(2)-range(1)+1)*R );
end
