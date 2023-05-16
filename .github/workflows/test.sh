REPOS=()
exec 3< "includedRepos.txt"
# Read the file line by line
while IFS= read -r line <&3 || [ -n "$line" ]; do
  REPOS+=("$line")
done
exec 3<&-
for item in "${REPOS[@]}"; do
  ENVIRONMENT_NAMES=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/EurusTechnologies/$item/environments")
  echo $ENVIRONMENT_NAMES
done