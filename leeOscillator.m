function z = leeOscillator(x)
persistent Z stepsize;
if isempty(Z) || isempty(stepsize)
    if isfile('leeOscillator.mat')
        load('leeOscillator.mat', 'Z', 'stepsize');
    else
        error("Please run 'leeOscillatorGen' to generate the oscialltor 'first.");
    end
end
z = x(:);
m = size(Z, 2);
n = length(z);
for i = 1:n
    if z(i) < -1 || z(i) > 1
        z(i) = 1 ./ (1 + exp(-z(i)));
    else
        row = int32((z(i)+1)/stepsize) + 1;
        col = int32(rand() * (m - 1)) + 1;
        z(i) = Z(row, col);
    end
end
z = reshape(z, size(x));
end