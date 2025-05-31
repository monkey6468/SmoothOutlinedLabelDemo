#
#  Be sure to run `pod spec lint WHCamera.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "SmoothOutlinedLabel"
  s.version      = "0.0.1"
  s.summary      = "A Library for iOS to use for SmoothOutlinedLabel."
  s.description  = <<-DESC
                    "是一个支持多行文本、描边（描边宽度与颜色）、文字阴影、自动换行、文字间距、最大行数以及省略号等功能的 自定义 UILabel 替代控件。"
                   DESC
  s.platform     = :ios, "7.0"
  s.homepage     = "https://github.com/monkey6468/SmoothOutlinedLabelDemo"
  s.license      = "MIT"
  s.author       = { "xiaoweihua" => "1019459067@qq.com" }
  s.source       = { :git => "https://github.com/monkey6468/SmoothOutlinedLabelDemo", :tag => "#{s.version}" }
  s.source_files  = "SmoothOutlinedLabel/*.{swift}"
end
