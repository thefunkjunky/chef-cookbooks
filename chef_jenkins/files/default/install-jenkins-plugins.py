import os.path
import copy
import argparse
import json
import urllib
import random
from distutils.version import LooseVersion

def is_higher_version(v1, v2):
  """Compares 2 version strings and returns True if the first is higher."""
  is_higher = LooseVersion(v1) > LooseVersion(v2)
  return is_higher

def plugin_version_check(to_install, plugin, version, deps):
  """Determines if a plugin with pinned version # should be installed.
  In the event of a version conflict, this will default to the higher
  version number."""
  if plugin in deps["all_versions"]["plugins"]:
    if (plugin not in to_install) or \
    (to_install[plugin] and is_higher_version(version, to_install[plugin])):
      return True
  else:
    return False

def load_deps():
  """Loads the Jenkins Plugins update-center.json and plugin-versions.json
  into a deps dictionary."""
  deps = {}
  urllib.urlretrieve(
    "https://updates.jenkins.io/current/update-center.actual.json",
    "jenkins-update-center.json")
  urllib.urlretrieve(
    "https://updates.jenkins.io/current/plugin-versions.json",
    "jenkins-plugin-versions.json")
  print("Finished downloading Jenkins Plugins Update Center.")
  with open("jenkins-update-center.json", "r") as update_file:
    deps["current_updates"] = json.load(update_file)
  with open("jenkins-plugin-versions.json", "r") as version_file:
    deps["all_versions"] = json.load(version_file)
  return deps

def current_deps(plugins, deps):
  """Generates a list of plugins and plugin dependencies to install,
  based on the most current versions of the plugins."""
  to_install = plugins[:]
  all_plugins = {}
  while to_install:
    plugin = to_install.pop()
    if plugin not in deps["current_updates"]["plugins"]:
      continue
    plugin_version = deps["current_updates"]["plugins"][plugin]["version"]
    all_plugins[plugin] = plugin_version
    dependencies = deps["current_updates"]["plugins"][plugin]["dependencies"]
    deps_list = [plugin["name"] for plugin in dependencies
                  if plugin["name"] not in to_install and
                  plugin["name"] not in all_plugins.keys() and
                  plugin["name"] in deps["current_updates"]["plugins"]
                ]
    to_install.extend(deps_list)
  return all_plugins

def pinned_deps(plugins, deps):
  """Generates a list of plugins, plugin dependencies, and corresponding
  version numbers to install; based upon a dict of plugins and their
  dependencies with pinned version numbers.  In the event of a version conflict,
  this will default to the higher version number."""
  to_install = copy.deepcopy(plugins)
  all_plugins = {}
  deps_truncated = {}

  while to_install:
    plugin = random.choice(to_install.keys())
    plugin_version = to_install.pop(plugin)
    if plugin_version_check(all_plugins, plugin, plugin_version, deps):
      all_plugins[plugin] = plugin_version
    else:
      continue

    dependencies = deps["all_versions"]["plugins"][plugin][plugin_version]["dependencies"]
    for dependency in dependencies:
      name = dependency["name"]
      version = dependency["version"]
      if plugin_version_check(to_install, name, version, deps):
        to_install[name] = version

  return all_plugins

def compare_manifest(to_install, manifest):
  """Compares a dict of plugins to be installed against a manifest of
  plugins already installed, and removes any that are on the manifest and of
  an equal or lower version #."""
  trimmed_plugins = copy.deepcopy(to_install)
  for plugin, version in to_install.iteritems():
    if plugin in manifest:
      if is_higher_version(version, manifest[plugin]):
        continue
      else:
        trimmed_plugins.pop(plugin)
  return trimmed_plugins

def download_deps(all_plugins, download_dir):
  """Downloads given plugins to the plugins directory."""
  for plugin, version in all_plugins.iteritems():
    url = "https://updates.jenkins-ci.org/download/plugins/{plugin}/{version}/{plugin}.hpi".format(plugin=plugin, version=version)
    plugins_dir = "{}/{}.hpi".format(download_dir, plugin).replace("//", "/")
    urllib.urlretrieve(url, plugins_dir)

def main():
  parser = argparse.ArgumentParser(
    description="Finds Jenkins plugins and dependencies, and installs them.")
  parser.add_argument("--plugins_json", type=str, required=True,
    help="Location of JSON of plugins to be installed.")
  parser.add_argument("--plugins_dir", type=str, default="/var/lib/jenkins/plugins",
    help="Location of Jenkins plugins directory.")
  parser.add_argument("--manifest", type=str, default="/var/lib/jenkins/plugins/manifest.json",
    help="Location of installed plugins manifest JSON.")
  args = parser.parse_args()
  with open(args.plugins_json, "r") as plugins_json:
    plugins = json.load(plugins_json)
  download_dir = args.plugins_dir

  plugins_current = []
  plugins_pinned = {}

  for plugin, version in plugins.iteritems():
    if version == "":
      plugins_current.append(plugin)
    else:
      plugins_pinned[plugin] = version

  print("Downloading Jenkins Plugins Update Center...")
  deps = load_deps()
  print("Generating list of plugins to install...")
  all_plugins = pinned_deps(plugins_pinned, deps)
  all_plugins.update(current_deps(plugins_current, deps))
  try:
    with open(args.manifest, "r") as manifest_file:
      manifest = json.load(manifest_file)
      print("Comparing against existing plugins...")
      trimmed_plugins = compare_manifest(all_plugins, manifest)
  except:
    trimmed_plugins = all_plugins
  if not trimmed_plugins:
    print("No plugins to install.")
    with open("/opt/jenkins-plugin-installer/last_action.log", "w") as f:
      f.write("No plugins installed.")
    exit()
  formatted_plugins = json.dumps(trimmed_plugins, indent=2, sort_keys=True)
  print("Installing the following plugins: {}".format(formatted_plugins))
  with open("/opt/jenkins-plugin-installer/last_action.log", "w") as f:
    f.write("Installed plugins.")
  download_deps(trimmed_plugins, download_dir)
  print("Writing manifest...")
  try:
    with open(args.manifest, "r+") as manifest:
      manifest_json = json.load(manifest)
      manifest_merged = manifest_json.update(trimmed_plugins)
      json.dump(manifest_merged, manifest)
  except:
    with open(args.manifest, "w") as manifest:
      json.dump(trimmed_plugins, manifest)
  print("All plugins installed.")

if __name__ == '__main__':
  main()
