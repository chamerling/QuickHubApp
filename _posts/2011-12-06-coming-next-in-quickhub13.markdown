---
layout: post
title: Coming next in QuickHub 1.3
permalink: /2011/12/coming-next-in-quickhub13/
---

First of all, thanks for all your comments and feedbacks about QuickHub 1.2. It tooks some nights to add some interesting features to QuickHub which is under review process since last night.

The first feature is about OAuth support: You do not need to give QuickHub your github password anymore. All authentication and authorization is now OAuth based. On the QuickHub side, it means that you will be redirected to quickhubapp.com and then to github.com to validate QuickHub rights on your github data. Once validated, you will have to give QuickHub a key by clicking on a button provided by a specific QuickHub web application. Note that for users already using the application in the previous versions, you will just be asked to authorize on application startup.
I just want to thanks github support team for their reactivity on this topic. It is just amazing to see how quick they can react! So no more paranoia, you can just use QuickHub in a safe mode (please note that in all cases, the github API does not provide any operation to retrieve your password). So come on GitHub team, just tell me what you think about QuickHub :)

<img src="http://f.cl.ly/items/3C1e2k0x1k3G1k1E071f/quickhub-oauth-first.png"/>

The second feature is Gist centric. Gist is really a great tool to share snippets with the world (and in some cases, with your colleagues). In the last versions, you were able to create Gists from a QuickHub window which was also drag and drop enabled. In QuickHub 1.3, you will be able to create Gists from your OS X services menu too. It means that you can do a text selection from any application and use the operation *"Create a gist from selection"* from the context menu, or select a file and use the *"Create a Gist"* one. QuickHub will automatically fill the Gist creation window with selected stuff.

**Question to Gists addicts : Do you need something where we bypass the Gist creation window and push stuff automatically to github?
**

<img src="http://f.cl.ly/items/0o2Y2L1738451v080429/quickhub-creategistservicemenu.png">

Last important feature: You can now create repositories from QuickHub. There is a dedicated menu/window for that.

<img src="http://f.cl.ly/items/2e2x2S0x2W1J3E2y0L2B/quickhub-repocreate.png"/>

QuickHub 1.3 will probably be validated before the end of the week, just look at your Mac App Store icon or check [@chamerling](http://twitter.com/chamerling) tweets.

-- @chamerling