REPOS=()
exec 3< "includedRepos.txt"
# Read the file line by line
while IFS= read -r line <&3 || [ -n "$line" ]; do
  REPOS+=("$line")
done
exec 3<&-
JSON_File=$(jq -r '.' envRules.json)
JSON_File_ENV=$(echo $JSON_File | jq -r '.[].name')
for item in "${REPOS[@]}"; do
  echo "Request to get Environment of $item"
  ENVIRONMENT_NAMES=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/EurusTechnologies/$item/environments" | jq -r '.environments[].name')
  for env in ${ENVIRONMENT_NAMES[@]}; do
    for i in $JSON_File_ENV; do
      if [[ $i == $env ]]; then
        JSON_PAYLOAD=$(echo "$JSON_File" | jq -r --arg environ "$i" '.[] | select(.name == $environ) | .reviewers ')        
        JSON_PAYLOAD_NOSPACE=$(echo "$JSON_PAYLOAD" | jq -c '.')
        json_object="{  
          \"reviewers\":$JSON_PAYLOAD_NOSPACE 
          }"
        echo "updating access for Environment $i"
        curl -L \
        -X PUT \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer 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" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/EurusTechnologies/$item/environments/$env" \
        -d "$json_object"
      fi
    done
  done
done