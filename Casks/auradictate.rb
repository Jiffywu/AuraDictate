cask "auradictate" do
  version "1.2.0"
  sha256 "0df986c52823c663a32327ec8cfa97f71ce6e9111796c263ef33b3f44c4daaa5"

  url "https://github.com/Jiffywu/AuraDictate/releases/download/v#{version}/AuraDictate-macos-arm64.zip"
  name "Aura Dictate"
  desc "Lightweight on-device push-to-talk voice dictation for macOS"
  homepage "https://github.com/Jiffywu/AuraDictate"

  depends_on macos: ">= :tahoe"
  depends_on arch: :arm64

  app "AuraDictate.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/AuraDictate.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Preferences/com.jeffreynguyen.AuraDictate.plist",
  ]
end
