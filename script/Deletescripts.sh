#!/bin/bash

STORE_NAME=$1
THEMEKIT_PASSWORD=$2 
REPO_NAME=$3
GITHUB_TOKEN=$4
SHOPIFY_API_VERSION="2022-10"

pwd



docker run -v ${PWD}:/theme satel/themekit:1.2-alpha1  /script/DeleteInactiveThemes.sh \
                # ${{ inputs.store-name }} ${{ inputs.theme-password }} ${{ inputs.repo-name }} ${{ inputs.github-token }} ${{ inputs.current-branch-name }}
# apk add jq 

# function delete_inactive_themes() {
#     # grab all the themes except for main and sandboxes as we dont want to delete theme
#     THEME_NAMES=`theme get --list --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} | grep 'PR: ' | awk '{print $3}'`
#     THEME_LIST=( $THEME_NAMES )

#     get_branch_list
#     BRANCH_NAMES=( $BRANCH_LIST )

#     for THEME in "${THEME_LIST[@]}"
#     do    
#         if [[ ! "${BRANCH_NAMES[*]}" =~ "${THEME}" ]]; then
#             echo "Themes that will be deleted PR:${THEME}"
#             THEME_ID=`theme get --list --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} | grep -i ${THEME} | cut -d "[" -f 2 | cut -d "]" -f 1` # | cut -d "e" -f 2
    
#             curl -d "{\"theme\":{\"id\": \"${THEME_ID}\", \"name\": \"${THEME}\"}}" \
#             -X DELETE "https://${STORE_NAME}/admin/api/${SHOPIFY_API_VERSION}/themes/${THEME_ID}.json" \
#             -H "X-Shopify-Access-Token: ${THEMEKIT_PASSWORD}" \
#             -H "Content-Type: application/json" 

#         fi
#     done
# }

# function get_branch_list(){
#     PAYLOAD="query { \
#         organization(login: \\\"Rahul-Personal-lists\\\") {\
#             repository(name: \\\"${REPO_NAME}\\\") {\
#             refs(refPrefix: \\\"refs/heads/\\\", first: 100) {\
#                 edges {\
#                 node{\
#                     name\
#                 }\
#                 }\
#             }\
#             }\
#         }\
#     }"

#     BRANCH_LIST=`curl -X POST "https://api.github.com/graphql" \
#         -H "Authorization: bearer ${GITHUB_TOKEN}" \
#         -H "Content-Type: application/json"  \
#         -d "{ \"query\": \"${PAYLOAD}\"}" | jq ".data.organization.repository.refs.edges[].node.name"`; STATUS1=$?  

#     # Catch exit code so all the PR: themes dont get deleted
#     if [[ $STATUS1 != 0 ]]
#     then    
#         exit 1
#     fi  
#     echo $BRANCH_LIST       
# }
# delete_inactive_themes