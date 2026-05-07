function plot_state_bar(state, idx_before, idx_after)
occ_b = state_occupancy(state, idx_before, 4);
occ_a = state_occupancy(state, idx_after, 4);
bar([occ_b(:) occ_a(:)])
set(gca,'XTickLabel',{'GhiDlo','GloDhi','GhiDhi','GloDlo'})
legend('Before','After')
ylabel('fraction')
ylim([0 1])
end
