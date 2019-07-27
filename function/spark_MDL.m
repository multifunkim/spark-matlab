function [MDL]=spark_MDL(Y, Dictionary, output, param)

% fprintf('%-40s: ','Calculating MDL...')

try
    Coef_mtx=full(output.CoefMatrix);
catch
    Coef_mtx=full(output);
end

idx = zeros(param.L, size(Coef_mtx,2));
mdl=zeros(1,size(Y,2));
m = size(Y,1);

tmp=zeros(size(Y,1),1);

for i=1:size(Y,2)
    
    idx = find(Coef_mtx(:,i) ~= 0);
    y           = Y(:,i);
    if (y == tmp)
        mdl(1,i)    = 0;
    else
        D           = Dictionary(:,idx);
        P_D         = D*pinv(D'*D)*D';
        P_D_perp    = eye(m) - P_D;
        variance    = 1/m * (P_D_perp * y)' * y;
        mdl(1,i)    = log2 (2 * pi * variance);
    end
    
end

MDL = (m/2 * sum(mdl)) + (3/2 * param.L * size(Y,2) * log2(param.K));
%MDL(1,sparsity_level) = (m/2 * sum(mdl)) + (1/2 * param.L * size(Y,2) * log2(param.K)) + param.L*size(Y,2)*log2star(param.K);
%AIC(1,sparsity_level) = (m/2 * sum(mdl)) + (1/2 * (param.K + param.L *
%size(Y,2))/(param.K - param.L * size(Y,2)-2));


% fprintf('%30s\n','...Completed')