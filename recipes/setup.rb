#
# Cookbook Name:: mapzen_odes
# Recipe:: setup
#

package 'osm2pgsql'

%w(
  build-essential
  osmctools
  gdal-bin
  parallel
  pbzip2
  zip
).each do |p|
  package p
end

# lockrun
remote_file '/usr/local/bin/lockrun' do
  source 'https://s3.amazonaws.com/mapzen.software/lockrun'
  mode '0755'
end

# imposm
ark 'imposm3' do
  owner         'root'
  url           node[:mapzen_odes][:imposm][:url]
  version       node[:mapzen_odes][:imposm][:version]
  prefix_root   node[:mapzen_odes][:imposm][:installdir]
  has_binaries  ['imposm3']
  not_if        { ::File.exist?("#{node[:mapzen_odes][:imposm][:installdir]}/imposm3-#{node[:mapzen_odes][:imposm][:version]}") }
end

# scripts basedir
directory node[:mapzen_odes][:setup][:scriptsdir] do
  owner node[:mapzen_odes][:user][:id]
end

# scripts
%w(extracts.sh shapes.sh coastlines.sh).each do |t|
  template "#{node[:mapzen_odes][:setup][:scriptsdir]}/#{t}" do
    owner   node[:mapzen_odes][:user][:id]
    source  "#{t}.erb"
    mode    0755
    only_if { node[:mapzen_odes][:json] }
  end
end

%w(osm2pgsql.style mapping.json).each do |f|
  cookbook_file "#{node[:mapzen_odes][:setup][:scriptsdir]}/#{f}" do
    owner   node[:mapzen_odes][:user][:id]
    source  f
    mode    0644
  end
end

%w(ex data logs shp coast).each do |d|
  directory "#{node[:mapzen_odes][:setup][:basedir]}/#{d}" do
    owner node[:mapzen_odes][:user][:id]
  end
end
