#!/bin/bash

# Get the directory name from the command line argument or generate a default name
if [ -z "$1" ]; then
  i=1
  while true; do
    DIR_NAME="my-web-app$i"
    if [! -d "$DIR_NAME" ]; then
      break
    fi
    i=$((i+1))
  done
else
  DIR_NAME="$1"
fi

# Check if the directory already exists
if [[ -d "$DIR_NAME" ]]; then
  echo "Directory '$DIR_NAME' already exists. Using existing directory."
else
  # Create the main folder
  if ! mkdir "$DIR_NAME"; then
    echo "Error: Could not create directory '$DIR_NAME'. Permission denied or insufficient privileges."
    exit 1
  fi
fi

# Create the subfolders
mkdir -p "$DIR_NAME"/src/server/{controllers,routes,views} || { echo "Error creating server subfolders."; exit 1; }
mkdir -p "$DIR_NAME"/src/public/{css,js} || { echo "Error creating public subfolders."; exit 1; }
mkdir -p "$DIR_NAME"/src/config || { echo "Error creating config subfolder."; exit 1; }

# Create the files
touch "$DIR_NAME"/src/server/server.js || { echo "Error creating server.js."; exit 1; }
touch "$DIR_NAME"/src/public/index.html || { echo "Error creating index.html."; exit 1; }
# touch "$DIR_NAME"/.gitignore || { echo "Error creating.gitignore."; exit 1; }
# touch "$DIR_NAME"/package.json || { echo "Error creating package.json."; exit 1; }
touch "$DIR_NAME"/README.md || { echo "Error creating README.md."; exit 1; }

echo "Project directory: $DIR_NAME"

# Change to the project directory
cd "$DIR_NAME" || { echo "Error: Could not change to directory '$DIR_NAME'"; exit 1; }

# Run npm commands
npm init -y || { echo "Error running npm init -y"; exit 1; }
npm install express axios dotenv || { echo "Error installing express axios dotenv"; exit 1; }
npm install --save-dev webpack webpack-cli webpack-node-externals nodemon || { echo "Error installing dev dependencies"; exit 1; }
# install templating engine
npm install ejs || { echo "Error installing ejs"; exit 1; }

echo "Project setup complete!
Update package.json with the below content: 

"scripts": {
  "build": "webpack --mode production",
  "start": "node dist/server.bundle.js",
  "dev": "nodemon src/server/server.js"
}
"

# Additional commands
mkdir -p src/server/routes src/server/views src/public src/client || { echo "Error creating additional directories"; exit 1; }
touch src/server/server.js src/public/index.html src/public/styles.css webpack.config.js || { echo "Error creating additional files"; exit 1; }