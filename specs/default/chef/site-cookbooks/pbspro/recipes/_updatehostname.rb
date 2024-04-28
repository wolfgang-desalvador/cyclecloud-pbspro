
#
# Cookbook Name:: gridengine
# Recipe:: _updatehostname
#

if !node[:cyclecloud][:hosts][:standalone_dns]
  template "/tmp/update_hostname.py" do
    source "update_hostname.py.erb"
    mode "0644"
    owner "root"
    group "root"
  end

  bash "run external update hostname" do
    code <<-EOF
    yum install -y python3 python3-virtualenv
    /usr/bin/python3 -m venv auth /opt/cycle/hostname/
    source /opt/cycle/hostname/bin/activate
    /opt/cycle/hostname/bin/python -m pip install --upgrade pip
    /opt/cycle/hostname/bin/python -m pip install azure-keyvault-secrets azure-identity
    /opt/cycle/hostname/bin/python update_hostname.py"
  EOF
  end
end

bash "update hostname via jetpack" do
    code <<-EOF
    #{node[:cyclecloud][:home]}/system/embedded/bin/python -c "import jetpack.converge as jc; jc._send_installation_status('warning')"
  EOF
end