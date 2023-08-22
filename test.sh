script_folder=$(dirname $0)

while getopts "x:" arg; do
    case $arg in
        x) export extra_json_args=${OPTARG};;
    esac
done

echo_to_github() {
    echo "$1"
    if [ -n "$GITHUB_STEP_SUMMARY" ]; then
        echo "$1" >> $GITHUB_STEP_SUMMARY
    fi
}

changelog=$(jq -r '.changelog' <<< $extra_json_args)
echo_to_github "changelog: $changelog"

build_info=$(jq --null-input \
    --arg changelog "$changelog" \
    --arg actor "test" \
    '$ARGS.named' \
)

app_feed_url="https://storage.googleapis.com/axie-game-assets/origin/test/app-feed-mac.json?ts=$(date +%s)"
content=$(curl $app_feed_url)
content=$(gecho $content | jq --argjson build_info "$build_info" '.buildInfos |= [$build_info] + .')

app_feed_output=$(readlink -f $script_folder)/temp/app-feed-testest.json
mkdir -p "$script_folder/temp"
gecho "$content" >> $app_feed_output

echo_to_github '```'
echo_to_github "$build_info"
echo_to_github '```'
