cask "auradictate" do
  version "1.1.0"
  sha256 "fc66231aa8d6bd02009b8d82a22f5a79e9857e1e3c96b88a9fdbf0535968c4cb"

  url "https://github.com/Jiffywu/AuraDictate-public/releases/download/v#{version}/AuraDictate-macos-arm64.zip"
  name "Aura Dictate"
  desc "Lightweight on-device push-to-talk voice dictation for macOS"
  homepage "https://github.com/Jiffywu/AuraDictate-public"

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
