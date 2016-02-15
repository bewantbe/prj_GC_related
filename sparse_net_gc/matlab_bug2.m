% matlab -nodisplay

% matlab bug
plot(rand(1,999000), 'k.');
print('-depsc2', 'a.eps');

% matlab bug
plot(rand(1,999000), '.');
print('-depsc2', 'a.eps');

% octave bug
scatter(1:999000, rand(1,999000), '.');
print('-depsc2', 'a.eps');

