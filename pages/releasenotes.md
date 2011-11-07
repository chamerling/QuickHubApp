---
layout: layout
title: "QH - Release Notes"
---

# v1.1 - 2011/11/06
The version 1.1 comes with many improvements, new features and bug fixes:

- [IMPROVEMENT] All artifacts now have icons in menu. Green bullets for public things, red for private ones. Avatars are also displayed for organizations and people
- [NEW] Added following and followers menus
- [NEW] Added watched repositories
- [NEW] User can now create public and private gists from QuickHub
- [NEW] Notifications from created Gists are clickable and brings user to the Gist page
- [FIX] Fix Internet connection availability problems: On startup, QuickHub now start to get data only if Internet connection is up. At runtime, QuickHub detects when Internet is up or down and so starts or stops getting things from GitHub.

# v1.0 - 2011/10/28
The initial version provides Growl support to notify user when something change (added or deleted) on user repositories, gists and issues. It also allows the user to have direct access to:

- Private and public repositories
- Organization and associated repositories
- Open issues assigned to the user
- Gists

From the preference panel, the user can configure its GitHub credentials and choose to start QuickHub at OS X startup.