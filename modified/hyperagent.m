%========================= DATE PREPERATION =============================
m = 29; % # Vertices 
n = 7; % # Edges 
N = 4; % # Skills

% Node Skill Matrix Q (m x |U|) where U = {a1,a2,.....,aN} skills.
% ['#', 'C', 'J', 'P'] 
Q = zeros(m,N);
Q(1,:) = [1 0 0 0]; Q(2,:) = [1 1 0 0]; Q(3,:) = [0 1 0 0]; 
Q(4,:) = [0 0 0 0]; Q(5,:) = [1 0 0 0]; Q(6,:) = [0 0 0 1]; 
Q(8,:) = [0 1 0 0]; Q(9,:) = [1 0 0 0]; 
Q(10,:) = [0 0 1 0]; Q(11,:) = [0 0 1 0]; Q(12,:) = [0 1 0 0]; 
Q(27,:) = [0 0 1 0]; Q(26,:) = [0 0 0 3]; Q(14,:) = [1 0 0 0]; 
Q(23,:) = [2 0 0 0]; Q(22,:) = [0 1 0 0]; 
%Q(24,:) = [20 0 0 0];

% Hyper-incidence matrix H (n # Edges X m # Vertices)
%{
H = zeros(n,m);
H(1,1)=1; H(1,2)=1;
H(2,2:7)=1;
H(3,5:13)=1; H(3,27:29)=1;  
H(4,26:29)=1; H(4,14:15)=1; 
H(5,14:20)=1; 
H(6,16:17)=1; H(6,21:23)=1;  
H(7,18:20)=1; H(7,24:25)=1; 
H=H';
%}

H_Idx = [1,1; 1,2; 2,2;2,3; 2,4; 2,5; 2,6; 2,7; 3,5; 3,6; 3,7; 3,8;
         3,9; 3,10; 3,11; 3,12; 3,13; 3,27; 3,28; 3,29;
            4,26; 4,27; 4,28; 4,29; 4,14;
         4,15; 5, 14; 5, 15; 5,16; 5,17; 5,18; 5,19; 5,20; 6,16;
         6,17; 6,21;6,22; 6,23; 7,18; 7,19; 7,20; 7,24; 7,25];
H = sparse(H_Idx(:,2), H_Idx(:,1), ones(43,1));
%}
Mul = [3 7 5 4 2 2 2]'; % Multiplicity
Car = sum(H,1)'; % Nothing but D_e
W = Mul./Car; % Weight (Kapoor et al. 2013)

%========================= LABEL PROPAGATION =============================

%label = zeros(29, 1);
%label(1:2,1)=1; label(26:29,1)=1; label(14:15,1)=1;
label = sum(Q(:,find(R>0)),2);

% Randomly select 20% of data as test set and set the parameters for HyperPrior
[Train, Test] = crossvalind('HoldOut', label, 0.2);
mu = 0.1; rho = 1;

% Semi-supervised learning by HyperPrior
[F] = HyperModified(H, label, Test, mu, W);
[~,idx] = sort(F,'descend');
idx
%disp(['The AUC of HyperPrior is ' num2str(AUC) ' for this experiment.']);

% Find the Top-K vertices
% K = 3;

% Top Hyperedge Sets : S (|S| x m)
find(sum(H(idx(1:K)',:),1)>0)
S = H(:,find(sum(H(idx(1:K)',:),1)>0))'

% Hyperedge Skill Matrix M(s,a)
M = S * Q

%========================= MULTI-SET MULTI-COVER (MM)  ===================
% N is the number of skillls 
% Requirement vector R (|U| x 1)
%R = zeros(m,1);
%R = [1; 1; 1; 1]; % Too low but all
%R = [10; 10; 10; 10]; % Not possible
%R = [20; 0; 1; 0]; % Not possible
%R = [20; 0; 0; 0]; 

% # Extracted hyper-edges: hm
hm = size(M,1);
f = ones(hm,1);
%M'*f
A = M';
b = -R;
lb = zeros(hm,1); 
ub = ones(hm,1);
x_star = linprog(f,A,b,[],[],lb,ub)
%for i=1:size(S,1), find(S(i,:)==1), M(i,:), end

% ============================ MM Rounding ===============================
acc_iter = 100000;
count = 0;
while true
U = zeros(hm,1);
for i = 1:hm
%    y = zeros(acc_iter,1);
%    x = rand(acc_iter,1);
%    y(x < x_star(i)) = 1;
%    sum(y)

%   if sum(y)/acc_iter <= x_star(i)
%       U(i,1) = 1;
%   end
%x_star(i)
if rand(1)<= x_star(i)
    U(i,1) = 1;
end
end

count = count + 1;
if A*U >= R' 
    break;    
elseif count > 10000
    break;
end
end
S_sub = S(find(U>0),:);
count
U'
% for i=1:size(S,1), find(S(i,:)==1), M(i,:), end
for i=1:size(S_sub,1), find(S_sub(i,:)==1), end
%{
n = 4;
p = [0.4 0.1 0.1 0.9];
k = size(p,2);
u = rand(1,n);
x = zeros(1,n);
for i=1:k
    i*(sum(p(1:i-1))<=u & u<sum(p(1:i)))
    x=x+i*(sum(p(1:i-1))<=u & u<sum(p(1:i)));
end
x
%}