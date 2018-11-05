resource_name :py_run # ~FC016

property :py_script, String, required: true, name_property: true
property :py_binary, String, default: '/usr/bin/python'
property :script_args, Array, default: []
property :py_args, Array, default: []
property :pythonpath, [String, false], default: false

action :run do
  if new_resource.pythonpath
    cmd_run = "PYTHONPATH='#{new_resource.pythonpath}' #{new_resource.py_binary}"
  else
    cmd_run = new_resource.py_binary
  end

  if new_resource.py_args
    new_resource.py_args.each do |py_arg|
      cmd_run << " #{py_arg}"
    end
  end

  cmd_run << " #{new_resource.py_script}"

  if new_resource.script_args
    new_resource.script_args.each do |script_arg|
      cmd_run << " #{script_arg}"
    end
  end

  execute "Running python script #{new_resource.py_script}" do
    command cmd_run
  end
end
