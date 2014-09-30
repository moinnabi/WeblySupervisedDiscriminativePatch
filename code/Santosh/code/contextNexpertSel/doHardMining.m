function model = doHardMining(Y,X,numNegIts,optionString)

try

if nargin < 4
    optionString = '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500';
end

% init
allP = find(Y==1);
allN = find(Y==-1);
disp(['  numpos is ' num2str(length(allP)) ' and numneg (total) is ' num2str(length(allN))]);
if numel(allN) < 50000, disp('too few samples; overkill of hardmining!'); keyboard; end

% set params
negSize = max(numel(allP)*10, 50000); % 10X more negs than pos, too many negs may bias learning?!
svSize = round(negSize/2);
stepS = round(numel(allN)/100);
disp(['  negSize (per it) will be ' num2str(negSize) ' and stepS will be ' num2str(stepS)]);

% 0. sample all pos, random negs 
P = allP;
N = allN(randperm(length(allN), min(negSize,length(allN))));

oldj = 1;
for ineg=1:numNegIts
    disp([' Doing iteration ' num2str(ineg) '/' num2str(numNegIts)]);
    
    % 1. train classifier
    disp('  train');
    D = [P; N];
    model = svmtrain(Y(D,:), X(D,:), optionString);
    if 1 %ineg>1   % store svs
        disp('  caching svs');
        [~, ~, s] = svmpredict(ones(size(N,1), 1), X(N,:), model);
        s = model.Label(1)*s;        
        [sval, sind] = sort(s, 'descend');
        neg_sv = numel(find(s>=-1.05));
        disp(['    got ' num2str(neg_sv) ' svs']);
        sv = max(neg_sv, svSize);   % make sure to keep all sv (if it has already many svs => it has not converged well, no point adding new svs)        
        if sv < length(sind), sind = sind(1:sv); end
        N = N(sind);
    else
        N = [];
    end
    
    % 2. run classifier on all negs
    disp('  predict');
    %[~, ~, s] = svmpredict(ones(size(allN,1), 1), X(allN,:), model);
    %s = model.Label(1)*s;  
    cnt = 0;
    for j=oldj:stepS:numel(allN)
        myprintf(j);
        
        thisN = allN(j:min(j+stepS-1,numel(allN)));
        [~, ~, s] = svmpredict(ones(numel(thisN), 1), X(thisN,:), model);
        s = model.Label(1)*s;
        
        % 3. collect hard negs and add to pool of svs, goto step1
        %disp('  bookkeep');
        [sval, sind] = sort(s, 'descend');
        neg_sv = numel(find(s>-1.05));
        cnt = cnt + neg_sv;
        sind = sind(1:neg_sv);
        N = [N; thisN(sind)];
        
        if numel(N) > negSize
            break;
        end
    end
    disp(['   total of ' num2str(cnt) ' svs added in this dm iteration']);
    if oldj == 1 && j+stepS > numel(allN)
        disp('  full round of dm successfully completed'); 
        D = [P; N];
        model = svmtrain(Y(D,:), X(D,:), optionString);
        break;
    end
    
    oldj = j;
    if oldj+stepS > numel(allN), oldj = 1; end
    myprintfn;
    
    %{
    % 3. collect hard negs and add to pool of svs, goto step1
    disp('  bookkeep');
    [sval, sind] = sort(s, 'descend');
    neg_sv = numel(find(s>-1));
    sv = min(neg_sv, negSize-n);
    disp(['   adding ' num2str(sv) ' svs to cache']);
    sind = sind(1:sv);
    N = [N; allN(sind)];    
    %}
end

catch
    disp(lasterr); keyboard;
end
