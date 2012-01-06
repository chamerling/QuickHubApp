---
layout: post
title: Coming next in QuickHub 1.4
permalink: /2012/01/coming-next-in-quickhub14/
---

Hi all,

Christmas and holidays are over and so I am now able to provide a new version of QuickHub with fixes, improvements and also new features. One more time, thanks for your comments. Those ones are generally good ones but they are some bad on the App store... Looks like some prefers to give bad review instead of just dicussing directly. BTW I took those good and bad comments into account and the 1.4 release note reflects them:

- [NEW] Create issues for your repositories. *For now you can only create issues for your own repositories and not for the organization ones. I have to investigate more on the API side for that but it seems that it is not available or documented for now.*
- [NEW] Create repositories for organizations.* All is in the title...*
- [IMPROVEMENT] Better issues display with repository name as prefix. *Issues where displayed just with their title and so it was not easy to know the linked repository. So items are now prefixed in repository names (and organization name is needed).*
- [IMPROVEMENT] Issue item now have the submitter avatar as icon. 
- [IMPROVEMENT] Better error display when creating repositories.
- [IMPROVEMENT] Data is loaded in the background... *This one is important, data is loaded in the background so the UI will not freeze and app startup will be better.*
- [FIX] Bad link on 'Repositories/Open' menu item
- [FIX] Fix windows close
- [FIX] Fix wiki and issues choice when creating repository
- [FIX] Regression on the number of items returned by the API call

I am fixing some stuff and I will probably submit the application for Apple review on monday so that it should be available next week.

-- @chamerling