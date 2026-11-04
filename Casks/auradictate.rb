cask "auradictate" do
  version "1.2.0"
  sha256 "1d8c5117b5e4f06fc73fea34c200d2269239481d6e2c6414f25c1134c62896f5"

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
