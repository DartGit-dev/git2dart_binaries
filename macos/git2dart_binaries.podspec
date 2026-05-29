#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint libgit2dart.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'git2dart_binaries'
  s.version          = '1.9.0'
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
  # The libgit2 dylib's install_name is @rpath/libgit2-experimental.1.9.dylib,
  # so the file must be vendored under that exact name or dyld can't find
  # it inside the .app bundle at runtime. libssh2.1.dylib is a transitive
  # dependency of libgit2 and must also be declared here so CocoaPods
  # embeds it into the bundle's Frameworks directory.
  s.vendored_libraries = ['libgit2-experimental.1.9.dylib', 'libssh2.1.dylib']

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
