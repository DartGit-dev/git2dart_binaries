#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint libgit2dart.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'git2dart_binaries'
  s.version          = '1.6.2'
  s.summary          = 'Dart bindings to libgit2.'
  s.description      = <<-DESC
Dart bindings to libgit2.
                       DESC
  s.homepage         = 'https://github.com/DartGit-dev/git2dart_binaries'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Viktor Borisov' => 'vik.borisoff@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.vendored_libraries = 'libgit2-1.6.2.dylib'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
