% Transient Chaotic Radial Basis Function (TCRBF)
%
% Note:
%   This toolbox function is still in beta stage. It is not completed yet.
%
% References: 
%   [1] T. Y. F. Qiu, A. Y. C. Yuan, P. Z. Chen, and R. S. T. Lee, 
%       “Hybrid Chaotic Radial Basis Function Neural Oscillatory Network 
%       (HCRBFNON) for Financial Forecast and Trading System,” in 2019 
%       IEEE Symposium Series on Computational Intelligence (SSCI), Dec. 
%       2019, pp. 2799–2806. doi: 10.1109/SSCI44817.2019.9002781.


% User preferences
stepsize = 0.001;
recordsize = 100;  % Save the last 300 values of the oscillation

% TCRBF
tx = zeros(1, ((2/stepsize)+1)*recordsize);
ty = zeros((2/stepsize)+1, recordsize);
idx = 1;
tic
for x=0:stepsize:1
    tx(1+(recordsize*(idx-1)):recordsize*idx) = x;
    if x <= 0.5
        ty(idx, :) = (leeOscillator(ones(1, recordsize) * (2*(x-0.25))));
    else
        ty(idx, :) = (leeOscillator(ones(1, recordsize) * (2 - 2*(x+0.25))));
    end
    idx = idx + 1;
end
toc

figure
plot(tx, reshape(ty',[1,((2/stepsize)+1)*recordsize]), '.');