# Satel Storefront Theme Deployment
This centralized GitHub action deploys a theme to shopify admin


## Usage 
```yml
name: "Deploy theme"
on:
  pull_request:
    types:
      - opened
  push:
    tags:
      - "*"
    branches:
      - main  
    
    deploy-theme:
    name: Theme deploy
    needs: [generate-variables]
    runs-on: <host_name>
    steps:    
      - name: Checkout
        uses: actions/checkout@v2  
      
      - name: Convert secrets to JSON
        id: create-json
        uses: jsdaniell/create-json@1.1.2
        with:
          name: "theme.json"
          json: ${{ secrets.THEME_CONFIG_JSON }}

      - name: Deploy
        uses: Rahul-Personal-lists/theme-runner@test/theme-deploy
        with: 
            store-name: "<store-1> <store-2>" 
            theme-env: "developtheme"
            copy-settings: true
            main-theme-id: "<id-1> <id-2>"
            repo-name: ${{needs.generate-variables.outputs.repo-name}}
            github-token: ${{ secrets.TOKEN_GITHUB }}
            shopify-api-version: "2022-10"
            theme-files-location: src
            current-branch-name: ${{needs.generate-variables.outputs.branch-name}}
            tag-name: ${{needs.generate-variables.outputs.tag-name}}   
```

 - `host_name` is `self-hosted` or the name of server where the action runner is hosted, `cosmicray` for example
 - `store-name` can be `flow-europe-parts-stg` or `flow-parts-dev` for example
 - ` main-theme-id` is ID of main theme, theme that gets deployed when a PR is merged to main branch 
 - `theme-files-location` is the location of the folder where all the themes files are located and is optional. 
     Only add this if the files are not in root directory, shape for eg, its in `src`
 - `clean-branch-name` & `tag-name` parameters are set in a previous step  
 - Convert secrets to JSON converts a JSON secrets stored on GitHub to a plain JSON and it's in following format 

 ```json
 {
	"<store-name-1>": "<password_for_store_1>",
	"<store-name-2>": "<password_for_store_2>"
}
```