---
layout: layout
title: "QH - Release Notes"
---

# v1.x
Unplanned features and ideas, wish list...

- [NEW] Configure polling periods for all tasks
- [NEW] Click on notifications brings user to the right Github page
- [NEW] Display API limit quota
- [NEW] Local search engine
- [NEW] Hot keys!
- [NEW] Local storage in order to be able to rebuild all even if Internet is down!

# v1.4.1 - 2012/01/30

- [IMPROVEMENT] The menu items are now listed in alphabetical order for repositories, organizations and users
- [IMPROVEMENT] Better Growl messages
- [FIX] Some Growl notifications are lost
- [FIX] Several typos

# v1.4 - 2012/01/06

- [NEW] Create issues for your repositories. Description is DnD enabled
- [NEW] Create repositories for organizations
- [IMPROVEMENT] Better issues display with repository name as prefix
- [IMPROVEMENT] Issue item now have the submitter avatar as icon
- [IMPROVEMENT] Better error display when creating repositories
- [IMPROVEMENT] Data is loaded in the background...
- [FIX] Bad link on 'Repositories/Open' menu item
- [FIX] Fix windows close
- [FIX] Fix wiki and issues choice when creating repository
- [FIX] Regression on the number of items returned by the API call

# v1.3 - 2011/12/06

- [NEW] OAuth support. No more Basic Auth: QuickHub does not need to know your GitHub password!
- [NEW] OS X Service added to create Gists from Services menus (on application and on Finder)
- [NEW] User can now create repositories from the repositories menu
- [NEW] When Internet is down, change the 'Open GitHub...' menu to 'No Internet connection'
- [NEW] Add option to open Gist when created
- [IMPROVEMENT] Better preferences and main menu cleaned from 'QuickHub Help' 
- [IMPROVEMENT] Better data loading in the background to avoid freezes
- [IMPROVEMENT] Better menu update support when creating things...

# v1.2 - 2011/11/17

- [NEW] Save the new created gist URL in clipboard
- [NEW] Allow drag and drop for gist creation. User can now drag and drop file from Finder to the Gist creation window
- [NEW] Pull requests support
- [IMPROVEMENT] Forks now have their own icons
- [IMPROVEMENT] Add clean button to gist creation window
- [IMPROVEMENT] Better logo, but not final
- [IMPROVEMENT] Change the Gist creation window color for better readability
- [IMPROVEMENT] Display default messages in empty menus
- [IMPROVEMENT] Clean error messages, no more HTTP details
- [FIX] Fix menus update when Growl is not installed

# v1.1 - 2011/11/06
The version 1.1 comes with many improvements, new features and bug fixes:

- [NEW] Added following and followers menus
- [NEW] Added watched repositories
- [NEW] User can now create public and private gists from QuickHub
- [NEW] Notifications from created Gists are clickable and brings user to the Gist page
- [IMPROVEMENT] All artifacts now have icons in menu. Green bullets for public things, red for private ones. Avatars are also displayed for organizations and people
- [FIX] Fix Internet connection availability problems: On startup, QuickHub now start to get data only if Internet connection is up. At runtime, QuickHub detects when Internet is up or down and so starts or stops getting things from GitHub.

# v1.0 - 2011/10/28
The initial version provides Growl support to notify user when something change (added or deleted) on user repositories, gists and issues. It also allows the user to have direct access to:

- Private and public repositories
- Organization and associated repositories
- Open issues assigned to the user
- Gists

From the preference panel, the user can configure its GitHub credentials and choose to start QuickHub at OS X startup.