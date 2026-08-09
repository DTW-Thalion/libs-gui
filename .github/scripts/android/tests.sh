#!/bin/bash
#
# Build and run libs-gui's tests on the Android emulator.
#
# Each test .m is compiled directly with clang rather than through
# gnustep-make: the test directories carry no GNUmakefile of their own,
# gnustep-tests instantiates one from a template at run time, and driving
# gnustep-make per set does not cross compile.  This mirrors what libs-base's
# Android runner does.
#
# Everything runs under /data/local/tests.  Its shell_test_data_file label is
# what lets the shell domain create files and sockets, and it is writable
# without disabling SELinux.
#
set -u

: "${ANDROID_NDK_HOME:?}"
: "${GS_PREFIX:?}"
: "${GS_GUI:?}"
: "${GS_API:=31}"
: "${GS_TRIPLE:=x86_64-linux-android}"
GS_DISPATCH_PREFIX="${GS_DISPATCH_PREFIX:-$GS_PREFIX/../dispatch-prefix}"
GS_DISPATCH_PREFIX=$(cd "$GS_DISPATCH_PREFIX" && pwd)
GSROOT="$GS_PREFIX/gnustep"
GS_WORK="${GS_WORK:-$HOME/gs-run}"
GS_TIMEOUT="${GS_TIMEOUT:-120}"

TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
CCPREFIX="$TOOLCHAIN/bin/${GS_TRIPLE}${GS_API}"
TF=$(find "$GSROOT" -type d -name TestFramework | head -1)
[ -n "$TF" ] || { echo "no TestFramework under $GSROOT"; exit 1; }

EXPECTED="$GS_GUI/.github/scripts/android/expected-failures.txt"

DEV=/data/local/tests/gsgui
ROOT=/data/local/tests/gsroot
UHOME=/data/local/tests/gshome
TMP=/data/local/tests/gstmp
CONF=$ROOT/etc/GNUstep/GNUstep.conf
W="$GS_WORK"

say() { echo "== $*"; }

# tools-make installs either the GNUstep layout ($GSROOT/Local/Library/...) or
# the FHS one ($GSROOT/lib, $GSROOT/include), depending on how it was
# configured.  Find what was installed rather than assuming a path.
BASELIB=$(find "$GSROOT" -name 'libgnustep-base.so' 2>/dev/null | head -1)
[ -n "$BASELIB" ] || { echo "no libgnustep-base.so under $GSROOT"; exit 1; }
BASELIBDIR=$(dirname "$BASELIB")
FOUNDATION_H=$(find "$GSROOT" -path '*/Foundation/NSObject.h' 2>/dev/null | head -1)
[ -n "$FOUNDATION_H" ] || { echo "no Foundation headers under $GSROOT"; exit 1; }
BASEINC=$(dirname "$(dirname "$FOUNDATION_H")")
echo "  base library: $BASELIBDIR"
echo "  base headers: $BASEINC"

INC="-I$GS_GUI/Headers -I$GS_GUI/Source -I$TF -I$GS_PREFIX/include \
 -I$BASEINC -I$GS_DISPATCH_PREFIX/include \
 -I$GS_GUI/Tests/gui"
LIBS="-L$GS_GUI/Source/obj -lgnustep-gui \
 -L$BASELIBDIR -lgnustep-base \
 -L$GS_PREFIX/lib -lobjc -licuuc -licui18n -licudata -liconv \
 -L$GS_DISPATCH_PREFIX/lib -ldispatch -lm"
FLAGS="-fobjc-runtime=gnustep-2.2 -fblocks -fexceptions -DGNUSTEP \
 -DGNUSTEP_BASE_LIBRARY=1 -Wno-deprecated-declarations -Wno-objc-method-access"

adb wait-for-device
adb shell 'echo device ready; id' </dev/null

say "preparing the device"
adb shell "rm -rf $DEV" >/dev/null 2>&1 </dev/null
adb shell "mkdir -p $DEV $UHOME/GNUstep/Defaults $TMP && chmod 777 $TMP" \
  >/dev/null 2>&1 </dev/null

rm -rf "$W"; mkdir -p "$W"
cp "$GS_GUI"/Source/obj/libgnustep-gui.so.* "$W/" 2>/dev/null
cp "$BASELIBDIR"/libgnustep-base.so.* "$W/" 2>/dev/null
cp "$GS_PREFIX/lib/libobjc.so" "$W/"
cp "$TOOLCHAIN/sysroot/usr/lib/$GS_TRIPLE/libc++_shared.so" "$W/" 2>/dev/null
cp "$GS_PREFIX"/lib/libicu*.so* "$W/" 2>/dev/null
cp "$GS_PREFIX"/lib/libiconv*.so* "$W/" 2>/dev/null
cp "$GS_DISPATCH_PREFIX/lib/libdispatch.so" "$W/" 2>/dev/null

say "compiling the tests"
NB=0; OK=0
: > "$W/nobuild.txt"
for d in "$GS_GUI"/Tests/gui/*/; do
  n=$(basename "$d")
  ls "$d"*.m >/dev/null 2>&1 || continue
  mkdir -p "$W/$n"
  find "$d" -maxdepth 1 -type f -exec cp {} "$W/$n/" \; 2>/dev/null
  sed -e 's/@TESTNAMES@//; s^@TESTOPTS@^^; s/@TESTRULES@//' \
    "$TF/GNUmakefile.in" > "$W/$n/GNUmakefile" 2>/dev/null
  for sub in "$d"*/; do
    [ -d "$sub" ] || continue
    case "$(basename "$sub")" in obj|derived_src) continue ;; esac
    cp -rL "$sub" "$W/$n/" 2>/dev/null
  done
  for f in "$d"*.m; do
    b=$(basename "$f" .m)
    if $CCPREFIX-clang $FLAGS $INC -I"$d" -o "$W/$n/$b" "$f" $LIBS \
         > "$W/cc-$n-$b.log" 2>&1; then
      OK=$((OK+1))
    else
      NB=$((NB+1)); echo "$n/$b" >> "$W/nobuild.txt"; rm -f "$W/$n/$b"
    fi
  done
done
say "compiled $OK executables, $NB did not build"
[ "$NB" -eq 0 ] || sed 's/^/    /' "$W/nobuild.txt"

say "deploying"
adb push "$W"/. $DEV >/dev/null 2>&1 </dev/null
SO=$(basename "$(ls "$GS_GUI"/Source/obj/libgnustep-gui.so.*.* 2>/dev/null | head -1)")
BSO=$(basename "$(ls "$BASELIBDIR"/libgnustep-base.so.*.* 2>/dev/null | head -1)")
adb shell "cd $DEV && ln -sf $SO libgnustep-gui.so && ln -sf $SO ${SO%.*} && \
  ln -sf $BSO libgnustep-base.so && ln -sf $BSO ${BSO%.*}" >/dev/null 2>&1 </dev/null

# A real GNUstep tree, so the backend bundle and the plist DTD resolve.
GT="$W/gsroot"; cp -rL "$GSROOT" "$GT" 2>/dev/null
sed "s|$GSROOT|$ROOT|g" "$GSROOT/etc/GNUstep/GNUstep.conf" \
  > "$GT/etc/GNUstep/GNUstep.conf" 2>/dev/null
adb shell "mkdir -p $ROOT" >/dev/null 2>&1 </dev/null
adb push "$GT"/. $ROOT >/dev/null 2>&1 </dev/null
# base discards a config file that is group or world writable, and adb push
# creates 0666.
adb shell "chmod 644 $CONF" >/dev/null 2>&1 </dev/null
adb shell "chmod -R 755 $ROOT/bin $ROOT/Local/Tools 2>/dev/null; true" \
  >/dev/null 2>&1 </dev/null

say "running"
RES="$W/results.txt"; : > "$RES"
: > "$W/noresult.txt"; : > "$W/unexpected.txt"
EMPTY=0
for d in "$GS_GUI"/Tests/gui/*/; do
  n=$(basename "$d")
  [ -d "$W/$n" ] || continue
  for f in "$W/$n"/*; do
    b=$(basename "$f")
    # a directory passes [ -x ]: .gorm, .nib and dummy are bundle-style DATA
    [ -f "$f" ] && [ -x "$f" ] || continue
    case "$b" in *.m|*.h|GNUmakefile*|obj) continue ;; esac
    out=$(adb shell "cd $DEV/$n && LD_LIBRARY_PATH=$DEV \
      GNUSTEP_CONFIG_FILE=$CONF HOME=$UHOME TMPDIR=$TMP \
      timeout -s KILL $GS_TIMEOUT ./$b 2>&1; echo RC=\$?" </dev/null | tr -d '\r')
    p=$(printf '%s\n' "$out" | grep -c '^Passed test')
    fl=$(printf '%s\n' "$out" | grep -c '^Failed test')
    h=$(printf '%s\n' "$out" | grep -c '^Dashed hope')
    # a guarded set that skips is a RESULT, not a silent gap
    sk=$(printf '%s\n' "$out" | grep -c '^Skipped set')
    echo "$n/$b passed=$p failed=$fl hopes=$h skipped=$sk" >> "$RES"
    if [ "$p" -eq 0 ] && [ "$fl" -eq 0 ] && [ "$sk" -eq 0 ]; then
      EMPTY=$((EMPTY+1))
      # Record WHY. An executable that says nothing may have been killed by the
      # timeout, aborted, or died before its first assertion, and those need
      # different fixes. Naming it without its exit status and last output
      # gives nobody enough to act on.
      rc=$(printf '%s\n' "$out" | sed -n 's/^RC=//p' | tail -1)
      case "$rc" in
        137) why="killed by the ${GS_TIMEOUT}s timeout" ;;
        139) why="segmentation fault" ;;
        134) why="aborted" ;;
        0)   why="exited 0 without running an assertion" ;;
        *)   why="exit ${rc:-unknown}" ;;
      esac
      {
        echo "$n/$b: $why"
        printf '%s\n' "$out" | grep -v '^RC=' | tail -4 | sed 's/^/      /'
      } >> "$W/noresult.txt"
    fi
    if [ "$fl" -gt 0 ] && ! grep -qx "$n/$b" "$EXPECTED" 2>/dev/null; then
      echo "$n/$b" >> "$W/unexpected.txt"
    fi
  done
done

say "totals"
awk '{for(i=1;i<=NF;i++){if($i~/^passed=/){split($i,a,"=");P+=a[2]}
                         if($i~/^failed=/){split($i,b,"=");F+=b[2]}
                         if($i~/^hopes=/){split($i,c,"=");H+=c[2]}
                         if($i~/^skipped=/){split($i,d,"=");K+=d[2]}}}
     END{printf "  %d passed, %d failed, %d dashed hopes, %d skipped sets\n",P,F,H,K}' "$RES"
echo "  $NB did not build, $EMPTY produced no result"

RC=0
if [ -s "$W/unexpected.txt" ]; then
  echo "== failures that are NOT in expected-failures.txt"
  sed 's/^/    /' "$W/unexpected.txt"
  RC=1
fi
if [ "$EMPTY" -gt 0 ]; then
  echo "== executables that produced no result at all"
  sed 's/^/    /' "$W/noresult.txt"
  RC=1
fi
if [ "$NB" -gt 0 ]; then
  echo "== executables that did not build"
  RC=1
fi
exit $RC
