# GDS-Github-Trello
[![Build Status](https://travis-ci.org/emmabeynon/gds-github-trello.svg?branch=master)](https://travis-ci.org/emmabeynon/gds-github-trello)

## Overview
App that queries Github’s API to look at alphagov’s PRs, and when a link to a Trello card is mentioned in the PR, post a message to the team’s Trello board, with the reference of the PR.

## User Stories
```
As a GOV.UK developer

So that I can make sure that the Trello card I am working on has the correct PR information

I would like a link to relevant PRs to be automatically added to the Trello card.
```

## Log
**22/04/16**
- Set up Gemfile with Sinatra, RSpec and Capybara gems
- Added Octokit gem for interaction with the GitHub API
- Set up a Trello board

**29/04/16**
- Added Dotenv gem to maintain secret keys
- Created tests to authenticate API, fetch alphagov repos and fetch pull requests
- Created GitHubPrScraper class to manage interaction with GithHub API

**05/05/16**
- Fixed Octokit pagination so that all repos are retrieved
- Set up Travis CI

**09/05/16**
- Github API is mocked using let statements
- Now able to fetch a list of commits from each open pull request

**16/05/16**
- Fetch pull requests method changed to use Github search to grab all open pull requests on Alphagov, which has sped up the interaction with the API
- Fetch commits method has been altered to work with the new fetch pull requests method
- Fetch repos has been removed as it's now redundant

**01/06/16**
- Method created to filter commits for links to Trello cards
- Currently using two data structures - one to store all PR URLs and commit body, and one to store PR URLs filtered by those containing a Trello card URL in the commit body.  Unsure at this point whether the combine the two, but will see how the code develops.

**03/06/16**
- Added ruby-trello gem to interact with the Trello API
- Trello is authenticated using basic authentication - struggling to make it work using OAuth currently.
- Set up a dummy Github organisation for testing
- Changed feature tests to work with dummy Github organisation

**10/06/16**
- Trello cards can now be accessed via the API using a unique card ID
- Method created to check for the presence of a Pull Requests checklist on a given card
- If a Pull Requests checklist is present, its id is stored in an array

**14/06/16**
- A Pull requests checklist is created if one is not already present.

**15/06/16**
- Added functionality to post a GitHub PR URL to a Pull Requests checklist.

**17/06/16**
- TrelloPoster is now injected as a dependency in the GitHubPrScraper class
- GitHubPrScraper iterates through prs_and_trello_card_ids and creates an instance of the TrelloPoster class to post the PR URL to the Trello card

**04/07/16**
- TrelloPoster and GitHubPrScraper classes refactored to reduce dependency on each other
- Added functionality to check if a given PR URL is already in the Pull Requests checklist.  If it is, then it will not be posted again.
- Implemented Sinatra

**15/07/16**
- Implemented a webhook that listens for changes to pull requests e.g. being opened, being closed, being edited, and creates an instance of the GitHubPrScraper class after receiving a payload from Github
- This has required a reworking of the GitHubPrScraper class to deal with single pull requests, as opposed to the previous implementation that scraped all open pull requests from an organisation.  Consequently, the name of this class has been changed to GitHubPullRequest.
- GitHub API tests have been removed as this is covered by the pr_poster feature tests

**22/07/16**
- Removed Trello API specs as this is covered by the unit tests and pr_poster feature tests
- Not sure how to test posting to Trello (#post_github_pr_url), as the API is mocked

**29/07/16**
- Pull request item checkbox on the Trello card 'Pull Requests' checklist is checked once a pull request has been merged.

#### Next:
- Set up OAuth for Trello
- Get app on PaaS
