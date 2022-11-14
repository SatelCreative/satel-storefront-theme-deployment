#!/bin/bash

STORE_NAME=$1 
THEME_ENV=$2
COPY_SETTINGS=$3
SHOPIFY_API_VERSION=$4
WORK_DIR=$5
BRANCH_NAME=$6
TAG_NAME=$7
THEME_ID=" "

echo "STORE_NAME=${STORE_NAME}, THEME_NAME=${THEME_NAME}, THEME_ENV=${THEME_ENV}, COPY_SETTINGS=${COPY_SETTINGS}"
THEMEKIT_PASSWORD=$(jq -r '."'${STORE_NAME}'"' theme.json) #decode password from json

if [[ -n $WORK_DIR ]] #only change dir if theme files are in a different folder
then
    echo "WORK_DIR ${WORK_DIR}"
    cd $WORK_DIR
fi    

if [[ -n $TAG_NAME ]]  
then  
    THEME_NAME=$TAG_NAME
else
    THEME_NAME=$BRANCH_NAME
fi

deploy_pr_branch_or_tag() { 
    THEME_ID=`docker run satel/themekit:1.2-alpha1 theme get --list --password=${THEMEKIT_PASSWORD}  --store="${STORE_NAME}.myshopify.com" | grep -i ${THEME_NAME} | cut -d "[" -f 2 | cut -d "]" -f 1`       
    echo "THEME_ID ${THEME_ID}"
    if [[ ! "${THEME_ID}" ]] 
    then
        # Theme doesnt exist, create it
        # Use api call instead of theme new as the latter creates a V1 theme
        echo "Create theme loop"
        create_theme
        THEME_ID=`docker run satel/themekit:1.2-alpha1 theme get --list --password=${THEMEKIT_PASSWORD}  --store="${STORE_NAME}.myshopify.com" | grep -i ${THEME_NAME} | cut -d "[" -f 2 | cut -d "]" -f 1`  
        configure_theme # configure once again before deployment to genearate config.yml as it's needed for theme deploy

    else
        # Theme exist, just configure it
        echo "Configure theme loop"
        configure_theme
    fi

    if [[ $COPY_SETTINGS == true ]]
    then   
        echo "COPY_SETTING LOOP"
        docker run -v ${PWD}:/theme satel/themekit:1.2-alpha1 theme download --password=${THEMEKIT_PASSWORD} --store="${STORE_NAME}.myshopify.com"  --env ${THEME_ENV} config/settings_data.json --live
    fi 

    #TODO : PR theme links  

    echo "Running deploy command"
    docker run -v ${PWD}:/theme satel/themekit:1.2-alpha1 theme deploy --password=${THEMEKIT_PASSWORD} --store="${STORE_NAME}.myshopify.com" --themeid=${THEME_ID}  --env ${THEME_ENV}; STATUS1=$?   

    # To overcome first theme deploy's limitation for V2 of uploading files in a bad order, so deploy once again
    if [[ $STATUS1 != 0 ]]
    then    
        echo "THEME DEPLOY LOOP"
        docker run -v config.yml:/theme satel/themekit:1.2-alpha1 theme deploy --env ${THEME_ENV}
    fi    
}   

function configure_theme(){
    docker run -v ${PWD}:/theme satel/themekit:1.2-alpha1 theme configure --password=${THEMEKIT_PASSWORD} --store="${STORE_NAME}.myshopify.com" --themeid=${THEME_ID} --env ${THEME_ENV}
    echo "Configre loop ${THEME_ID}"
}

function create_theme(){
    curl -d "{\"theme\":{\"name\": \"PR: ${THEME_NAME}\", \"env\": \"${THEME_ENV}\"}}" \
        -X POST "https://${STORE_NAME}.myshopify.com/admin/api/${SHOPIFY_API_VERSION}/themes.json" \
        -H "X-Shopify-Access-Token:${THEMEKIT_PASSWORD}" \
        -H "Content-Type: application/json" 
}

deploy_pr_branch_or_tag
