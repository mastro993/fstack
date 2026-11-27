# Trackers and code hosts

Commands for each place an issue or a PR can live. Read the parts for this issue's tracker and code host, and confirm the tool works (its auth check) before the first real call.

Contents: [Identify the tracker](#identify-the-tracker) · [When they differ](#when-the-tracker-and-the-code-host-differ) · [GitHub](#github) · [GitLab](#gitlab) · [Jira](#jira) · [Linear](#linear) · [Azure DevOps](#azure-devops) · [Gitea and Forgejo](#gitea-and-forgejo) · [Bitbucket](#bitbucket) · [Anything else](#anything-else)

## Identify the tracker

| Reference | Tracker |
| --- | --- |
| A URL | Its host: github.com, gitlab.com or a self-managed GitLab, `<site>.atlassian.net`, linear.app, dev.azure.com, a Gitea or Forgejo host. |
| `#123`, `<owner>/<repo>#123`, a bare number | The code host's own tracker (the git remote's host), unless the project says it tracks work elsewhere. On Azure Repos a bare number is a work item ID. |
| `ABC-123` | A key-based tracker: usually Jira or Linear (also YouTrack and others). Settle which from the project's docs (README, CONTRIBUTING, AGENTS.md), the repo's autolinks (`gh api repos/<owner>/<repo>/autolinks`), recent PR titles and branch names, or the tool that finds the key. `GL-123` is a GitLab issue. |
| `AB#123` | Azure Boards, referenced from GitHub. |

## When the tracker and the code host differ

Read the issue, its links, and its comments on the tracker; branch, push, and open the PR on the code host. Link the two with the issue key in the branch name and the PR title, and the issue's URL in the PR body. A keyword closes the issue on merge only where an integration does it (Linear's magic words, `Fixes AB#123` for Azure Boards, a Jira automation or Smart Commits); otherwise the tracker's own workflow moves it. To resume, search the code host's open PRs and branches for the key.

## GitHub

Tools: `gh` CLI. Check it with `gh --version` and `gh auth status`. gh takes the repo from the git remote; override it with `-R <owner>/<repo>`.
MCP: a host or harness may offer its own issue and PR tools. `gh` works everywhere, so prefer it.
API: `gh api repos/<owner>/<repo>/...` for REST and `gh api graphql -f query=...` for GraphQL. Both use gh's auth.

| Need | How |
| --- | --- |
| Reference | `#<n>`, `<owner>/<repo>#<n>`, `GH-<n>`, or `https://github.com/<owner>/<repo>/issues/<n>`. Issues and PRs share one number space per repo. |
| Read | `gh issue view <n> -R <owner>/<repo> --json number,title,body,state,stateReason,url,assignees,comments,parent,subIssues,subIssuesSummary,blockedBy,closedByPullRequestsReferences`. For threads over 100 comments, use `gh api --paginate repos/<owner>/<repo>/issues/<n>/comments`. |
| Blocked by | Link types are "blocked by" and "blocking". Run `gh issue view <n> -R <owner>/<repo> --json blockedBy`. Every node in `.blockedBy.nodes` must be `CLOSED`, and the node count must match `.blockedBy.totalCount`. Also scan the body for plain-text "Depends on #<n>" lines. |
| Parent or children | Run `gh issue view <n> -R <owner>/<repo> --json parent,subIssues,subIssuesSummary`. It is a parent when `subIssuesSummary.total > 0` and a child when `parent` is non-null. Fallbacks: a `- [ ] #<n>` task list in the body, or an epic or tracking label. |
| Existing PR | Run `gh issue view <n> -R <owner>/<repo> --json closedByPullRequestsReferences` (open PRs only). Then run `gh pr list -R <owner>/<repo> --state open --search "<n> in:body" --json number,headRefName,isDraft,url,body` and confirm the body really references the issue. Also run `gh issue develop --list <n> -R <owner>/<repo>`. |
| Assign | `gh issue edit <n> -R <owner>/<repo> --add-assignee @me`. `@me` is the account gh is signed in as, and `--add-assignee` keeps the existing assignees. Assigning needs triage or write access. |
| Link and close | Put `Closes #<n>` in the PR body. `Fixes` and `Resolves` also work, and `Fixes <owner>/<repo>#<n>` works across repos. Each issue needs its own keyword: `Closes #1, closes #2`. It only works when the PR targets the default branch, and a repo can turn auto-close off (Settings > General > Issues). `Refs #<n>` mentions the issue without closing it. |
| Open as draft | `git push -u origin HEAD`, then `gh pr create --draft --title "<title>" --body-file <body.md> --base <default-branch>`. Later, `gh pr ready <n>` marks it ready. |
| Edit description | `gh pr view <n> --json body --jq .body > <body.md>`, edit the file, then `gh pr edit <n> --body-file <body.md>`. This replaces the whole body. |
| PR template | `pull_request_template.md` in `.github/`, the root, or `docs/`, or a `PULL_REQUEST_TEMPLATE/` directory there. `gh pr create --body-file` doesn't apply it, so fill it into the body file. |
| Ready, checks, merge | `gh pr ready <n>`. Checks: `gh pr checks <n> --json name,bucket` and `gh pr view <n> --json reviewDecision,mergeStateStatus`. Merge through the pr-ship skill (`gh pr merge <n> --squash --match-head-commit <sha>`). |

Pitfalls:
- `gh issue view <owner>/<repo>#<n>` fails with `invalid issue format`, so use `gh issue view <n> -R <owner>/<repo>` or the full URL.
- `gh issue view <n>` on a PR number does not fail and returns the PR, so check that `url` contains `/issues/` and not `/pull/` before you treat it as the issue.
- gh `--json` lists are cut off (comments at 100, blockedBy at 50, subIssues at 100). Compare against `totalCount` where it exists, and treat exactly 100 comments as cut off. Their nodes have no `repository` key, so take a cross-repo item's `<owner>/<repo>` from its `url`.
- `closedByPullRequestsReferences` only shows open PRs that use a closing keyword and target the default branch, so a PR into another branch or one that only says `Refs #<n>` needs the `gh pr list --search` fallback.
- `gh pr create --body-file` does not apply the repo's PR template, and without `--title` plus a body flag gh prompts and hangs, so fill the template into the body file yourself.

## GitLab

Tools: `glab`. Check it with `glab auth status`, which exits non-zero when you are not logged in. On self-managed GitLab, set `GITLAB_HOST` or pass `--hostname <host>`.
MCP: GitLab's own MCP server at `https://<host>/api/v4/mcp`. It needs an `mcp`-scoped OAuth token or a fine-grained PAT, because legacy PATs get a 403.
API: REST `https://<host>/api/v4`, through `glab api`, which fills in `:fullpath` from the repo. GraphQL is at `/api/graphql` and is the only non-deprecated way to list an item's children.

| Need | How |
| --- | --- |
| Reference | Issues: `#<n>`, `<group>/<project>#<n>`, or URLs `.../-/issues/<n>` and `.../-/work_items/<n>`. MRs use `!<n>`. Epics use `&<n>`. `GL-<n>` is a GitLab issue too. |
| Read | `glab issue view <n\|URL> -R <group>/<project> -c -P 100 -F json`. With MCP: `get_work_item` with `include: ["notes"]`. |
| Blocked by | `glab api projects/:fullpath/issues/<n>/links`. Keep items with `link_type == "is_blocked_by"`. Each is done when its `state == "closed"`. It may be in another project, so check `project_id` and `web_url`. Blocking links need Premium or Ultimate. On Free, read "blocked by #n" in the description. |
| Parent or children | `glab api graphql -f query='query { namespace(fullPath:"<group>/<project>") { workItem(iid:"<n>") { workItemType { name } widgets { ... on WorkItemWidgetHierarchy { hasChildren children(first:100) { nodes { iid state webUrl } } } } } } }'`. It is a parent if the type is `Epic` or `hasChildren` is true. For a group epic, use the group's path. |
| Existing PR | `glab mr list -s <branch> -F json` (open MRs by default). Or run `glab api projects/:fullpath/issues/<n>/related_merge_requests` and keep `state == "opened"`. With MCP: `get_work_item` with `include: ["related_merge_requests"]`. |
| Assign | `glab issue update <n> -R <group>/<project> --assignee +@me`. The `+` adds to the assignees; a bare name replaces them all. The docs don't list `@me`, so if glab refuses it, pass `+<username>` from `glab api user --jq .username`. With MCP: your id from `get_user` with `me: true`, then `save_work_item` with `assignee_ids` set to the current ids plus yours, since it replaces the list. |
| Link and close | `Closes #<n>` (`Fixes`, `Resolves` and `Implements` also work). Use `Closes <group>/<project>#<n>` for another project, and `Related to #<n>` to link without closing. It closes only on merge into the default branch. Each project can turn this off, and self-managed admins can change the keyword pattern. |
| Open as draft | `glab mr create --draft -s <branch> -b <default-branch> -t "<title>" --description-file <file> -y`. MCP `save_merge_request` has no draft field, so start the title with `Draft:`. |
| Edit description | `glab mr update <mr-iid> --description-file <file>`. This replaces the whole body. With MCP: `save_merge_request` with `merge_request_iid` and `description`. |
| MR template | `.gitlab/merge_request_templates/<name>.md`; `Default.md` is the default unless project settings name another. glab doesn't apply it, so fill it into the description file. |
| Ready, checks, merge | `glab mr update <iid> --ready`. Checks: `glab mr view <iid> -F json` (`detailed_merge_status`, `head_pipeline.status`). Merge: `glab mr merge <iid> --squash --sha <head-sha> --yes`, which by default waits for checks to pass (`--auto-merge=false` merges now). |

Pitfalls:

- glab rejects `<group>/<project>#<n>` as an issue argument with `invalid issue format`, so pass the bare number with `-R <group>/<project>` or the full URL.
- Don't use `glab mr create --related-issue <n>`: without `-s` it makes a new branch from the target branch with none of your commits, and it adds a `Closes #<n>` that only resolves in the current project.
- `glab mr list` has no `--state` or `--json` flag, so use `-A`, `-c` or `-M` for other states and `-F json` for JSON.
- `glab api` switches to POST as soon as you pass any `-f` or `-F` field, so add `-X GET` when a read needs query fields.
- `glab issue view -c` shows only 20 comments per page by default, so raise `-P` or page through, or you will miss the latest maintainer comments.

## Jira

Tools: `acli` (official Atlassian CLI, Cloud): check with `command -v acli && acli jira auth status`. Alternative: `jira` (ankitpokhrel/jira-cli, Cloud and Data Center): check with `jira serverinfo`, not `jira me`.
MCP: Atlassian Rovo MCP server (`https://mcp.atlassian.com/v2/mcp`). Check that `getJiraIssue` is in the tool list, then call `getAccessibleAtlassianResources` to get the `cloudId` that every call needs.
API: `https://<site>.atlassian.net/rest/api/3` (Cloud, basic auth with email:token) or `https://<host>/rest/api/2` (Data Center, Bearer PAT). Jira holds the issue. The code host CLI (`gh`, `glab`) handles the PR.

| Need | How |
| --- | --- |
| Reference | Uppercase key `<KEY-123>` (regex `\b[A-Z][A-Z0-9_]+-[0-9]+\b`) or `https://<site>.atlassian.net/browse/<KEY-123>`. |
| Read | `acli jira workitem view <KEY-123> --json --fields '*all'` plus `acli jira workitem comment list --key <KEY-123> --json --paginate`, or `jira issue view <KEY-123> --comments 50 --plain`. MCP: `getJiraIssue(cloudId, issueIdOrKey, responseContentFormat="markdown")` plus `listJiraIssueComments(cloudId, issueIdOrKey)` (older servers: `executeRead(name="listJiraIssueComments", ...)`). |
| Blocked by | In `fields.issuelinks[]`, an entry with type `Blocks` and an `inwardIssue` means this issue is blocked by that one. It is done when `status.statusCategory.key == "done"`. Or run `acli jira workitem search --jql 'issue in linkedIssues("<KEY-123>", "is blocked by") AND statusCategory != Done' --json --fields key,summary,status` (MCP: `searchJiraIssuesUsingJql`). |
| Parent or children | `fields.issuetype.hierarchyLevel`: 1 is an epic, 0 is a story/task, -1 is a sub-task. The parent is in `fields.parent`. To list children: `acli jira workitem search --jql 'parent = <KEY-123>' --json --fields key,summary,status,issuetype` or `jira epic list <KEY-123> --plain`. |
| Existing PR | Search the code host by key: `gh pr list --state open --search "<KEY-123> in:title,body" --json number,title,headRefName,url,isDraft`, or `glab mr list --search <KEY-123> -F json`. Then check branches with `git ls-remote --heads origin '*<KEY-123>*'`. MCP alternative: `getTeamworkGraphContext` with `relationshipTypes: ["jira_work_item_links_external_pull_request"]`. |
| Assign | `acli jira workitem assign --key <KEY-123> --assignee "@me" --yes`, or `jira issue assign <KEY-123> "$(jira me)"`. MCP: your `accountId` from `atlassianUserInfo`, then `editJiraIssue` with `fields: { assignee: { accountId } }` (check the tool's schema first). API: `PUT /rest/api/3/issue/<KEY-123>/assignee` with `{"accountId": "<id>"}`, your id from `GET /rest/api/3/myself`. Jira holds one assignee, so this replaces whoever is there. |
| Link and close | Put the uppercase key in the branch name (`<KEY-123>-<slug>`), the commits and the PR title (`<KEY-123>: <summary>`). The body line is a link: `<KEY-123> · https://<site>.atlassian.net/browse/<KEY-123>`. Nothing closes Jira by default. Closing needs config: Smart Commits (`<KEY-123> #close` in a commit), workflow triggers, Automation, or GitLab's `Closes <KEY-123>` with "Enable Jira transitions" on and the default branch as target. |
| Open as draft | `gh pr create --draft --title "<KEY-123>: <summary>" --body-file <file>` or `glab mr create --draft --title "<KEY-123>: <summary>" --description "<body>"`. |
| Edit description | `gh pr edit <n> --body-file <file>` or `glab mr update <iid> --description "<body>"`. If you rename the PR, keep the key in the title. |

Pitfalls:

- On Rovo MCP v2, `listJiraIssueLinkTypes` and `listJiraIssueRemoteIssueLinks` are deferred tools: call them through the execute tool your client lists (`executeRead`, or a single `execute`), with `name` and a flat `inputs` object.
- `jira issue list -q '<JQL>'` silently adds `project=<configured project>` and its own ORDER BY, so it drops blockers and children in other projects; read `issuelinks` from `jira issue view <KEY-123> --raw` instead.
- Decide "done" by `statusCategory.key`, never by the status name, and also check custom link types such as "depends on" or "requires", not just `Blocks`.
- `Closes <KEY-123>` in a GitHub PR does nothing to Jira, and a key that is only in the PR description or written in lowercase does not link the PR to the issue.
- `acli jira workitem view` takes the key as a positional argument, but `comment` and `link` subcommands need `--key`, and the default view fields leave out comments, links, parent and subtasks.

## Linear

Tools: MCP: official remote server `https://mcp.linear.app/mcp`. The tool prefix depends on how it was registered (`mcp__linear-server__*`, `mcp__linear__*`, `mcp__claude_ai_Linear__*`). Check it works with `list_teams`.
CLI: Linear has no official CLI. Use community `linear` (schpet/linear-cli) only if it is already installed. PRs go through the code host: `gh auth status` or `glab auth status`.
API: GraphQL `POST https://api.linear.app/graphql` with header `Authorization: <API_KEY>` (no `Bearer`). Check it with `{ viewer { id name } }`.

| Need | How |
| --- | --- |
| Reference | `<KEY-123>` (team key, dash, number) or `https://linear.app/<workspace>/issue/<KEY-123>/<slug>`. |
| Read | MCP `get_issue({ id: "<KEY-123>", includeRelations: true })`, then `list_comments({ issueId: "<KEY-123>" })`. CLI: `linear issue view <KEY-123> --json`. |
| Blocked by | MCP `get_issue` with `includeRelations: true` returns `blockedBy`. GraphQL: blockers are the `inverseRelations` nodes with `type: blocks`, and the blocker is `.issue`. A blocker is done when its `state.type` is `completed` or `canceled`; through MCP, `get_issue` each blocker and map its status name to a type with `list_issue_statuses` for its team. |
| Parent or children | MCP `list_issues({ parentId: "<KEY-123>" })`: any result means a parent. GraphQL `issue(id: "<KEY-123>") { children { nodes { identifier state { type } } } }`. Linear has no epic type, and projects are not issues. |
| Existing PR | Linked PRs show up as attachments on the issue (`get_issue`, or GraphQL `attachments { nodes { url sourceType } }`). Check each one with `gh pr view <url> --json state,isDraft,headRefName` or `glab mr view <url>`. Fallback: `gh pr list --state open --search "<KEY-123>" --json number,url,headRefName`, or `gh pr list --head <branchName>` / `glab mr list --source-branch <branchName>` using the issue's suggested branch (`gitBranchName` through MCP, `branchName` in GraphQL). |
| Assign | MCP `save_issue({ id: "<KEY-123>", assignee: "me" })`, or your user id where its schema doesn't take `"me"`. GraphQL: `issueUpdate(id: "<KEY-123>", input: { assigneeId: "<viewer.id>" })`. An agent signed in as a Linear app user goes in `delegate` (`delegateId`), not the assignee, which stays the user. |
| Link and close | Put `Fixes <KEY-123>` in the PR title or description and the issue closes on merge. Other closing words: closes, resolves, completes, implements. `Part of <KEY-123>` or `Ref <KEY-123>` links without closing. This only works when the workspace has the GitHub or GitLab integration, and each team's automations decide the status moves. On GitLab the magic word goes in the MR description. |
| Open as draft | `gh pr create --draft --base <default> --head <branchName> --title "..." --body-file body.md`. GitLab: `glab mr create --draft --source-branch <branchName> --target-branch <default> --title "..." --description "..."` |
| Edit description | `gh pr edit <n> --body-file body.md`. GitLab: `glab mr update <id> --description "..."`. Keep the magic-word line, because Linear re-links when you save. |

Pitfalls:
- GraphQL has no `blocked_by` relation type, so reading only `relations` misses every blocker. Blockers are `inverseRelations` with `type: blocks`.
- Decide open or done from `state.type`, never from the state name, because teams rename their states.
- MCP tool names change over time (`save_comment` replaced `create_comment`), so read the live tool list before calling.
- Writing `<TEAM>-NEW` (like `ENG-NEW`) in a PR description creates a new Linear issue.
- Magic words in PR comments never link, and `Fixes <KEY-123>` closes nothing on GitHub's side.

## Azure DevOps

Tools: `az` CLI with the `azure-devops` extension. Check it with `az extension show --name azure-devops`. Check auth with `az devops project list --org https://dev.azure.com/<org> -o table` (sign in with `az login`, `az devops login`, or `AZURE_DEVOPS_EXT_PAT`). The CLI does not work on Azure DevOps Server (on-prem), so use REST there.
MCP: the official Azure DevOps server, `npx -y @azure-devops/mcp <org>` (microsoft/azure-devops-mcp). Its tools are action-based, such as `wit_work_item` and `repo_pull_request_write`.
API: `https://dev.azure.com/<org>/<project>/_apis/...?api-version=7.1`. Call it with `az rest --resource 499b84ac-1321-427f-aa17-267ca6975798 --url <url>` (uses the `az login` token) or `curl -u :$PAT`.

| Need | How |
| --- | --- |
| Reference | A numeric ID like `123`, unique across the whole org. A URL looks like `https://dev.azure.com/<org>/<project>/_workitems/edit/<id>`. In GitHub text it is `AB#123`, which works only when the repo is connected to Azure Boards. A bare `#123` means a work item only when the git remote is Azure Repos. |
| Read | `az boards work-item show --id <id> --org https://dev.azure.com/<org> -o json` (the default `--expand all` includes `relations[]`). Comments are separate: `az rest --resource 499b84ac-1321-427f-aa17-267ca6975798 --url "https://dev.azure.com/<org>/<project>/_apis/wit/workItems/<id>/comments?api-version=7.1-preview.4"`, paged with `continuationToken`. MCP: `wit_work_item` with action `get` or `list_comments`. |
| Blocked by | Blockers are the `relations[]` entries with `rel == "System.LinkTypes.Dependency-Reverse"` (Predecessor), or `System.LinkTypes.Remote.Dependency-Reverse` (Consumes From) across orgs. The ID is the last segment of `url`. Check each one with `az boards work-item show --id <b> --fields System.State,System.WorkItemType,System.TeamProject --expand none`. It is done when its state's category is `Completed` (from `GET .../_apis/wit/workitemtypes/<type>/states?api-version=7.1`), or `Resolved` with its linked PR (an `ArtifactLink`) completed into the default branch, since a merged PR only moves an item to Resolved. |
| Parent or children | `rel == "System.LinkTypes.Hierarchy-Forward"` (Child) means the item has children, and `Hierarchy-Reverse` is its one parent. An Epic or Feature with children is a parent. A Story or PBI with Task children can still be built. |
| Existing PR | In `relations[]`, look for `rel == "ArtifactLink"` with `attributes.name == "Pull Request"` (`"GitHub Pull Request"` on a GitHub host). URL-decode `url` and take the last `/` segment as the PR ID, then run `az repos pr show --id <pr>` and check that `status` is `active`. Or run `az repos pr list --repository <repo> --source-branch <branch> --status active -o json`. On a GitHub host: `gh pr list --search "AB#<id>" --state open`. |
| Assign | `az boards work-item update --id <id> --assigned-to "$(az account show --query user.name -o tsv)"`, the email of the `az login` identity (signed in with a PAT, use that account's email). A work item holds one assignee, so this replaces whoever is there. |
| Link and close | Azure Repos: the body line is the work item URL; link with `--work-items <id>` on `az repos pr create` (or later with `az repos pr work-item add --id <pr> --work-items <id>`). Add `--transition-work-items true` to move linked items to their next state (for example Active to Resolved) when the PR completes. The repo setting "Commit mention work item resolution" (default On) can turn this off. GitHub: put `Fixes AB#<id>` in the PR description. It moves the item to Resolved, or to Completed if the process has no Resolved state, and only when the PR merges into the default branch. |
| Open as draft | First `git push -u origin <branch>`, then `az repos pr create --repository <repo> --source-branch <branch> --title "<title>" --description "$(cat body.md)" --work-items <id> --transition-work-items true --draft true -o json`. MCP: `repo_pull_request_write` with action `create`, `isDraft: true`, and `sourceRefName: "refs/heads/<branch>"`. |
| Edit description | `az repos pr update --id <pr> --description "$(cat body.md)"`. Read the current body first with `az repos pr show --id <pr> --query description -o tsv`. MCP: `repo_pull_request_write` with action `update`. The service caps descriptions at 4000 characters: past that, keep the checklist and status there and move Decisions, Deviations, and Follow-ups into a PR comment (PR comment row) that the body links to. |
| PR comment | No `az repos pr` subcommand: `az rest --resource 499b84ac-1321-427f-aa17-267ca6975798 --method post --url "https://dev.azure.com/<org>/<project>/_apis/git/repositories/<repo>/pullRequests/<pr>/threads?api-version=7.1" --body '{"comments":[{"content":"<text>"}],"status":"active"}'`. MCP: `repo_create_pull_request_thread`. |
| PR template | `pull_request_template.md` in `.azuredevops/`, `.vsts/`, `docs/`, or the root, with branch-specific ones under `pull_request_template/branches/`. The CLI doesn't apply it, so fill it into the description. |
| Ready, checks, merge | `az repos pr update --id <pr> --draft false`. Checks: `az repos pr policy list --id <pr> -o json` (each policy's `status`). Merge: `az repos pr update --id <pr> --auto-complete true --squash true` completes it once every policy passes. |

Pitfalls:
- `az boards work-item show` defaults to `--expand all`, so `--fields` without `--expand none` fails with "The expand parameter can not be used with the fields parameter."
- `az boards work-item show` has no `--project` flag and returns no comments, but the comments and states REST paths need the project, so read it from `fields["System.TeamProject"]`.
- Link names point one way: `Dependency-Reverse` (Predecessor) blocks this item, while `Dependency-Forward` (Successor) is an item this one blocks.
- `az repos pr list` returns only active PRs unless you pass `--status all`, and it cuts `description` to 400 characters, so read a PR body with `az repos pr show`.
- `AB#` links nothing in a PR title or comment, and `Fixes AB#1, AB#2` moves only AB#1, so give each item its own keyword.

## Gitea and Forgejo

Tools: CLI `tea`. Check it is installed with `tea --version`. Check auth with `tea login status -o json` (v0.16+) or `tea whoami`.
Raw REST calls go through `tea api <endpoint>` (v0.12+). It fills in `{owner}`/`{repo}` from the current repo. Forgejo has the same paths.
API base is `https://<host>/api/v1`. Send the header `Authorization: token <PAT>`.

| Need | How |
| --- | --- |
| Reference | `#<n>` or `<owner>/<repo>#<n>`. `!<n>` always means a PR. URL: `https://<host>/<owner>/<repo>/issues/<n>`. Issues and PRs share one number space. |
| Read | `tea issues <n> --comments -o json`. For cross-references and linked PRs: `tea api '/repos/{owner}/{repo}/issues/<n>/timeline?limit=50'` |
| Blocked by | `tea api '/repos/{owner}/{repo}/issues/<n>/dependencies'`. A blocker is done when its `state` is `"closed"`. Read `repository.full_name` because a blocker can be in another repo. A 404 means dependencies are off for this repo. |
| Parent or children | No native sub-issues or epics. Go by convention: a task list of `#<n>` refs in the body, an `epic`/`tracking` label, or many entries in `/dependencies`. |
| Existing PR | `tea pulls list --state open --fields index,title,head,base,url,body -o json`, then match the head branch, title, or body. Or check `pull_ref` events in the timeline. On Forgejo you can also filter: `tea api '/repos/{owner}/{repo}/pulls?state=open&head=<branch>'`. |
| Assign | `tea issues edit <n> --add-assignees "$(tea api /user \| jq -r .login)"`. Before tea 0.15, `--add-assignees` replaced the assignees, so on older versions pass the current ones too (from `tea issues <n> --comments=false -o json`). REST `PATCH /repos/{owner}/{repo}/issues/<n>` with `assignees` replaces the whole set. |
| Link and close | Put `Closes #<n>` (or `Fixes`/`Resolves`, or `<owner>/<repo>#<n>`) in the PR description. A plain `#<n>` only cross-links. Admins can change the keywords with `CLOSE_KEYWORDS`, and the issue closes on merge only if the person merging is allowed to close it. |
| Open as draft | `tea pulls create --head <branch> --base <default> --title '<title>' --description-file body.md --draft` |
| Edit description | `tea pulls edit <n> --description-file body.md`. Mark ready with `tea pulls edit <n> --ready`. |
| PR template | `PULL_REQUEST_TEMPLATE.md` or `pull_request_template.md` at the root or in `.gitea/`, `.github/`, or (Forgejo) `.forgejo/`. tea doesn't apply it, so fill it into the description file. |
| Ready, checks, merge | `tea pulls edit <n> --ready`. Checks and reviews: `tea pulls <n> --comments=false`. Merge: `tea pulls merge <n> --style squash`; to merge once checks pass, `tea api -X POST '/repos/{owner}/{repo}/pulls/<n>/merge' -f do=squash -F merge_when_checks_succeed=true`. |

Pitfalls:
- `--draft` only adds `WIP: ` to the start of the title, and the REST create body has no draft field, so when you change the title, keep the prefix until the PR is ready.
- Always pass `--comments` to `tea issues <n>`, or tea prompts about comments and stalls a headless run.
- `tea api /repos/{owner}/{repo}/pulls/<base>/<head>` also returns closed and merged PRs, so check that `state` is `"open"` and `merged` is false before you resume from one.
- `--description-file` needs tea 0.16.0 or later (older: `--description "$(cat body.md)"`), `--draft`/`--ready` 0.14.2, and `tea api` 0.12.0, so run `tea --version` first. tea 0.16 is its last release; Gitea 28 and later also ship `gt`.
- Gitea will not close an issue while its blockers are open, and will not merge a PR while the PR's own dependencies are open, so an open blocker stops the close as well as the work.

## Bitbucket

Tools: no `gh`-style CLI. Use the REST API 2.0 at `https://api.bitbucket.org/2.0` with an Atlassian API token: `-u "$EMAIL:$TOKEN"` or `-H "Authorization: Bearer $TOKEN"`. Check it with `curl -s -u "$EMAIL:$TOKEN" https://api.bitbucket.org/2.0/user`.
Atlassian's `twg` CLI has `twg bitbucket pull-requests create|get|query|update`. Check with `twg doctor` and `twg help describe`.
Bitbucket Cloud removed its issue tracker on 2026-08-20, so issues live in Jira. Use the Jira section (Atlassian Rovo MCP, Jira REST) for Read, Blocked by, and Parent.

| Need | How |
| --- | --- |
| Reference | An uppercase Jira key, `<KEY-123>`. Old `#<n>` issue links point at deleted issues. PR URL: `https://bitbucket.org/<workspace>/<repo>/pull-requests/<id>` |
| Read | In Jira, see the Jira section (`GET /rest/api/3/issue/<KEY-123>` or Rovo MCP). |
| Blocked by | Jira `Blocks` link type. A blocker is done when its `statusCategory` is Done. See the Jira section. |
| Parent or children | Jira's `parent` field (Epic, then Story/Task, then Sub-task). See the Jira section. |
| Existing PR | `curl -s -u "$EMAIL:$TOKEN" -G "https://api.bitbucket.org/2.0/repositories/<workspace>/<repo>/pullrequests" --data-urlencode 'q=source.branch.name="<branch>" AND state="OPEN"'`. Or use `q=title~"<KEY-123>" AND state="OPEN"`. Follow `next` to get more pages. |
| Assign | In Jira. See the Jira section. |
| Link and close | Put `<KEY-123>` in the PR title and the branch name (a non-merge commit also works). The description does not link, and linking needs the Jira-Bitbucket integration connected. No keyword closes the issue on merge: that needs a Jira automation rule. |
| Open as draft | `curl -s -u "$EMAIL:$TOKEN" -X POST "https://api.bitbucket.org/2.0/repositories/<workspace>/<repo>/pullrequests" -H 'Content-Type: application/json' -d '{"title":"<KEY-123> <title>","description":"<body>","source":{"branch":{"name":"<branch>"}},"draft":true}'` |
| Edit description | GET the PR first, then `curl -s -u "$EMAIL:$TOKEN" -X PUT "https://api.bitbucket.org/2.0/repositories/<workspace>/<repo>/pullrequests/<id>" -H 'Content-Type: application/json' -d '{"title":"<current title>","description":"<body>","reviewers":[<current reviewers>]}'` |
| PR template | `.bitbucket/pull_request_template.md` on the source branch, else the repo's Default description. The REST API applies neither, so fill it into `description`. |
| Ready, checks, merge | PUT `{"draft": false}` to the PR. Checks: GET `.../pullrequests/<id>/statuses` and `.../pullrequests/<id>/mergeability/checks`. Merge: POST `.../pullrequests/<id>/merge` with `{"type":"pullrequest","merge_strategy":"squash"}`, which merges at once: there is no merge-when-green through the API unless the branch has a merge queue. |

Pitfalls:
- Adding `AND draft=true` to `q` returns only drafts, not drafts as well, so if a known draft is missing, run it as a separate query.
- The PR body field you send is `description`; responses show it as `summary.raw`, so sending `summary` does nothing.
- PUT replaces the PR, and leaving out `reviewers` may clear them, so copy title and reviewers from a single-PR GET (list responses can leave reviewers out), and note that only OPEN PRs can be changed.
- App passwords stopped working on 2026-06-09, so use an API token with the Atlassian account email (not the username) or as Bearer.
- Bitbucket Data Center has a different API (`https://<host>/rest/api/latest/projects/<KEY>/repos/<slug>/pull-requests` with full refs in `fromRef.id`/`toRef.id`), so Cloud request bodies will not work there.

## Anything else

For a tracker not listed here (YouTrack, Shortcut, Redmine, a self-hosted tool), use its MCP server or CLI if one is set up, else its REST API with the user's token, else ask the user to paste the issue with its comments and links. The same needs apply: read it with comments, find blockers and children, find an existing PR, assign it to yourself, and link the PR to it. Say in the PR body how it is linked, since a reviewer can't assume the usual keyword.
