#!/bin/bash
STORE_NAME=$1 
THEMEKIT_PASSWORD=$2  
THEME_NAME=$3 # Also the branch name
THEME_ENV=$4
COPY_SETTINGS=$5
SHOPIFY_API_VERSION="2022-10"
THEME_ID=" "

echo "STORE_NAME=${STORE_NAME}, THEMEKIT_PASSWORD=${THEMEKIT_PASSWORD}, THEME_NAME=${THEME_NAME}, THEME_ENV=${THEME_ENV}, COPY_SETTINGS=${COPY_SETTINGS}"

deploy_pr_branch_or_tag() { 
    THEME_ID=`docker run satel/themekit:1.2-alpha1 theme get --list --password=${THEMEKIT_PASSWORD}  --store=${STORE_NAME} | grep -i ${THEME_NAME} | cut -d "[" -f 2 | cut -d "]" -f 1`       
    echo "THEME_ID ${THEME_ID}"
    if [[ ! "${THEME_ID}" ]] 
    then
        # Theme doesnt exist, create it
        # Use api call instead of theme new as the latter creates a V1 theme
        echo "Create theme loop"
        create_theme
    else
        # Theme exist, just configure it
        echo "Configure theme loop"
        configure_theme
    fi

    configure_theme # configure once again before deployment

    if [[ COPY_SETTINGS == true ]]
    then   
        echo "COPY_SETTING LOOP"
        docker run satel/themekit:1.2-alpha1 theme download --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} --env ${THEME_ENV} config/settings_data.json --live
    fi 

    #TODO : PR theme links  

    cd src
    ls

    #REPLACE docker run with CURL PUT  - it doesnt quite work
    echo "Running deploy command"
    # curl -d "{\"theme\":{\"name\": \"PR: ${THEME_NAME}}\", \"id\": \"${THEME_ID}\"}}" \
    #     -X PUT "https://${STORE_NAME}/admin/api/${SHOPIFY_API_VERSION}/themes/${THEME_ID}.json" \
    #     -H "X-Shopify-Access-Token: ${THEMEKIT_PASSWORD}" \
    #     -H "Content-Type: application/json" 
    docker run satel/themekit:1.2-alpha1  theme deploy --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} --themeid=${THEME_ID}  --env ${THEME_ENV}; STATUS1=$?
    #To overcome first theme deploy's limitation for V2 of uploading files in a bad order, so deploy once again
    if [[ $STATUS1 != 0 ]]
    then    
        echo "THEME DEPLOY LOOP"
        docker run satel/themekit:1.2-alpha1  theme deploy --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} --themeid=${THEME_ID}  --env ${THEME_ENV};
    fi    
}   

function configure_theme(){
    docker run satel/themekit:1.2-alpha1 theme configure --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} --themeid=${THEME_ID} --env ${THEME_ENV}
    echo $THEME_ID
}

function create_theme(){
    curl -d "{\"theme\":{\"name\": \"PR: ${THEME_NAME}\", \"env\": \"${THEME_ENV}\"}}" \
        -X POST "https://${STORE_NAME}/admin/api/${SHOPIFY_API_VERSION}/themes.json" \
        -H "X-Shopify-Access-Token: ${THEMEKIT_PASSWORD}" \
        -H "Content-Type: application/json" 
}

deploy_pr_branch_or_tag
