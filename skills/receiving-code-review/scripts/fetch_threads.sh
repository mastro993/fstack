#!/usr/bin/env bash
# Print a pull request's open review feedback as JSON:
#   threads    unresolved review threads, every page (GraphQL: the flat comments API has no
#              resolution state), with each comment's author and bot flag
#   waiting    unresolved threads where you spoke last: the reviewer owes the next word
#   reviews    review bodies with text, and
#   comments   conversation comments, from others, that no later comment of yours links to
# plus the PR's head commit, you (viewer), and fetched_at for the plan's checked_at.
#
#   fetch_threads.sh [PR]    PR is a number, URL, or branch; default: the current branch's PR.
set -euo pipefail

pr=$(gh pr view ${1:+"$1"} --json number,url,headRefOid,headRefName,baseRefName,author)
read -r host owner repo number < <(jq -r '.url | capture("https?://(?<h>[^/]+)/(?<o>[^/]+)/(?<r>[^/]+)/pull/(?<n>[0-9]+)") | "\(.h) \(.o) \(.r) \(.n)"' <<<"$pr")
[ "$host" = github.com ] || export GH_HOST="$host"
fetched_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# One paginated query per connection: --paginate follows only one pageInfo per query.
query() {
  gh api graphql --paginate --slurp -F owner="$owner" -F repo="$repo" -F number="$number" -f query="
query(\$owner: String!, \$repo: String!, \$number: Int!, \$endCursor: String) {
  viewer { login }
  repository(owner: \$owner, name: \$repo) { pullRequest(number: \$number) { $1 } }
}"
}
threads=$(query 'reviewThreads(first: 100, after: $endCursor) { pageInfo { hasNextPage endCursor }
  nodes { id isResolved isOutdated path line startLine originalLine
    comments(first: 100) { nodes { databaseId author { login __typename } body url createdAt } } } }')
reviews=$(query 'reviews(first: 100, after: $endCursor) { pageInfo { hasNextPage endCursor }
  nodes { id author { login __typename } state body url submittedAt } }')
comments=$(query 'comments(first: 100, after: $endCursor) { pageInfo { hasNextPage endCursor }
  nodes { id author { login __typename } body url createdAt } }')

jq -n --argjson pr "$pr" --argjson t "$threads" --argjson r "$reviews" --argjson c "$comments" \
  --arg repo "$owner/$repo" --arg fetched_at "$fetched_at" '
  def nodes($pages; $conn): [$pages[].data.repository.pullRequest[$conn].nodes[]];
  def who: {author: .author.login, bot: (.author.__typename == "Bot" or (.author.login | test("\\[bot\\]$")))};
  ($t[0].data.viewer.login) as $me
  | nodes($t; "reviewThreads") as $threads
  | nodes($r; "reviews") as $reviews
  | nodes($c; "comments") as $comments
  | [$comments[] | select(.author.login == $me) | .body] as $mine
  | def answered: .url as $u | any($mine[]; contains($u));
  {
    repo: $repo, pr: $pr.number, url: $pr.url, head: $pr.headRefOid, head_ref: $pr.headRefName,
    base_ref: $pr.baseRefName, author: $pr.author.login, viewer: $me, fetched_at: $fetched_at,
    pending_review: any($reviews[]; .state == "PENDING" and .author.login == $me),
    threads: [$threads[] | select((.isResolved | not) and .comments.nodes[-1].author.login != $me)
      | {id, path, line: (.line // .startLine // .originalLine), outdated: .isOutdated,
         reply_to: .comments.nodes[0].databaseId,
         comments: [.comments.nodes[] | who + {body, at: .createdAt}]}],
    waiting: [$threads[] | select((.isResolved | not) and .comments.nodes[-1].author.login == $me)
      | {id, path, line: (.line // .originalLine), since: .comments.nodes[-1].createdAt}],
    resolved_threads: [$threads[] | select(.isResolved)] | length,
    reviews: [$reviews[] | select(.author.login != $me and .state != "PENDING"
                and (.body | test("\\S")) and (answered | not))
      | {id, url, state} + who + {body}],
    comments: [$comments[] | select(.author.login != $me and (.body | test("\\S")) and (answered | not))
      | {id, url} + who + {body}]
  }'
