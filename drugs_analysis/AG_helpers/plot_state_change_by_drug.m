function plot_state_change_by_drug(Group, st, DrugColors, DrugNames)
% One value per session: occupancy after - before.

data1 = Group.state_occ_after{1}(:,st) - Group.state_occ_before{1}(:,st);
data2 = Group.state_occ_after{2}(:,st) - Group.state_occ_before{2}(:,st);
plot_box_or_spread({data1 data2}, DrugColors, 1:2, DrugNames)
yline_compat(0,'--r')
makepretty_BM2
end
