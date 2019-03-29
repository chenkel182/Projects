from vsts.vss_connection import VssConnection
from msrest.authentication import BasicAuthentication
import os
from git import Repo

COMMITS_TO_PRINT = 1

# Fill in with your personal access token and org URL
personal_access_token = 'token'
organization_url = 'url'

# Create a connection to the org
credentials = BasicAuthentication('', personal_access_token)
connection = VssConnection(base_url=organization_url, creds=credentials)

# Get a client (the "core" client provides access to projects, teams, etc)
core_client = connection.get_client('vsts.core.v4_0.core_client.CoreClient')

# Get the list of projects in the org
projects = core_client.get_projects()


def print_commit(commit):
    print('----')
    print(remote_branches), str(commit.authored_datetime)
   #  print(str(commit.hexsha))
   # print("\"{}\" by {} ({})".format(commit.summary,
   #                                  commit.author.name,
   #                                 commit.author.email))
   #  print(str("count: {} and size: {}".format(commit.count(),
   #                                           commit.size)))


def print_repository(repo):
    print('Repo active branch is {}'.format(repo.active_branch))
    for remote in repo.remotes:
        print('Remote named "{}" with URL "{}"'.format(remote, remote.url))
    print('Last commit for repo is {}.'.format(str(repo.head.commit.hexsha)))


def get_branches(repo):
    # pull list of branches into an array
    remote_branches = []
    for ref in repo.git.branch('-r').split('\n'):
        #     print(ref)
        remote_branches.append(ref)


if __name__ == "__main__":
    repo_path = os.getenv('GIT_REPO_PATH')
    # Repo object used to programmatically interact with Git repositories
    repo = Repo(repo_path)
    # check that the repository loaded correctly
    if not repo.bare:
        print('Repo at {} successfully loaded.'.format(repo_path))
        print_repository(repo)
        # create list of commits then print some of them to stdout
        commits = list(repo.iter_commits('master'))[:COMMITS_TO_PRINT]
        commits_b = list(repo.iter_commits(repo.active_branch))[:COMMITS_TO_PRINT]
        for commit in commits:
            print_commit(commit)
        for commit in commits_b:
            print_commit(commit)
            pass
    else:
        print('Could not load repository at {} :('.format(repo_path))
