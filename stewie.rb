dep 'stewie' do
  [
    'osx prefs',
    'command line tools',
    'zsh shell',
    'vim 7.3',
    'stewie hostname',
    'macbook powermode',
    'macbook hibernate image',
    'fonts',

    'osx ssd trim enabled',
  ].each{ |p| requires p }
end

dep 'osx ssd trim enabled' do
  met? {
    `system_profiler SPSerialATADataType | grep "TRIM Support:"`.strip =~ /Yes/
  }
end

dep 'osx prefs' do
  requires 'osx prefs scrollbar'
  requires 'osx prefs keyboard'
  requires 'osx prefs menubar opaque'
  requires 'osx prefs menubar battery'
end

dep 'osx prefs keyboard' do
  met? {
    `defaults read NSGlobalDomain KeyRepeat`.strip == '0'
  }

  meet {
    `defaults write NSGlobalDomain KeyRepeat -int 0`
  }
end

dep 'osx prefs scrollbar' do
  met? {
    `defaults read NSGlobalDomain AppleShowScrollBars`.strip == 'WhenScrolling'
  }
  meet {
    `defaults write NSGlobalDomain AppleShowScrollBars -string WhenScrolling`
  }
end

dep 'osx prefs menubar opaque' do
  met? {
    `defaults read -g AppleEnableMenuBarTransparency`.strip == '0'
  }
  meet {
    `defaults write -g AppleEnableMenuBarTransparency -bool false`
  }
end

dep 'osx prefs menubar battery' do
  met? {
    `defaults read com.apple.menuextra.battery ShowPercent`.strip == 'YES'
  }
  meet {
    `defaults write com.apple.menuextra.battery ShowPercent -string 'YES'`
  }
end


dep 'user font dir exists' do
  met? {
    "~/Library/Fonts".p.dir?
  }
  meet {
    log_shell "Creating ~/Library/Fonts", "mkdir ~/Library/Fonts"
  }
end

meta 'ttf' do
  accepts_list_for :source
  accepts_list_for :extra_source
  accepts_list_for :ttf_filename

  template {
    requires 'user font dir exists'
    prepare {
      setup_source_uris
    }
    met? {
      "~/Library/Fonts/#{ttf_filename.first}".p.exists?
    }
    meet {
      process_sources do
        Dir.glob("*.ttf") do |font|
          log_shell "Installing #{font}", "cp '#{font}' ~/Library/Fonts"
        end
      end
    }
  }
end

dep 'anonymous-pro.ttf' do
  source 'http://www.marksimonson.com/assets/content/fonts/AnonymousPro-1.002.zip'
  ttf_filename 'Anonymous Pro.ttf'
end

dep 'fonts' do
  requires 'anonymous-pro.ttf'
end


dep 'macbook powermode' do
  met? {
    data = `pmset -g custom`.strip.split("\n").map(&:strip).map(&:split)
    mode = data.select{ |k,v| k == 'hibernatemode' }.map{ |_,v| v } == %w{0 0}
    sleep = data.select{ |k,v| k == 'sleep' }.map{ |_,v| v } == %w{120 180}
    display = data.select{ |k,v| k == 'displaysleep' }.map{ |_,v| v } == %w{10 10}
    mode && sleep && display
  }
end

dep 'macbook hibernate image' do
  met? {
    not File.exists?('/var/vm/sleepimage')
  }
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

dep 'vim 7.3' do
  met? {
    `vim --version |grep "Vi IMproved 7.3"`
  }
end


# Unix Tools

dep 'ack.managed'
dep 'curl.managed'
dep 'git.managed'

dep 'htop-osx.managed' do
  provides 'htop'
end

dep 'wget.managed'
dep 'zsh.managed'

dep 'mercurial.managed' do
  provides 'hg'
end

dep 'zsh-completions.managed' do
  met? {
    `brew list zsh-completions` !~ /No such keg/
  }
end

dep 'command line tools' do
  %w{ack wget curl git htop-osx}.each do |tool|
    requires "#{tool}.managed"
  end
end

dep 'zsh shell' do
  requires 'zsh.managed',
           'zsh-completions.managed'
end
