resource_name :py_virtualenv # ~FC016

property :location, String, required: true, name_property: true
property :py_binary, String, default: "python"
property :pip_binary, String, default: "pip"
property :virtualenv_binary, String, default: "virtualenv"
property :site_packages, [true, false], default: false
property :options, Array, default: []
property :upgrade_virtualenv, [true, false], default: false
property :virtualenv_version, String, default: ""

action :create do
  directory new_resource.location do
    recursive true
  end

  cmd_install_virtualenv = "#{new_resource.pip_binary} install 'virtualenv#{new_resource.virtualenv_version}'"
  if new_resource.upgrade_virtualenv
    cmd_install_virtualenv << "--upgrade"
  end

  execute "pip install virtualenv" do
    command cmd_install_virtualenv
  end

  cmd_options = Marshal.load(Marshal.dump(new_resource.options))
  if new_resource.site_packages
    cmd_options << "--system-site-packages"
  end

  cmd_virtualenv = "#{new_resource.virtualenv_binary} -p #{new_resource.py_binary} #{new_resource.location}"

  if cmd_options
    cmd_options.each do |option|
      cmd_virtualenv << " #{option}"
    end
  end

  execute "create_virtual_env #{new_resource.location}" do
    command cmd_virtualenv
    not_if { ::File.exist?("#{new_resource.location}/bin/python") }
  end
end
