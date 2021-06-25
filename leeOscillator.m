function z = leeOscillator(x)
load('leeOscillator.mat');
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