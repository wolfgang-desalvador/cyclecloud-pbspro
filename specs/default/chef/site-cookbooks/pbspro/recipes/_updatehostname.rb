
#
# Cookbook Name:: gridengine
# Recipe:: _updatehostname
#

if node[:cyclecloud][:hosts][:standalone_dns][:enabled] == false
  template node[:hostname_update][:handler_path] do
    source "hostname_update_handler.py.erb"
    mode "0644"
    owner "root"
    group "root"
  end

  bash "run external hostname handler" do
    code <<-EOF
    yum install -y python3 python3-virtualenv
    /usr/bin/python3 -m venv auth #{node[:hostname_update][:environment_path]}
    source #{node[:hostname_update][:environment_path]}/bin/activate
    #{node[:hostname_update][:environment_path]}/bin/python -m pip install --upgrade pip
    #{node[:hostname_update][:environment_path]}/bin/python -m pip install azure-keyvault-secrets azure-identity
    #{node[:hostname_update][:environment_path]}/bin/python #{node[:hostname_update][:handler_path]}
    EOF
  end
end

bash "update hostname via jetpack" do
    code <<-EOF
    #{node[:cyclecloud][:home]}/system/embedded/bin/python -c "import jetpack.converge as jc; jc._send_installation_status('warning')"
  EOF
end