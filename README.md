

# Working Copy Client

A light Codea client for committing code to Working Copy, a full iOS Git client. The free version supports local Git commits only. To push to a remote host such as GitHub, BitBucket, or your own server, please buy the full version of Working Copy.

## Installation

1. Install Working Copy on your iPad.

2. Set up some repositories in Working Copy to store your code. If you have a remote host on GutHub, BitBucket, your local server etc then you can clone your existing repositories. Otherwise you can initialise local repos on your device, and push them to the remote host later. Give large projects their own repository with the same name as their project name in Codea.[^note1] To store smaller projects that don't need their own repository, set up a repository called "Codea". This will save you having to set up repositories for every single Codea project.

3. In Working Copy settings, turn on "URL Callbacks" and copy the URL key to the clipboard.

4. The first time you run Working Copy Client in Codea, press the "set up" button in the parameter sidebar and paste this URL key (from step 3) into the "Working Copy key" text box. 

## Usage

1. In Codea, make Working Copy Client a dependency of any project you want to push to Working Copy 

2. The first time you run Working Copy Client within a Codea project, press the "Working Copy Client" button in the parameter sidebar, and then press the "set up" button. On the setup screen you can select:

  - A toggle switch to say whether you want to push the local repositories on your iPad to remote hosts on GitHub, BitBucket, your computer etc. This requires the push IAP in Working Copy (recommended).

  - The repository name that you would like to sync to. There is a button to autopopulate the repository name with the name of the Codea project. This also places the name in the clipboard (in case you haven't actually set up the repository yet, so you can move across to Working Copy and paste the title into the new repo name field).

  - A toggle switch to say whether you would like to push this project as a single file in Codea's "paste-into-project" format, or as multiple files:

    - "single file" concatenates your project using Codea's "paste into project" format `--# tab name` and pushes it by default to the "Codea" repository in Working Copy (although you can change the repository name to whatever you like), naming the file after its Codea project name.[^note1] This is appropriate for smaller projects. To restore a previous version, you can copy the file from Working Copy (share pane > Copy), and in Codea, "paste into project"

    - "multiple file" writes each tab as a separate file into a folder called "tabs". It is recommended that you push multiple files to their own repository. Fill in the repository name field, or use the "name repository after project" button to autopopulate it. You'll get an error message if no repository with that name is found. This is best practice for larger projects. The downside is that there is currently no easy way to restore a multi-file project from Working Copy back to Codea. This could change if Codea gets iOS 8 "open in"/ share pane functionality.  To "pull", you'll currently have to use one of the other Git Codea clients, such as the excellent Codea-SCM.

3. Each time you want to save a version, enter Working Copy client from within your Codea project, enter a message describing whatever change you made into the commit text box, and press "commit"

Special bonus feature: if your project has a tab named README with some text surrounded by --\[\[ \]\], Working Copy Client will strip out the braces and save the tab in the root level of the repository with a `.md` extension.

[^note1]: The project name is found by looking for the `-- <project name>` string that Codea places at the top of the Main tab. Make sure you don't put anything before this in the Main tab, or change this line.

  