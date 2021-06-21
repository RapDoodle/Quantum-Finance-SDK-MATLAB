% Lee-Oscillator
% Credits: This code is adapted from Raymond LEE's code in his book
%   on Quantum Finance (p.256)
% For more information: 
%   [1] R. S. T. Lee, Quantum Finance: Intelligent Forecast and Trading 
%       Systems. Singapore: Springer Singapore, 2020. doi: 
%       10.1007/978-981-32-9796-8.
%   [2] R. S. T. Lee, “Lee-Associator—a chaotic auto-associative network 
%       for progressive memory recalling,” Neural Networks, vol. 19, 
%       no. 5, pp. 644–666, Jun. 2006, doi: 10.1016/j.neunet.2005.08.017.

% User preferences
stepsize = 0.001;
recordsize = 100;  % Save the last 300 values of the oscillation

% Oscillator parameters
% For more information, refer [2].
N = 600;
s = 5;
e = 0.02;
k = 500;
c = 1;
a1 = 5;
a2 = 5;
b1 = 1;
b2 = 1;
eu = 0;
ev = 0;

% Intermediate values
% DON'T CHANGE THE VALUE
idx = 1;
recbgnidx = N-recordsize; % Record begin index
recofst = (N-recordsize)-1; % Record offset
xaixs = zeros(1, ((2/stepsize)+1)*recordsize);
xaxisidx = 1;

% Output parameter
Z = zeros((2/stepsize)+1, recordsize);

for i=-1:stepsize:1
    u = zeros(1, N);
    v = zeros(1, N);
    w = zeros(1, N);
    z = zeros(1, N);
    
    z(1) = 0.2;
    u(1) = 0.2;
    
    it = i + 0.02*sign(i);
    
    for t = 1:N-1     
        tempu = a1*u(t) - a2*v(t) + it - eu;
        tempv = b1*u(t) - b2*v(t) - ev;
        u(t+1) = (exp(s*tempu) - exp((-1)*s*tempu)) / (exp(s*tempu) + exp((-1)*s*tempu));
        v(t+1) = (exp(s*tempv) - exp((-1)*s*tempv)) / (exp(s*tempv) + exp((-1)*s*tempv));
        w(t+1) = (exp(s*it) - exp((-1)*s*it)) / (exp(s*it) + exp((-1)*s*it)); 
        z(t+1) = ((u(t+1) - v(t+1)) * exp(-k*it*it) + c*w(t+1));       
        if (t >= recbgnidx)
            xaixs(xaxisidx) = i;
            xaxisidx = xaxisidx + 1;
            Z(idx, t-recofst) = z(t+1);
        end
    end
    idx = idx + 1;
end

save('leeoscillator', 'Z', 'stepsize')

plot(xaixs, reshape(Z',[1,((2/stepsize)+1)*recordsize]), '.')