dep 'stewie' do
  [
    'common osx',
    'macbook powermode',
    'macbook hibernate image',
    'stewie hostname',
  ].each{ |p| requires p }
end

dep 'stewie hostname' do
  met? {
    [
      'scutil --get ComputerName',
      'scutil --get HostName',
      'scutil --get LocalHostName',
      'defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName',
    ].map{ |cmd| `#{cmd}`.strip }.uniq == ['stewie']
  }

  meet {
    hostname = 'stewie'
    [
      "sudo scutil --set ComputerName '#{hostname}'",
      "sudo scutil --set HostName '#{hostname}'",
      "sudo scutil --set LocalHostName '#{hostname}'",
      "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string '#{hostname}'",
    ].map{ |cmd| `#{cmd}` }
  }
end

dep 'macbook powermode' do
  met? {
    data = `pmset -g custom`.strip.split("\n").map(&:strip).map(&:split)
    mode = data.select{ |k,v| k == 'hibernatemode' }.map{ |_,v| v } == %w{0 0}
    sleep = data.select{ |k,v| k == 'sleep' }.map{ |_,v| v } == %w{120 180}
    display = data.select{ |k,v| k == 'displaysleep' }.map{ |_,v| v } == %w{10 10}
    standbydelay = data.select{ |k,v| k == 'standbydelay' }.map{ |_,v| v } == %w{43200 43200} # Write sleep image after 12 hours
    p data.select{ |k,v| k == 'standbydelay' }.map{ |_,v| v }
    mode && sleep && display && standbydelay
  }
end

dep 'macbook hibernate image' do
  met? {
    not File.exists?('/var/vm/sleepimage')
  }
end


