#!/bin/bash
#
# Cross-build tools-make, libs-base, libs-gui and libs-back for Android.
#
# libs-back is configured with the headless server AND headless graphics.  That
# backend draws nothing: every DPS primitive in HeadlessGState is an empty body
# and HeadlessFontEnumerator finds no font.  It is built only so that a backend
# bundle exists for AppKit to load, which is deliberate.  With an inert backend
# underneath, a libs-gui test failure is an AppKit or base porting problem
# rather than a backend problem.
#
set -eu

: "${ANDROID_NDK_HOME:?}"
: "${GS_PREFIX:?}"
: "${GS_BASE:?}"                     # the libs-base checkout
: "${GS_GUI:?}"                      # the libs-gui checkout
: "${GS_API:=31}"
: "${GS_TRIPLE:=x86_64-linux-android}"
GS_SRC="${GS_SRC:-$HOME/gs-src}"
GS_DISPATCH_PREFIX="${GS_DISPATCH_PREFIX:-$GS_PREFIX/../dispatch-prefix}"
GS_DISPATCH_PREFIX=$(cd "$GS_DISPATCH_PREFIX" && pwd)
GSROOT="$GS_PREFIX/gnustep"

TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
CCPREFIX="$TOOLCHAIN/bin/${GS_TRIPLE}${GS_API}"
JOBS=$(nproc)
say() { echo "== $*"; }

# ------------------------------------------------------------- tools-make
find_gnustep_sh() { find "$GSROOT" -name GNUstep.sh -path '*Makefiles*' 2>/dev/null | head -1; }

if [ -z "$(find_gnustep_sh)" ]; then
  say "tools-make (cross)"
  [ -d "$GS_SRC/tools-make" ] || git clone -q --depth 1 \
    https://github.com/gnustep/tools-make.git "$GS_SRC/tools-make"
  cd "$GS_SRC/tools-make"
  ./configure --prefix="$GSROOT" \
    --host="$GS_TRIPLE" --target="$GS_TRIPLE" \
    --with-library-combo=ng-gnu-gnu \
    CC="$CCPREFIX-clang" \
    CPPFLAGS="-I$GS_PREFIX/include" \
    LDFLAGS="-L$GS_PREFIX/lib -fuse-ld=lld" \
    LIBS="-lobjc" > "$GS_SRC/tools-make-configure.log" 2>&1 || {
      echo "tools-make configure failed"
      tail -25 "$GS_SRC/tools-make-configure.log"; exit 1; }
  make -j"$JOBS" >/dev/null && make install >/dev/null
fi

GSMAKE_SH=$(find_gnustep_sh)
[ -n "$GSMAKE_SH" ] || { echo "tools-make installed no GNUstep.sh"; exit 1; }
echo "   GNUstep.sh: $GSMAKE_SH"

# ------------------------------------------------------- host tool wrappers
# plmerge, pl2link and defaults run on the BUILD machine.  Sourcing the Android
# GNUstep.sh puts the cross-built copies in $GSROOT/Local/Tools on PATH and
# points LD_LIBRARY_PATH at Android libraries, so the host binaries exit 127
# with "invalid ELF header".  Wrap the host ones and put them first.
HOSTTOOLS="$GS_SRC/hosttools"
mkdir -p "$HOSTTOOLS"
for t in plmerge pl2link defaults; do
  real=$(command -v "$t" || true)
  [ -n "$real" ] || { echo "missing host tool: $t"; exit 1; }
  rm -f "$HOSTTOOLS/$t"
  printf '#!/bin/sh\nexec env -u LD_LIBRARY_PATH %s "$@"\n' "$real" > "$HOSTTOOLS/$t"
  chmod +x "$HOSTTOOLS/$t"
done

CROSS="${GS_CROSS_CONFIG:-$GS_GUI/.github/scripts/android/android.cross.config}"
[ -f "$CROSS" ] || { echo "missing cross config: $CROSS"; exit 1; }

# GNUstep.sh reads variables that are not set, which `set -u` treats as fatal.
set +u
# shellcheck disable=SC1091
. "$GSMAKE_SH"
set -u
export PATH="$HOSTTOOLS:$PATH"
export CC="$CCPREFIX-clang" CXX="$CCPREFIX-clang++"
export PKG_CONFIG_PATH="$GS_PREFIX/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$GS_PREFIX/lib/pkgconfig"
GNUTLS_LIBS=$(pkg-config --static --libs gnutls)
# libobjc2's Block.h must win over libdispatch's, so its include comes first.
export CPPFLAGS="-I$GS_PREFIX/include -I$GS_DISPATCH_PREFIX/include"
export LDFLAGS="-L$GS_PREFIX/lib -L$GS_DISPATCH_PREFIX/lib -fuse-ld=lld"
export LIBS="-liconv $GNUTLS_LIBS"
export XML2_CONFIG="$GS_PREFIX/bin/xml2-config"

# gnustep-make does not put the environment's CPPFLAGS on its own compile
# lines. ADDITIONAL_INCLUDE_DIRS is the variable it honours, and base's
# NSOperation.h includes dispatch/dispatch.h whenever GS_USE_LIBDISPATCH is 1,
# so libs-gui does not compile without the dispatch include reaching it.
export ADDITIONAL_INCLUDE_DIRS="-I$GS_PREFIX/include -I$GS_DISPATCH_PREFIX/include"

# tools-make installs either layout depending on how it was configured:
# $GSROOT/System/Library/Libraries and friends, or the FHS $GSROOT/lib and
# $GSROOT/share. Ask where the library actually is rather than assuming, or the
# already-built check silently misses and every path printed after it is wrong.
find_baselib() { find "$GSROOT" -name 'libgnustep-base.so' 2>/dev/null | head -1; }

# ---------------------------------------------------------------- libs-base
if [ -z "$(find_baselib)" ]; then
  say "libs-base configure"
  cd "$GS_BASE"
  ./configure --host="$GS_TRIPLE" --prefix="$GSROOT" \
    --with-cross-compilation-info="$CROSS" \
    --with-xml-prefix="$GS_PREFIX" --with-curl="$GS_PREFIX" \
    --with-dispatch-include="$GS_DISPATCH_PREFIX/include" \
    --with-dispatch-library="$GS_DISPATCH_PREFIX/lib" \
    > "$GS_BASE/android-configure.log" 2>&1 || {
      echo "configure failed"; tail -40 "$GS_BASE/android-configure.log"; exit 1; }
  say "libs-base build"
  make -j"$JOBS" > "$GS_BASE/android-build.log" 2>&1 || {
    echo "build failed"; grep -E "error:" "$GS_BASE/android-build.log" | head -20; exit 1; }
  say "libs-base install"
  make install > "$GS_BASE/android-install.log" 2>&1 || {
    echo "install failed"; tail -25 "$GS_BASE/android-install.log"; exit 1; }
fi
BASELIB=$(find_baselib)
[ -n "$BASELIB" ] || { echo "libs-base installed no libgnustep-base.so under $GSROOT"; exit 1; }
echo "    base: $BASELIB"

# ----------------------------------------------------------------- libs-gui
say "libs-gui configure"
cd "$GS_GUI"
./configure --host="$GS_TRIPLE" --prefix="$GSROOT" \
  > "$GS_GUI/android-configure.log" 2>&1 || {
    echo "configure failed"; tail -40 "$GS_GUI/android-configure.log"; exit 1; }

# The image libraries are built on purpose: code behind #if HAVE_LIBJPEG and
# friends is compiled away otherwise and gets no coverage at all.
say "image libraries picked up by configure"
grep -E '^ac_cv_lib_(jpeg|tiff|png|gif)' config.log | sort -u | sed 's/^/    /'
for v in ac_cv_lib_png_png_sig_cmp ac_cv_lib_jpeg_jpeg_destroy_decompress \
         ac_cv_lib_tiff_TIFFReadScanline ac_cv_lib_gif_DGifOpen; do
  grep -q "^$v=yes" config.log || { echo "$v is not yes; the image paths would be compiled out"; exit 1; }
done

say "libs-gui build"
make -j"$JOBS" > "$GS_GUI/android-build.log" 2>&1 || {
  echo "build failed"; grep -E "error:" "$GS_GUI/android-build.log" | head -20; exit 1; }
ls -l Source/obj/libgnustep-gui.so.* | sed 's/^/    /'

say "libs-gui install"
make install > "$GS_GUI/android-install.log" 2>&1 || {
  echo "install failed"; tail -25 "$GS_GUI/android-install.log"; exit 1; }

# ---------------------------------------------------------------- libs-back
# Cloned rather than checked out by the workflow: only the bundle is wanted.
if [ ! -d "$GS_SRC/libs-back" ]; then
  git clone -q --depth 1 https://github.com/gnustep/libs-back.git "$GS_SRC/libs-back"
fi
say "libs-back configure (headless server, headless graphics)"
cd "$GS_SRC/libs-back"
# --without-freetype is needed even though graphics=headless never uses it:
# configure.ac runs PKG_CHECK_MODULES([FREETYPE], [freetype2]) before the
# graphics selection with no action-if-not-found, so it is fatal otherwise.
./configure --host="$GS_TRIPLE" --prefix="$GSROOT" \
  --enable-server=headless --enable-graphics=headless --without-freetype \
  > "$GS_SRC/back-configure.log" 2>&1 || {
    echo "configure failed"; tail -30 "$GS_SRC/back-configure.log"; exit 1; }
grep -E '^BUILD_SERVER|^BUILD_GRAPHICS' config.make | sed 's/^/    /'
for v in "BUILD_SERVER=headless" "BUILD_GRAPHICS=headless"; do
  grep -q "^$v\$" config.make || { echo "expected $v"; exit 1; }
done

say "libs-back build and install"
make -j"$JOBS" > "$GS_SRC/back-build.log" 2>&1 || {
  echo "build failed"; grep -E "error:" "$GS_SRC/back-build.log" | head -20; exit 1; }
make install > "$GS_SRC/back-install.log" 2>&1 || {
  echo "install failed"; tail -25 "$GS_SRC/back-install.log"; exit 1; }
find "$GSROOT" -maxdepth 6 -name 'libgnustep-back*.bundle' | sed 's/^/    /'

say "cross build complete"
