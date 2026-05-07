function makepretty_BM2()
% set some graphical attributes of the current axis

set(get(gca, 'XLabel'), 'FontSize', 22);
set(get(gca, 'YLabel'), 'FontSize', 22);
set(gca, 'FontSize', 16);
box off
set(gca,'Linewidth',2)
set(get(gca, 'Title'), 'FontSize', 18);
end
