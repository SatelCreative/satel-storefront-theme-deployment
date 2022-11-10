#!/bin/bash
STORE_NAME=$1
THEMEKIT_PASSWORD=$2
THEME_NAME=$3 #main branch name
THEME_ID=$4
THEME_ENV=$5
SHOPIFY_API_VERSION="2022-10"

function deploy_main_branch(){
  docker run -it satel/themekit:1.2-alpha1 theme configure --password=${THEMEKIT_PASSWORD} --store=${STORE_NAME} --themeid=${THEME_ID} --env ${THEME_ENV}

  NAME=`TZ='US/Pacific' date`
  NEW_THEME_NAME="${THEME_NAME^^}"
  echo ${NEW_THEME_NAME} ${NAME}
  #this will rename the theme
  curl -d "{\"theme\":{\"name\": \"${NEW_THEME_NAME} ${NAME}\", \"id\": \"${THEME_ID}\"}}" \
        -X PUT "https://${STORE_NAME}/admin/api/${SHOPIFY_API_VERSION}/themes/${THEME_ID}.json" \
        -H "X-Shopify-Access-Token: ${THEMEKIT_PASSWORD}" \
        -H "Content-Type: application/json" 
  #Deploy to live
  docker run -it satel/themekit:1.2-alpha1  theme -e developtheme deploy --allow-live --ignored-file=config/settings_data.json    
}


deploy_main_branch