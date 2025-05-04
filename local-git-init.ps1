# Define the repository name (replace with your actual repo name)
$repoName = "YourRepoName"  # Replace with your actual repository name
$githubUrl = "git@github-ace:ACEhandle/$repoName.git"  # Replace with your GitHub username and repo name

# Initialize the local Git repository
git init

# Set local username and email for commits
git config user.name "Frank"  # Local Git username
git config user.email "blank@blank.com"  # Local Git email

# Add the remote origin (GitHub repository URL via SSH)
git remote set-url origin $githubUrl

# Add all files to the staging area
git add .

# Commit the files with an initial commit message
git commit -m "Initial commit"

# Push to the remote repository (GitHub)
git push -u origin master  # Use 'main' instead of 'master' if your default branch is 'main'
