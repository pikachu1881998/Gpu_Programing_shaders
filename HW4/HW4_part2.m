clear; close all; clc;
rough = 0.828;
rough2 = 0.786;
a = rough * rough;
a2 = rough2 * rough2;
x = (0:0.01:1);
beck =  1./(pi * a.^2.*(x.^4)) .* exp((x.^2 - 1)./ (a.^2 * x.^2));
bling = (1/pi*a2.^2) .* (x.^((2/a2.^2) - 2));
plot(x, beck);
hold on;
plot(x, bling);
