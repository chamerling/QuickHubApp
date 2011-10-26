# This build the DMG using choctop, simply launch 'rake dmg'

require "rubygems"
require "rake"

require "choctop"

ChocTop::Configuration.new do |s|
  # Remote upload target (set host if not same as Info.plist['SUFeedURL'])
  # s.host     = 'quickhubapp.com'
  s.remote_dir = '/path/to/upload/root/of/app'

  # Custom DMG
  # s.background_file = "resources/background.jpg"
  # s.app_icon_position = [100, 90]
  # s.applications_icon_position =  [400, 90]
  # s.volume_icon = "dmg.icns"
  # s.applications_icon = "QuickHubLogo-128.png" # or "appicon.png"
end
