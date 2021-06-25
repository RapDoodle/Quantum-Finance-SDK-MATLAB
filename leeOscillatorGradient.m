function dz = leeoscillatorGradient(x)
load('leeoscillator.mat');
dz = x(:);
m = size(Z, 2);
n = length(dz);
for i = 1:n
    if dz(i) <= -0.9 || dz(i) >= 0.9
        s = sigmoid(dz(i));
        dz(i) = s .* (1 - s);
    else
        row = int32((dz(i)+1) ./ stepsize) + 1;
        col1 = int32(rand() * (m - 1)) + 1;
        col2 = int32(rand() * (m - 1)) + 1;
        try
            dz(i) = (Z(row + 1, col1) - Z(row - 1, col2)) ./ (stepsize * 2);
        catch
            fprintf('[%5.2f] %d, %d, %d, %d, %d, %d\n', dz(i), row + 1, col1, row - 1, col2, m, n);
        end
        if dz(i) > 1
            dz(i) = log(dz(i)) + 1;
        end
    end
end
dz = reshape(dz, size(x));
end