function [M,R,S,K,qual_auth_names,idx] = hyperagent_newest(Q,H,W,...
                                                qual_auth_names,R,K,alpha)

% ========================= LABEL PROPAGATION =============================
label = sum(Q(:,R>0),2);

% Randomly select 20% of data as test set and set the parameters for HyperPrior
[Train, Test] = crossvalind('HoldOut', label, 0.2);
%alpha = 0.1;

% Semi-supervised learning by HyperPrior
%[F] = HyperModified(H, label, Test, alpha, W);
[F] = HyperModifiedVectorized(H, label, Test, alpha, W);

[~,idx] = sort(F,'descend');
%idx
%disp(['The AUC of HyperPrior is ' num2str(AUC) ' for this experiment.']);

% Find the Top-K vertices
% K = 1000;

for i = 1:K
    disp(qual_auth_names{idx(i)});
end

% Top Hyperedge Sets : S (|S| x m)
% find(sum(H(idx(1:K)',:),1)>0)
% S = H(idx(1:K)',sum(H(idx(1:K)',:),1)>0)';
S = H(:,sum(H(idx(1:K)',:),1)>0)';
% Q = Q(idx(1:K)',:);

% Hyperedge Skill Matrix M(s,a)
M = S * Q;
end
