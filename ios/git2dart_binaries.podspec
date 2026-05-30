#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'git2dart_binaries'
  s.version          = '1.11.0'
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
  binary_root = '$(PODS_ROOT)/../.symlinks/plugins/git2dart_binaries/ios'
  device_library_search_paths = [
    '$(inherited)',
    "#{binary_root}/libcrypto.xcframework/ios-arm64",
    "#{binary_root}/libssl.xcframework/ios-arm64",
    "#{binary_root}/libssh2.xcframework/ios-arm64",
    "#{binary_root}/libgit2.xcframework/ios-arm64"
  ].map { |path| "\"#{path}\"" }.join(' ')
  simulator_library_search_paths = [
    '$(inherited)',
    "#{binary_root}/libcrypto.xcframework/ios-arm64-simulator",
    "#{binary_root}/libssl.xcframework/ios-arm64-simulator",
    "#{binary_root}/libssh2.xcframework/ios-arm64-simulator",
    "#{binary_root}/libgit2.xcframework/ios-arm64-simulator"
  ].map { |path| "\"#{path}\"" }.join(' ')
  binary_xcconfig = {
    'LIBRARY_SEARCH_PATHS[sdk=iphoneos*]' => device_library_search_paths,
    'LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*]' => simulator_library_search_paths,
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -force_load "$(PODS_ROOT)/../.symlinks/plugins/git2dart_binaries/ios/libgit2.xcframework/ios-arm64/libgit2.a"',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -force_load "$(PODS_ROOT)/../.symlinks/plugins/git2dart_binaries/ios/libgit2.xcframework/ios-arm64-simulator/libgit2.a"'
  }
  s.pod_target_xcconfig = binary_xcconfig.merge({ 'DEFINES_MODULE' => 'YES' })
  s.user_target_xcconfig = binary_xcconfig
  s.swift_version = '5.0'
end
