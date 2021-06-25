function mQPL = calculateQPL(data, interval, target)
% Calculate the Quantum Price Level (QPL)
% Author: Bohui WU (Bowen)
% Adapted from: Raymond S. T. LEE's QPL2019.mql
%
% Parameters:
%   data: A table containing the field "Open" or "Close" in 
%       time desending order (the latest trading day should
%       be the first entry). The field "Return" is optional
%       as it can be calculated, be it would be extremely
%       slow as it needs to be calculated everytime the
%       function is called.
%   interval: The interval used to estimate the wavefunction.
%       Suggested value: 2048. In general, it should be 
%       greater than 500 trading days.
%   target: The target in which the calculation of QPLs are 
%       based on. Should provide the name of the field.
%       For example, "Open" or "Close". By default: "Close"
%
% References:
%   [1] R. S. T. Lee, Quantum Finance: Intelligent Forecast 
%       and Trading Systems. Singapore: Springer Singapore, 
%       2020. doi: 10.1007/978-981-32-9796-8.
%
%
assert(interval <= size(data, 1), "Not enough data.");


% =======================================================
% Step 1: Calculate all the K values (energy levels)
%           from k0 to k20 using the formula 5.17 in
%           p98 of [1].
K = zeros(21, 1);
for n=1:21
    K(n) = ((1.1924 + (33.2383*(n-1)) + (56.2169*(n-1)*(n-1))) / ...
        (1 + 43.6196*(n-1)))^(1/3);
end


% =======================================================
% Step 2: Calculate the returns, its mean (mu) and  
%           standard deviation (sigma) of period
%           returns

% Calculate the returns
if ~isfield(table2struct(data(1, :)), "Return")
    returns = zeros(size(data, 1)-1, 1);
    n = min(size(data, 1)-1, interval);
    for i=1:n
        returns(i) = data{i, "Close"} / data{i+1, "Close"};
    end
else
    returns = data{1:interval, "Return"};
end

mu = mean(returns);
sigma = std(returns);  % N - 1 is not needed
% The width of each slice of returns
dr = (3*sigma) / 50;


% =======================================================
% Step 3: Form the QP Wavefunction distribution

% Q is the quantum price return wavefunction Q(r).
%   In other words, the number of occurrences
Q = zeros(100, 1);
% Loop over the maxRno to get the distribution
%   where maxRno is (interval-1), eg. 2048-2.
%   Purpose: to exclude the boundary case
maxRno = interval - 1;
% tQno is used to keep track of the number of
%   returns found in the selected intervals
%   (some (r)s may not fit in any interval)
tQno = 0;
for nR=1:maxRno
    found = false;
    % nQ is the index of slice in the distribution 
    % function
    nQ = 1; 
    r = 1 - (dr*50);
    while ~found && nQ <= 100
        if returns(nR) > r && returns(nR) <= r + dr
            Q(nQ) = Q(nQ) + 1;
            tQno = tQno + 1;
            found = true;
        else 
            nQ = nQ + 1;
            r = r + dr;
        end
    end
end

r = 1 - (dr*50);
rs = zeros(100, 1);
for i=1:100
    rs(i) = r;
    r = r + dr;
end

% NQ is the normalized quantum price return 
%   wavefunction NQ(r)
NQ = Q / tQno;

% Find maxQ and maxQno
[maxQ, maxQno] = max(NQ);


% =======================================================
% Step 4: Evaluate the lambda for the Quantum Price
%   wavefunction.
r0 = rs(maxQno) - (dr/2);
r1 = r0 + dr;   % r_{+1}
rn1 = r0 - dr;  % r_{-1}
lambda = abs(...
    ( (rn1^2)*NQ(maxQno-1) - (r1^2)*NQ(maxQno+1) ) /...
    ( (r1^4)*NQ(maxQno+1) - (rn1^4)*NQ(maxQno-1) ) ...
    );


% =======================================================
% Step 5: Solve for QFSE to determine the first 21
%   energy levels
%   wavefunction.
QFEL = zeros(21, 3);
for n=1:21
    a = (1 / (2*(n-1)+1))^3;
    b = 0;
    c = -1 / (2*(n-1)+1);
    d = -1*lambda*(K(n)^3); 
    QFEL(n, :) = roots([a, b, c, d]);
end


% =======================================================
% Step 6: Evaluate all QPR values
QPR = zeros(21, 1);
NQPR = zeros(21, 1);
for n=1:21
    QPR(n) = QFEL(n) / QFEL(1);
    NQPR(n) = 1 + 0.21*sigma*QPR(n);
end


% =======================================================
% Step 6: Evaluate Quantum Price Levels (QPL)
if nargin < 3
    % The target is not specified, use default value
    target = "Close";
end
mQPL = zeros(20*2+1, 2);
price = data{1, target};
for n=-20:1:20
    mQPL(n+20+1, 1) = n;
    if n >= 0
        mQPL(n+20+1, 2) = price * NQPR(n+1);
    else
        mQPL(n+20+1, 2) = price / NQPR(abs(n));
    end
end

end

