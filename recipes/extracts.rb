#
# Cookbook Name:: odes
# Recipe:: extracts
#

execute 'create extracts' do
  user      node[:mapzen_odes][:user][:id]
  cwd       node[:mapzen_odes][:setup][:basedir]
  timeout   node[:mapzen_odes][:osmconvert][:timeout]
  notifies  :run, 'execute[fix osmconvert perms]', :immediately
  command <<-EOH
    parallel -j #{node[:mapzen_odes][:osmconvert][:jobs]} \
      -a #{node[:mapzen_odes][:setup][:scriptsdir]}/extracts.sh \
      --joblog #{node[:mapzen_odes][:setup][:basedir]}/logs/parallel_extracts.log
  EOH
  only_if { node[:mapzen_odes][:process][:pbf_extracts] == true || node[:mapzen_odes][:process][:xml_extracts] == true}
end

execute 'fix osmconvert perms' do
  action    :nothing
  user      node[:mapzen_odes][:user][:id]
  cwd       node[:mapzen_odes][:setup][:basedir]
  command   'chmod 644 ex/*'
  only_if { node[:mapzen_odes][:process][:pbf_extracts] == true || node[:mapzen_odes][:process][:xml_extracts] == true}
end
