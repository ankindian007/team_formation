function[F] = HyperModifiedVectorized(H, label, test, alpha, W)

% Initial Labels
Y_0 = label;

D_e = sum(H, 1);
D_v = sum(H, 2);

% optimize F
F = OptimizeF(H, D_e, D_v, W, Y_0, alpha);

function[F] = OptimizeF(H, D_e, D_v, W, Y, alpha)

[m, n] = size(H);
%tmp = zeros(m, n);
tmp = sparse([],[],[],m,n);
t_3 = toc;
for i = 1 : n
    if D_e(i) ~= 0
        
        tmp(:, i) = H(:, i) * sqrt(W(i)) / sqrt(D_e(i));
        
    end
end
disp('Time taken in tmp:');
t_4 = toc-t_3

S = tmp * tmp';
disp('Time taken in S:');
t_5 = toc - t_4
nnz(S)
[S_i, S_j, ~] = find(S);
size(S_i)
size(S_j)
t_6 = toc - t_5 ;
count = 0;
S1 = S;
t_7 = toc - t_6
S((S_j-1)*size(S,1) + S_i) = S((S_j-1)*size(S,1) + S_i) ./sqrt(D_v(S_i)) ./sqrt(D_v(S_j));
t_8 = toc - t_7
%{
for i = 1: size(S_i,1)
    
    if S(S_i(i), S_j(i)) ~=0            
        count = count +1;
        S(S_i(i), S_j(i)) = S(S_i(i), S_j(i)) / sqrt(D_v(S_i(i)))...
                                                / sqrt(D_v(S_j(i)));            
    end        
    
end
%}

%S
count
disp('Total time taken in S update:');
toc       
%{
count = 0;
S = S1;
for i = 1 : m    
    for j = 1 : m        
        %tic;
        if S(i, j) ~=0            
            S(i, j) = S(i, j) / sqrt(D_v(i)) / sqrt(D_v(j));            
            count = count +1;
        end        
        %disp('Time taken in S update:');
        %toc
    end    
end
count 
S
%}

nnz(S)
size(find(S==Inf))
nnz(Y)
size(find(Y==Inf))
F = Y;
for i = 1 : 10000
    F_old = F;
    
    F = alpha * S * F + (1 - alpha) * Y;
    
    if max(abs(F - F_old)) < 1e-9
        disp('Iterations taken in diffusion process:');
        i
        break
    end
end
disp('Total time taken in diffusion process:');
t_9 = toc - t_8;

if i == 10000
    disp('OptimizeF didn''t converge!')
end