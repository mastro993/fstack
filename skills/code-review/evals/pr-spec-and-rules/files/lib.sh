# Shared by the code-review eval fixtures; sourced by each case's setup-fixture.sh, which runs from
# the sandbox root. Commits get fixed, increasing dates, so every run builds the same SHAs.
set -eu

ROOT=$PWD
export GIT_AUTHOR_NAME=fixture GIT_AUTHOR_EMAIL=fixture@example.org
export GIT_COMMITTER_NAME=fixture GIT_COMMITTER_EMAIL=fixture@example.org
TICK=0

# new_repo DIR: an empty repository on main, entered.
new_repo() {
  git init -q -b main "$ROOT/$1"
  cd "$ROOT/$1"
  git config user.name fixture
  git config user.email fixture@example.org
}

# commit MESSAGE [AUTHOR]: commit everything, dated one day after the previous commit.
commit() {
  TICK=$((TICK + 1))
  local when
  when=$(printf '2026-09-%02dT10:00:00Z' "$TICK")
  git add -A
  GIT_AUTHOR_NAME=${2:-$GIT_AUTHOR_NAME} GIT_AUTHOR_DATE=$when GIT_COMMITTER_DATE=$when git commit -qm "$1"
}

# publish NAME PR=BRANCH...: push every branch to $ROOT/remote.git, add refs/pull/<n>/head for
# each PR, point origin at https://git.example.com/evals/NAME (fetched from remote.git), and
# leave the checkout on main with only main local, as if the PRs came from someone else.
publish() {
  local name=$1 pair
  shift
  git init -q --bare "$ROOT/remote.git"
  git push -q "$ROOT/remote.git" --all
  git --git-dir="$ROOT/remote.git" symbolic-ref HEAD refs/heads/main
  for pair in "$@"; do
    git --git-dir="$ROOT/remote.git" update-ref "refs/pull/${pair%%=*}/head" "refs/heads/${pair#*=}"
  done
  git remote add origin "https://git.example.com/evals/$name.git"
  git config "url.$ROOT/remote.git.insteadOf" "https://git.example.com/evals/$name.git"
  git fetch -q origin
  git remote set-head origin main
  git checkout -q main
  git branch --format='%(refname:short)' | grep -vx main | xargs -n1 git branch -q -D 2>/dev/null || true
  git branch -q -u origin/main main
}
