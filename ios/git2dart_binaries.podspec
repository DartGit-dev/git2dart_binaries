#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'git2dart_binaries'
  s.version          = '1.10.4'
  s.summary          = 'Dart bindings to libgit2.'
  s.description      = <<-DESC
Dart bindings to libgit2.
                       DESC
  s.homepage         = 'https://github.com/DartGit-dev/git2dart_binaries'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Viktor Borisov' => 'vik.borisoff@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.static_framework = true
  s.vendored_frameworks = [
    'libcrypto.xcframework',
    'libssl.xcframework',
    'libssh2.xcframework',
    'libgit2.xcframework'
  ]
  s.libraries = ['z', 'iconv']

  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
