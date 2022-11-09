#!/bin/bash
STORE_NAME=$1 
THEMEKIT_PASSWORD=$2  
THEME_NAME=$3 # Also the branch name
THEME_ENV=$4
COPY_SETTINGS=$5
SHOPIFY_API_VERSION="2022-10"
THEME_ID=" "


deploy_pr_branch_or_tag() { 
    THEME_ID=`theme get --list --password=${THEMEKIT_PASSWORD}  --store=${STORE_NAME} | grep -i ${THEME_NAME} | cut -d "[" -f 2 | cut -d "]" -f 1`       
    echo "THEME_ID ${THEME_ID}"
    if [[ ! "${THEME_ID}" ]] 
    then
        # Theme doesnt exist, create it
        # Use api call instead of theme new as the latter creates a V1 theme
        echo "Create theme"
        create_theme
    else
        # Theme exist, just configure it
        echo "Configure theme"
        configure_theme
    fi
    ls
    configure_theme # configure once again before deployment

    if [[ COPY_SETTINGS == true ]]
    then   
        echo "COPY_SETTING LOOP"
        theme download --env ${THEME_ENV} config/settings_data.json --live
    fi 

    #TODO : PR theme links  

    theme deploy --env ${THEME_ENV}; STATUS1=$?     

    #To overcome first theme deploy's limitation for V2 of uploading files in a bad order, so deploy once again
    if [[ $STATUS1 != 0 ]]
    then    
        echo "THEME DEPLOY LOOP"
        theme deploy --env ${THEME_ENV}
    fi    
}   

function configure_theme(){
    theme configure --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} --themeid=${THEME_ID} --env ${THEME_ENV}
    echo $THEME_ID
}

function create_theme(){
    curl -d "{\"theme\":{\"name\": \"PR: ${THEME_NAME}\", \"env\": \"${THEME_ENV}\"}}" \
        -X POST "https://${STORE_NAME}/admin/api/${SHOPIFY_API_VERSION}/themes.json" \
        -H "X-Shopify-Access-Token: ${THEMEKIT_PASSWORD}" \
        -H "Content-Type: application/json" 
}

deploy_pr_branch_or_tag
