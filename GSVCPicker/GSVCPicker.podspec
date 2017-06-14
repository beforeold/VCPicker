#  引用命令 pod 'GSVCPicker', :svn =>"https://192.168.1.9/svn/IOS/otherprojects/GSKit/GSVCPicker"


Pod::Spec.new do |s|

  s.name         = "GSVCPicker"
  s.version      = "1.3"
  s.summary      = "this is a GSVCPicker."

  s.description  = <<-DESC
                   just use it!
                   DESC
  s.homepage     = "http://www.souhuow.com"

  s.license      = "MIT"

  s.author       = { "luffy" => "83831617@qq.com"}
 
  s.platform     = :ios, "8.0"

  s.source       = { ", :tag => "#{s.version}" }

  s.source_files = 'GSVCPicker/*.{h,m}'
 
end
