chef_jenkins Cookbook
====================
Cookbook for the Jenkins server.  This will scan a Github org for presence of repos with a `Jenkinsfile`, configure their Github repositories for webhooks and master branch protection, create jobs for PRs and merge requests, and runs the pipeline called from the shared pipeline library.

Requirements
------------

#### cookbooks
- `jenkins` - Used to add Jenkins secrets from the command line.
- `chef_python` - Used to install and run python scripts along with their dependencies

## Attributes
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['plugins']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>JSON.parse(plugins_json)</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['pipelines_json']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'/../files/default/pipelines.json'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['pipelines']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>JSON.parse(pipelines_json)</tt></td>
  </tr>
  <tr>
    <td><tt>default['jenkins']['master']['version']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'2.138.1-1.1'</tt></td>
  </tr>
  <tr>
    <td><tt>default['jenkins']['executor']['timeout']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>240</tt></td>
  </tr>
  <tr>
    <td><tt>default['jenkins']['master']['port']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>8080</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['jre']['package']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'jdk'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['jre']['version']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'1.7.0_80-fcs'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['email']['reply_to']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'whatever@whatever.com'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['pipeline']['aws']['key_pair']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'whatever'</tt></td>
  </tr>
  <tr>
    <td><tt>default['jenkins']['master']['home']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'/var/lib/jenkins'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['jenkins']['plugins_dir']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'/var/lib/jenkins/plugins'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['jenkins']['num_executors']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>5</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['jenkins']['max_item_age']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>90</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['github']['server']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'www.github.com'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['github']['endpoint']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>"https://#{node['chef_jenkins']['github']['server']}/api/v3"</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['github']['credentials']['name']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'github-creds'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['slack']['webhook']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'https://hooks.slack.com/services/ABCD1234'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['slack']['id']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'slack-id'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['metrics_key']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'vwipjJrw0rrK6xVvLutC8jUqw9JEHZepwbRuyIZRCkLLPsSiR9XR3u4BnHpU9v2W'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['jenkins']['url']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'https://jenkins.myserver.com/'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_jenkins']['secrets']['path']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>"#{node['jenkins']['master']['home']}/.secrets"</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_client']['interval']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'1800'</tt></td>
  </tr>
  <tr>
    <td><tt>default['chef_client']['splay']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>'300'</tt></td>
  </tr>
</table>

Usage
-----
#### chef_jenkins::default

Update any attributes you might need and include `chef_jenkins::default` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[chef_jenkins::default]"
  ]
}
```

This will build a jenkins master server as needed.  

When being in a testing environment without a real world/routable IP, you may need to SSH forward through a jumphost.

`ssh -A -L 8080:<instance_ip>:8080 -N jumphost.mydomain.com`
This will map to http://localhost:8080 on your local machine.

#### Organization Jobs/Shared Pipeline Library configuration JSON
This is a JSON file used to set up each organization job and shared pipeline library.  It is a list of hash objects in the following manner:
```json
[
  {
    "name": "Jenkins test pipeline",
    "ghe_org": "jenkins-test",
    "credentials_name": "chef-pipeline",
    "polling": 1800000,
    "max_item_age": 90,
    "shared_pipeline_repo": "pipeline",
    "shared_pipeline_name": "pipeline",
    "shared_pipeline_id": "146953ab-c197-446a-a61a-b1aa8f46c34e"
  },
  {
    "name": "Test deployments pipeline",
    "ghe_org": "test-deployments",
    "credentials_name": "chef-pipeline",
    "polling": 1800000,
    "max_item_age": 90,
    "shared_pipeline_repo": "pipeline",
    "shared_pipeline_name": "deploy_pipeline",
    "shared_pipeline_id": "146953ab-d201-446a-a61a-b1aa8f46c34e"
  }
]
```
Note that the `ghe_org`, `shared_pipeline_name`, and `shared_pipeline_id` for each entry needs to be unique.

#### Pipelines
These are configured in each organization's shared pipeline library and called by the repository's `Jenkinsfile`.

#### Plugins
This cookbook and pipeline depends on a number of Jenkins plugins for its functionality.  Included is a python tool `install-jenkins-plugins.py`; which downloads, installs, and manages Jenkins plugins along with their dependencies.  It reads from a JSON of "key": "value" pairs, where the "key" is the plugin name, and the "value" is the pinned version number.  If the value string is left empty, it will find the most recent versions of the plugin along with its dependencies.  If the version is pinned, it will also pin the plugin's dependencies; however any version conflicts will default to the most recent version of the bunch.

The `plugins.json` provided originated from the smaller, unpinned list `plugins_unpinned.json`.  The script was run on the latter, and the manifest file of all the plugins, dependencies, and version #s was used as the source of truth for the cookbook.  

To update or add plugins, run the tool against an unpinned JSON, and copy the contents of the generated manifest file to `files/default/plugins.json`.

Run `$ python install-jenkins-plugins.py --help` for more information.

#### Caveats and manual necessities
Although this cookbook is designed to have as much automatically handled by the first chef-client run as possible, there remains some elements which must be handled manually:

- Organization/Job scan - The primary Github organization job generator is configured to automatically run every polling period found in `node['chef_jenkins']['jenkins']['polling']`.  However, if this period is too long to wait for, or this cookbook is being run on a fresh instance, it is quicker to simply go the the Jenkins web portal, click on the organization job, and click "Scan organization".

- Branch protection - This cookbook contains a python script that scans the target Github organization and updates every eligible repository to have master branch protection. However, the Github API doesn't allow this API call on a repo that has never had branch protections set before, as fresh repos will return a `nil` type instead of a blank list ("[]") and fail the API call.  To fix this, turn branch protections on the repo from the UI, and then turn them off (or just leave them on).  So long as they were turned on once, the API request will work.  I know this is dumb, but this is how Github made it.

- Webhooks - Jenkins has been configured to automatically create the necessary webhooks for every eligible repo it finds.  However, it doesn't REMOVE older webhooks.  If the Chefbuild Jenkins URL is changed, new webhooks will have to be automatically generated, and the old ones manually removed.

- Jenkins Upgrades - due to strange Jenkins behavior affecting the config.xml file, the config.xml on the existing node must be deleted BEFORE applying/converging a new Jenkins version!  Jenkins somehow modifies this file in a way that causes the Jenkins server to restart every chef-client run, and I can't figure out exactly how it's being changed.

## Authors:
- Garrett Anderson
