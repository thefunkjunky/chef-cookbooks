resource_name :py_packages # ~FC016

property :pip_location, String, default: "/usr/bin/pip"
property :local_repo, [String, false], default: false
property :packages, Hash, default: {}
property :requirements_txt, [String, false], default: false
property :target_folder, [String, false], default: false
property :pip_options, Array, default: []
property :pip_install_options, Array, default: []
property :pip_uninstall_options, Array, default: ["--yes"]
property :pip_freeze_file, [String, false], default: false
property :pip_freeze_options, Array, default: []

action :install do
  cmd_pip = new_resource.pip_location

  if new_resource.pip_options
    new_resource.pip_options.each do |pip_option|
      cmd_pip << " #{pip_option}"
    end
  end

  cmd_pip << " install"

  if new_resource.target_folder
    cmd_pip << " --target=#{new_resource.target_folder}"
  end

  if new_resource.local_repo
    cmd_pip << " --extra-index-url=#{new_resource.local_repo}"
  end

  if new_resource.pip_install_options
    new_resource.pip_install_options.each do |pip_install_option|
      cmd_pip << " #{pip_install_option}"
    end
  end

  if new_resource.requirements_txt
    cmd_pip_requirements = cmd_pip.dup
    cmd_pip_requirements << " -r #{new_resource.requirements_txt}"
    execute "pip install requirements.txt" do
      command cmd_pip_requirements
    end
  end

  if new_resource.packages
    new_resource.packages.each do |package, version|
      cmd_pip << " '#{package}#{version}'"
    end
    execute "pip install packages" do
      command cmd_pip
    end
  end
end

action :uninstall do
  cmd_pip = new_resource.pip_location

  if new_resource.pip_options
    new_resource.pip_options.each do |pip_option|
      cmd_pip << " #{pip_option}"
    end
  end

  cmd_pip << " uninstall"

  if new_resource.pip_uninstall_options
    new_resource.pip_uninstall_options.each do |pip_uninstall_option|
      cmd_pip << " #{pip_uninstall_option}"
    end
  end

  if new_resource.requirements_txt
    cmd_pip_requirements = cmd_pip.dup
    cmd_pip_requirements << " -r #{new_resource.requirements_txt}"
    execute "pip uninstall requirements.txt" do
      command cmd_pip_requirements
    end
  end

  if new_resource.packages
    new_resource.packages.each do |package, version|
      cmd_pip << " '#{package}#{version}'"
    end
    execute "pip uninstall packages" do
      command cmd_pip
    end
  end
end

action :pip_freeze do
  cmd_pip = new_resource.pip_location

  if new_resource.pip_options
    new_resource.pip_options.each do |pip_option|
      cmd_pip << " #{pip_option}"
    end
  end

  cmd_pip << " freeze"

  if new_resource.pip_freeze_options
    new_resource.pip_freeze_options.each do |freeze_option|
      cmd_pip << " #{freeze_option}"
    end
  end

  cmd_pip << " > #{new_resource.pip_freeze_file}"

  execute "Execute pip freeze > #{new_resource.pip_freeze_file}" do
    command cmd_pip
  end
end
