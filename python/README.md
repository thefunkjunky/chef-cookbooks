# chef_python
Simplified Chef cookbook and custom resources for Python

## Requirements

### Platforms
- CentOS 7

### Chef

- Chef 12.5 or later 

## Quickstart

This example recipe installs Python 3.6 and pip/pip3 packages at the system level for CentOS 7 by including the 'chef_python::default' recipe; then creates a Python 3.6 virtual environment, installs/updates a couple of packages to the newly created virtual environment, copies a python script from the cookbook "files/" folder, and runs the script from the virtual environment:

##### recipes/demo.rb
```
include 'chef_python::default'

py_virtualenv "/home/myuser/py3project/py3venv" do
  py_binary "python3.6"
end

py3_packages = {"pip" => "==10.0.1", "requests" => ""}

py_packages "pip3 packages" do
  pip_location "/home/myuser/py3project/py3venv/bin/pip"
  packages py3_packages
  pip_install_options ["--upgrade"]
end

cookbook_file "/home/myuser/py3project/test_script.py" do
  source "test_script.py"
end

py_run "/home/myuser/py3project/test_script.py" do
  py_binary "/home/myuser/py3project/py3venv/bin/python"
end
```

## Attributes
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef_python']['py_sys_packages']</tt></td>
    <td>Array</td>
    <td>List of base system packages to install.</td>
    <td><tt>[
  'python36u',
  'python-pip',
  'python36u-pip'
]</tt></td>
  </tr>
</table>

## Resources

### py_virtualenv

The `py_virtualenv` resource installs `virtualenv` and creates a Python virtual environment, if
not already present at the given location.

NOTE: to delete a virtual environment, simply use Chef's ['Directory'](https://docs.chef.io/resource_directory.html) resource to delete the virtual environment folder.

```
py_virtualenv "/home/myuser/py3project/venv" do
  py_binary "python3.6"
  options ["--prompt=__py36venv__"]
end
```

#### Actions
* `:install` - Creates virtual environment at the location specified. *(default)*

#### Properties
* `location` - Location to install the virtual environment. *(name property)*
* `py_binary` - Which version of Python to use in the virtual environment.  Default = "python"
* `pip_binary` - Which pip to install `virtualenv` with. Default = "pip"
* `virtualenv_binary` - Which `virtualenv` to use.  Default = "virtualenv"
* `upgrade_virtualenv` - Whether to upgrade `virtualenv` or not.  Default = false
* `virtualenv_version` - Specify which `virtualenv` version to install, using [Python Version Specifiers](https://www.python.org/dev/peps/pep-0440/#version-specifiers) syntax.  See `py_packages` below for an example of this syntax.  Default = ""
* `site_packages` - Whether to include global system site packages in the virtual environment.  Default = false
* `options` - Additional options to pass to `virtualenv`. Default = []

### py_packages

The `py_packages` resource manages pip packages in a Python environment

```
cookbook_file "/home/myuser/py3project/requirements.txt" do
  source "requirements.txt"
end

additional_packages = {"pip" => "==10.0.1", "requests" => ""}

py_packages "py3 packages" do
  pip_location "/home/myuser/py3project/venv/bin/pip"
  requirements_txt "/home/myuser/py3project/requirements.txt"
  packages additional_packages
  pip_install_options ["--upgrade"]
end

py_packages "pip freeze new requirements" do
  pip_location "/home/myuser/py3project/venv/bin/pip"
  pip_freeze_file "/home/myuser/py3project/updated_requirements.txt"
  action :pip_freeze
end
```

#### Actions
* `:install` - Installs packages to the specified environment. *(default)*
* `:uninstall` - Uninstalls packages from the specified environment.
* `:pip_freeze` - Outputs `pip freeze` to a file from a specified environment

#### Properties
* `pip_location` - Location of `pip` binary.  This will determine the environment used. Default = "/usr/bin/pip"
* `local_repo` - Specifies a local custom `pip` package repository to use.  Default = false
* `packages` - A hash map of packages to install => optional version specifiers. See [Python Version Specifiers](https://www.python.org/dev/peps/pep-0440/#version-specifiers) for more information.  Default = {}
* `requirements_txt` - Optional `requirements.txt` location to install from.  Default = false
* `target_folder` - Optional target folder location that `pip` will install packages to.  Default = false
* `pip_freeze_file` - Location of file to store output of `:pip_freeze`. Default = false
* `pip_options` - List of options to pass to `pip`.  Default = []
* `pip_install_options` - List of options to pass `pip install`.  Default = []
* `pip_uninstall_options` - List of options to pass `pip uninstall`.  Default = ["--yes"]
* `pip_freeze_options` - List of options to pass `pip freeze`.  Default = []

### py_run

Executes a Python script from the selected environment

```
py_run "/home/myuser/py3project/test_script.py" do
  py_binary "/home/myuser/py3project/py3venv/bin/python"
  pythonpath "/home/myuser/additional_py3_libs/:/home/anotheruser/more_py3_libs/"
  script_args ["arg1", "arg2", "arg3"]
end
```

#### Actions
* `:run` - Executes a Python script from an environment with the specified arguments and options. *(default)*

#### Properties
* `py_script` - Location of Python script to run. *(name property)*
* `py_binary` - Location of Python binary to use. Default = "/usr/bin/python"
* `py_args` - List of arguments to pass to Python binary.  Default = []
* `script_args` - List of arguments to pass to Python script.  Default = []
* `pythonpath` - Sets $PYTHONPATH environment variable when executing script.  Default = ""

## Usage

First, ensure that the base system packages are installed by including the 'chef_python::default' recipe in the node's `run_list`:
```json
{
  "name":"my_node",
  "run_list": [
    "recipe[chef_python]"
  ]
}
```

Then, to use `chef_python` custom resources in your own cookbooks, edit your `metadata.rb` file and add the following:
```
depends 'chef_python'
```

It is **STRONGLY** encouraged that you utilize [virtual environments](https://realpython.com/python-virtual-environments-a-primer/) for most, if not all of your Python tasks.  Packages, user libraries, and scripts should be installed and run from isolated environments.  See above for examples on how to do this, as well as the `chef_python::py_tests` recipe.


## Author(s)
* Garrett Anderson
