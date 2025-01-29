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
touch "$DIR_NAME"/.gitignore || { echo "Error creating.gitignore."; exit 1; }

# Add initial content to package.json
echo "{}" > "$DIR_NAME"/package.json || { echo "Error creating package.json."; exit 1; }

touch "$DIR_NAME"/README.md || { echo "Error creating README.md."; exit 1; }

echo "Project directory: $DIR_NAME"

# Change to the project directory
cd "$DIR_NAME" || { echo "Error: Could not change to directory '$DIR_NAME'"; exit 1; }

# Run npm commands
npm init -y || { echo "Error running npm init -y"; exit 1; }
npm install express axios dotenv || { echo "Error installing express axios dotenv"; exit 1; }
npm install --save-dev webpack webpack-cli webpack-node-externals nodemon || { echo "Error installing dev dependencies for Webpack and nodemon"; exit 1; }
npm install --save-dev @babel/core @babel/preset-env babel-loader || { echo "Error installing dev dependencies for Babel"; exit 1; }

echo "Initial setup is complete."

echo "Setting up webpack config."

cat > webpack.config.js << EOF
const path = require('path');
const nodeExternals = require('webpack-node-externals');

module.exports = {
  entry: './src/server/server.js',
  target: 'node',
  externals: [nodeExternals()],
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'server.bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
    ],
  },
};
EOF

echo "Setting up express server."

cat > src/server/server.js << EOF
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Set EJS as the templating engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static files
app.use(express.static(path.join(__dirname, './src/public')));

// Parse JSON and URL-encoded bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Home route (static HTML)
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, './src/public/index.html'));
});

// Dynamic route (EJS)
app.get('/dynamic', (req, res) => {
  res.render('dynamic', { title: 'Dynamic View', message: 'Hello from the server!' });
});

// Start the server
app.listen(PORT, () => {
  console.log(\`Server is running on http://localhost:\${PORT}\`);
});
EOF

echo "Writing boiler plate HTML pages for testing"

cat > src/public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Web App</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <h1>Welcome to My Web App</h1>
  <p>This is a static HTML view.</p>
</body>
</html>
EOF

cat > src/public/styles.css << EOF
body {
  font-family: Arial, sans-serif;
  background-color: #f0f0f0;
  text-align: center;
  padding: 50px;
}
EOF

cat > src/server/views/dynamic.ejs << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= title %></title>
</head>
<body>
  <h1><%= title %></h1>
  <p><%= message %></p>
</body>
</html>
EOF

echo "Setting up babelrc"

cat > .babelrc << EOF
{
  "presets": ["@babel/preset-env"]
}
EOF


echo 'Project setup complete!

Update package.json with the following content:

"scripts": {
  "build": "webpack --mode production",
  "start": "node dist/server.bundle.js",
  "dev": "nodemon src/server/server.js"
}
'


# debug later
# Change to the project directory
# cd "$DIR_NAME" || { echo "Error: Could not change to directory '$DIR_NAME'"; exit 1; }
