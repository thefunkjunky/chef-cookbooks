import requests
import json
import argparse

def get_repos(args):
  """Searches an organization and returns a list of every repository
  with a Jenkinsfile present."""
  page = 0
  all_repos = []
  while True:
    page += 1
    url = "{}/orgs/{}/repos?page={}&per_page=100".format(args.ghe_api, args.org, page)
    repos = requests.get(url, headers=args.headers).json()
    if repos == []:
      break
    all_repos.extend(repos)

  valid_repos = []
  for repo in all_repos:
    contents_url = repo["contents_url"].replace("{+path}", "")
    r = requests.get(contents_url, headers=args.headers)
    if any([file["name"] for file in r.json() if file["name"] == "Jenkinsfile"]):
      valid_repos.append(repo)
  return valid_repos

def set_branch_protection(args, repos):
  """Sets protections and status checks for the master branch
  of every repository in a given list."""
  protection_payload = {
    "required_status_checks": {
      "strict": True,
      "contexts": [
        "continuous-integration/jenkins/pr-merge"
      ],
      "include_admins": True,
    },
    "required_pull_request_reviews": {
      "dismissal_restrictions": {},
      "require_code_owner_reviews": True,
      "include_admins": True
    },
    "restrictions": None
  }
  for repo in repos:
    master_branch_url = repo["branches_url"].replace(
      "{/branch}", "/master")
    protection_url = master_branch_url + '/protection'
    protection_update = requests.put(
      protection_url,
      headers=args.branches_headers,
      data=json.dumps(protection_payload))
    if protection_update.status_code != 200:
      raise Exception("Failed to update branch protections "\
        "on repo {}:\n\"{}\"".format(
          repo["html_url"], protection_update.content))

def set_repo_labels(args, repos):
  """Sets up repo labels."""
  labels = [
    {
      "color": "b60205",
      "name": "Changes Requested"
    },
    {
      "color": "0e8a16",
      "name": "Ready for 2nd Review"
    },
    {
      "color": "fbca04",
      "name": "Need 2 Reviews"
    },
    {
      "color": "d93f0b",
      "name": "Wait for CHG"
    }
  ]
  for repo in repos:
    labels_url = repo["labels_url"].replace(
      "{/name}", "")
    labels_get_request = requests.get(
        labels_url,
        headers=args.headers
        )
    repo_labels = labels_get_request.json()
    for label in labels:
      # If label already exists, update instead of add
      existing_label = [repo_label for repo_label in repo_labels
                        if repo_label["name"] == label["name"]]
      if existing_label:
        label_mod_request = requests.patch(
          existing_label[0]["url"],
          headers=args.headers,
          data=json.dumps(label))
      else:
        label_mod_request = requests.post(
          labels_url,
          headers=args.headers,
          data=json.dumps(label))
      if label_mod_request.status_code not in [200, 201]:
        raise Exception("Failed to add label {} "\
          "on repo {}:\n\"{}\"\nStatus: {}\n".format(
            label["name"],
            repo["html_url"],
            label_mod_request.content,
            label_mod_request.status_code))

def main():
  """Main function for set-repo-settings"""
  parser = argparse.ArgumentParser(
    description="Searchs a GHE organization for repos with a Jenkinsfile, and "\
    "sets branch protection status checks on them.")
  parser.add_argument("--ghe_api", type=str, required=True,
    help="URL of the GHE api. Typically 'https://[GHE domain]/api/v3")
  parser.add_argument("--org", type=str, required=True,
    help="Name of GHE organization")
  parser.add_argument("--token", type=str, required=True,
    help="GHE access token")
  args = parser.parse_args()

  args.headers = {'Authorization': 'token {}'.format(args.token)}
  args.branches_headers = {
    'Authorization': 'token {}'.format(args.token),
    'Accept': 'application/vnd.github.loki-preview+json'
    }

  valid_repos = get_repos(args)
  if valid_repos:
    set_branch_protection(args, valid_repos)
    set_repo_labels(args, valid_repos)
  else:
    raise Exception("No valid repositories found in GHE organization {}".format(
      args.org))

if __name__ == '__main__':
  main()
