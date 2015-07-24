

# Working Copy Client

A light Codea client for committing code to Working Copy, a full iOS Git client. The free version supports local Git commits only. To push to a remote host such as GitHub, BitBucket, or your own server, please buy the full version of Working Copy.

## Installation

1. Install Working Copy on your iPad 

2. Set up some repositories in Working Copy to store your code. If you have a remote host on GutHub, BitBucket, your local server etc then you can clone your existing repositories. Otherwise you can initialise local repos on your device, and push them to the remote host later. Give large projects their own repository with the same name as their project name in Codea.[^note1] To store smaller projects that don't need their own repository, set up a repository called "Codea". This will save you having to set up repositories for every single Codea project.

3. In Working Copy settings, turn on "URL Callbacks" and copy the URL key to the clipboard.

4. The first time you run Working Copy Client in Codea, paste this URL key (from step 3) into the "Working Copy key" text box

## Usage

1. In Codea, make Working Copy Client a dependency of any project you want to push to Working Copy 

2. Enter a message describing whatever change you made into the commit text box

3. You now have the choice to "Commit as single file" or as "multiple files":

  - "single file" concatenates your project using Codea's "paste into project" format `--# tab name` and pushes it to the "Codea" repository in Working Copy, naming the file after its Codea project name.[^note1] This is appropriate for smaller projects. To restore a previous version, you can copy the file from Working Copy (share pane > Copy), and in Codea, "paste into project"

  - "multiple file" writes each tab as a separate file into a folder called "tabs" in a repository named after the project[^note1]. You'll get an error message if no repository with that name is found. This is best practice for larger projects. The downside is that there is currently no easy way to restore a multi-file project from Working Copy back to Codea. This could change if Codea gets iOS 8 "open in"/ share pane functionality.  To "pull", you'll currently have to use one of the other Git Codea clients, such as the excellent Codea-SCM.

Special bonus feature: if your project has a tab named README with some text surrounded by --\[\[ \]\], Working Copy Client will strip out the braces and save the tab in the root level of the repository with a .md extension.

[^note1]: The project name is found by looking for the `-- <project name>` string that Codea places at the top of the Main tab. Make sure you don't put anything before this in the Main tab

  