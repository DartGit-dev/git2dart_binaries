#!/bin/bash
set -e

# Build libgit2 with OpenSSL for Android
# This script builds OpenSSL 3.0.15 and libgit2 1.9.1 with OpenSSL backend for Android
#
# Requirements:
# - Android NDK installed (tested with NDK 26.3.11579264)
# - CMake
# - Git
# - Standard Unix build tools (make, gcc, etc.)
#
# Usage:
#   export ANDROID_NDK_ROOT=/path/to/android/ndk
#   ./build_libgit2_with_openssl.sh
#
# Output:
#   Compiled libgit2.so in build/arm64-v8a/libgit2.so

# Configuration
OPENSSL_VERSION="3.0.15"
LIBGIT2_VERSION="1.9.1"
ANDROID_API_LEVEL=21
ARCHITECTURE="arm64-v8a"  # Options: armeabi-v7a, arm64-v8a, x86, x86_64

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate environment
if [ -z "$ANDROID_NDK_ROOT" ]; then
    log_error "ANDROID_NDK_ROOT is not set"
    log_info "Please set it to your Android NDK installation path"
    log_info "Example: export ANDROID_NDK_ROOT=\$HOME/Library/Android/sdk/ndk/26.3.11579264"
    exit 1
fi

if [ ! -d "$ANDROID_NDK_ROOT" ]; then
    log_error "ANDROID_NDK_ROOT directory does not exist: $ANDROID_NDK_ROOT"
    exit 1
fi

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/../build/android_openssl"
OPENSSL_SRC="$BUILD_DIR/openssl-src"
OPENSSL_INSTALL="$BUILD_DIR/openssl-install"
LIBGIT2_SRC="$BUILD_DIR/libgit2-src"
LIBGIT2_BUILD="$BUILD_DIR/libgit2-build"
OUTPUT_DIR="$SCRIPT_DIR/../android/src/main/jniLibs/$ARCHITECTURE"

# Map architecture names
case $ARCHITECTURE in
    "armeabi-v7a")
        OPENSSL_ARCH="android-arm"
        CMAKE_ARCH="armeabi-v7a"
        ;;
    "arm64-v8a")
        OPENSSL_ARCH="android-arm64"
        CMAKE_ARCH="arm64-v8a"
        ;;
    "x86")
        OPENSSL_ARCH="android-x86"
        CMAKE_ARCH="x86"
        ;;
    "x86_64")
        OPENSSL_ARCH="android-x86_64"
        CMAKE_ARCH="x86_64"
        ;;
    *)
        log_error "Unknown architecture: $ARCHITECTURE"
        exit 1
        ;;
esac

log_info "Building for architecture: $ARCHITECTURE ($OPENSSL_ARCH)"
log_info "Android API level: $ANDROID_API_LEVEL"
log_info "NDK: $ANDROID_NDK_ROOT"

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Step 1: Download and build OpenSSL
log_info "Step 1/5: Downloading OpenSSL $OPENSSL_VERSION"
if [ ! -d "$OPENSSL_SRC" ]; then
    git clone --depth 1 --branch "openssl-$OPENSSL_VERSION" \
        https://github.com/openssl/openssl.git "$OPENSSL_SRC"
else
    log_warn "OpenSSL source already exists, skipping download"
fi

log_info "Step 2/5: Building OpenSSL"
cd "$OPENSSL_SRC"

# Add NDK to PATH for OpenSSL build
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

# Configure OpenSSL for Android
log_info "Configuring OpenSSL..."
./Configure "$OPENSSL_ARCH" \
    -D__ANDROID_API__=$ANDROID_API_LEVEL \
    --prefix="$OPENSSL_INSTALL" \
    no-shared \
    no-tests

# Build and install OpenSSL
log_info "Compiling OpenSSL (this may take several minutes)..."
make clean || true
make -j$(sysctl -n hw.ncpu)

log_info "Installing OpenSSL to $OPENSSL_INSTALL"
make install_sw

log_info "OpenSSL build complete"
ls -lh "$OPENSSL_INSTALL/lib/"

# Step 2: Download libgit2
log_info "Step 3/5: Downloading libgit2 $LIBGIT2_VERSION"
cd "$BUILD_DIR"
if [ ! -d "$LIBGIT2_SRC" ]; then
    git clone --depth 1 --branch "v$LIBGIT2_VERSION" \
        https://github.com/libgit2/libgit2.git "$LIBGIT2_SRC"
else
    log_warn "libgit2 source already exists, skipping download"
fi

# Apply OpenSSL SSL_VERIFY_PEER patch
log_info "Applying SSL_VERIFY_PEER patch..."
cd "$LIBGIT2_SRC"
sed -i.bak 's/SSL_VERIFY_NONE/SSL_VERIFY_PEER/' src/libgit2/streams/openssl.c

if grep -q "SSL_VERIFY_PEER" src/libgit2/streams/openssl.c; then
    log_info "✓ SSL_VERIFY_PEER patch applied successfully"
else
    log_error "Failed to apply SSL_VERIFY_PEER patch"
    exit 1
fi

# Step 3: Configure libgit2 with CMake
log_info "Step 4/5: Configuring libgit2 with OpenSSL"
mkdir -p "$LIBGIT2_BUILD"
cd "$LIBGIT2_BUILD"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$CMAKE_ARCH" \
    -DANDROID_PLATFORM=android-$ANDROID_API_LEVEL \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF \
    -DUSE_HTTPS=OpenSSL \
    -DOPENSSL_ROOT_DIR="$OPENSSL_INSTALL" \
    -DOPENSSL_INCLUDE_DIR="$OPENSSL_INSTALL/include" \
    -DOPENSSL_SSL_LIBRARY="$OPENSSL_INSTALL/lib/libssl.a" \
    -DOPENSSL_CRYPTO_LIBRARY="$OPENSSL_INSTALL/lib/libcrypto.a" \
    "$LIBGIT2_SRC"

# Step 4: Build libgit2
log_info "Step 5/5: Building libgit2 (this may take several minutes)..."
make clean || true
make -j$(sysctl -n hw.ncpu)

if [ ! -f "libgit2.so" ]; then
    log_error "Build failed: libgit2.so not found"
    exit 1
fi

# Strip symbols to reduce size
log_info "Stripping symbols from libgit2.so"
"$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip" libgit2.so

# Get file sizes
ORIGINAL_SIZE=$(ls -lh libgit2.so | awk '{print $5}')
log_info "libgit2.so size: $ORIGINAL_SIZE"

# Copy to output directory
log_info "Copying libgit2.so to $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp libgit2.so "$OUTPUT_DIR/"

# Verify the output
if [ -f "$OUTPUT_DIR/libgit2.so" ]; then
    log_info "✓ Build successful!"
    log_info "Output: $OUTPUT_DIR/libgit2.so"
    log_info "Size: $(ls -lh "$OUTPUT_DIR/libgit2.so" | awk '{print $5}')"

    # Verify it's for the right architecture
    file "$OUTPUT_DIR/libgit2.so"

    # Test that it has OpenSSL symbols
    log_info "Verifying OpenSSL symbols..."
    if nm "$OUTPUT_DIR/libgit2.so" 2>/dev/null | grep -q "SSL_"; then
        log_info "✓ OpenSSL symbols found"
    else
        log_warn "OpenSSL symbols not found (this might be OK if stripped)"
    fi
else
    log_error "Failed to copy libgit2.so to output directory"
    exit 1
fi

# Print summary
log_info ""
log_info "========================================="
log_info "Build Summary"
log_info "========================================="
log_info "Architecture:     $ARCHITECTURE"
log_info "OpenSSL version:  $OPENSSL_VERSION"
log_info "libgit2 version:  $LIBGIT2_VERSION"
log_info "Output file:      $OUTPUT_DIR/libgit2.so"
log_info "File size:        $(ls -lh "$OUTPUT_DIR/libgit2.so" | awk '{print $5}')"
log_info "========================================="
log_info ""
log_info "Next steps:"
log_info "1. Update your Android app to initialize SSL certificates"
log_info "2. See ANDROID_SSL_SETUP.md for usage instructions"
log_info "3. Test HTTPS operations on a real device/emulator"
log_info ""
log_info "To build for other architectures:"
log_info "  export ARCHITECTURE=armeabi-v7a && $0"
log_info "  export ARCHITECTURE=x86_64 && $0"
