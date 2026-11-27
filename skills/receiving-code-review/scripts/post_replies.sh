#!/usr/bin/env bash
# The only path that writes to the pull request. Goes through the plan's items once:
#   reject, clarify  reply on each thread, review, or comment source; leave it open
#   accept           only once fixed_in is on the PR head: reply ({sha} filled in), resolve its threads
#   needs-human      nothing
# Safe to rerun: a thread already holding your reply gets no second one. A thread with comments from
# others after the plan's checked_at is skipped: judge it again. Review bodies and conversation
# comments can't hold replies, so their answer is a PR comment that links them.
#   post_replies.sh [resolution-plan.json]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
plan=${1:-resolution-plan.json}
read -r repo pr checked_at < <(jq -r '"\(.repo) \(.pr) \(.checked_at)"' "$plan")
if [ "$pr" = null ]; then
  echo "The plan has no pull request: nothing to post."
  exit 0
fi

state=$("$here/fetch_threads.sh" "$pr")
if [ "$(jq -r .pending_review <<<"$state")" = true ]; then
  echo "You have a pending review on this PR; replies would be absorbed into it unseen. Submit or discard it on GitHub, then rerun." >&2
  exit 3
fi
head=$(jq -r .head <<<"$state")
me=$(jq -r .viewer <<<"$state")
host=$(jq -r '.url | capture("https?://(?<h>[^/]+)/").h' <<<"$state")
[ "$host" = github.com ] || export GH_HOST="$host"

published() {
  local status
  status=$(gh api "repos/$repo/compare/$1...$head" --jq .status 2>/dev/null) || return 1
  [ "$status" = identical ] || [ "$status" = ahead ]
}
resolve() {
  gh api graphql -f id="$1" --jq .data.resolveReviewThread.thread.isResolved \
    -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }' >/dev/null
}

while IFS= read -r item <&3; do
  id=$(jq -r .id <<<"$item")
  verdict=$(jq -r .verdict <<<"$item")
  body=$(jq -r '.reply_draft // ""' <<<"$item")
  if [ "$verdict" = needs-human ]; then
    echo "$id: needs-human, left open for the user"
    continue
  fi
  if [ "$verdict" = accept ]; then
    sha=$(jq -r '.fixed_in // ""' <<<"$item")
    if [ -z "$sha" ]; then
      echo "$id: accepted, no fixed_in yet; nothing posted"
      continue
    elif ! published "$sha"; then
      echo "$id: ${sha:0:7} isn't on the PR head yet; nothing posted"
      continue
    fi
    body=${body//\{sha\}/${sha:0:7}}
  fi
  while IFS=$'\t' read -r type sid <&4; do
    case $type in
    thread)
      open=$(jq -c --arg id "$sid" '.threads[] | select(.id == $id)' <<<"$state")
      mine=$(jq -c --arg id "$sid" '.waiting[] | select(.id == $id)' <<<"$state")
      if [ -n "$open" ]; then
        if jq -e --arg since "$checked_at" --arg me "$me" 'any(.comments[]; .at > $since and .author != $me)' <<<"$open" >/dev/null; then
          echo "$id: $sid has new comments since the plan; judge it again"
          continue
        fi
        gh api "repos/$repo/pulls/$pr/comments/$(jq -r .reply_to <<<"$open")/replies" \
          -f body="$body" --jq .html_url >/dev/null
        echo "$id: replied on $sid"
        if [ "$verdict" = accept ]; then
          resolve "$sid"
          echo "$id: resolved $sid"
        fi
      elif [ -n "$mine" ] && [ "$verdict" = accept ] && jq -e --arg since "$checked_at" '.since > $since' <<<"$mine" >/dev/null; then
        resolve "$sid"
        echo "$id: $sid already had your reply; resolved it"
      elif [ -n "$mine" ]; then
        echo "$id: $sid already has your reply"
      else
        echo "$id: $sid is resolved or gone; skipped"
      fi
      ;;
    review | comment)
      url=$(jq -r --arg id "$sid" 'first(.reviews[], .comments[] | select(.id == $id) | .url) // ""' <<<"$state")
      if [ -n "$url" ]; then
        gh api "repos/$repo/issues/$pr/comments" -f body="Re $url"$'\n\n'"$body" --jq .html_url >/dev/null
        echo "$id: answered $sid in a PR comment"
      else
        echo "$id: $sid already answered"
      fi
      ;;
    esac
  done 4< <(jq -r '.sources[] | [.type, .id] | @tsv' <<<"$item")
done 3< <(jq -c '.items | sort_by(.order // 1e9)[]' "$plan")
