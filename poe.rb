dep 'poe' do
  [
    'common osx',

    'programming',

    'poe hostname',
  ].each{ |p| requires p }
end

dep 'poe hostname' do
  met? {
    [
      'scutil --get ComputerName',
      'scutil --get HostName',
      'scutil --get LocalHostName',
      'defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName',
    ].map{ |cmd| `#{cmd}`.strip }.uniq == ['poe']
  }

  meet {
    hostname = 'poe'
    [
      "sudo scutil --set ComputerName '#{hostname}'",
      "sudo scutil --set HostName '#{hostname}'",
      "sudo scutil --set LocalHostName '#{hostname}'",
      "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string '#{hostname}'",
    ].map{ |cmd| `#{cmd}` }
  }
end
