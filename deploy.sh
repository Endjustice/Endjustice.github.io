#!/data/data/com.termux/files/usr/bin/bash

echo "🔍 شروع عملیات نهایی..."

# ۱. کپی آیکون از مسیر گوشی
SOURCE_ICON="/storage/emulated/0/pictures/ic_launcher.png"
DEST_DIR="app/src/main/res/mipmap-mdpi"
if [ -f "$SOURCE_ICON" ]; then
    mkdir -p "$DEST_DIR"
    cp "$SOURCE_ICON" "$DEST_DIR/ic_launcher.png"
    echo "✅ آیکون با موفقیت جایگزین شد."
else
    echo "❌ خطا: فایل آیکون پیدا نشد."
    exit 1
fi

# ۲. تنظیم مانیفست
sed -i 's/android:icon="[^"]*"/android:icon="@mipmap\/ic_launcher"/g' app/src/main/AndroidManifest.xml

# ۳. ایجاد فایل YAML با متغیرهای اصلاح شده (حروف بزرگ و بدون آندرلاین)
mkdir -p .github/workflows
cat <<EOF > .github/workflows/android_build.yml
name: Android CI/CD for Endjustice
on:
  push:
    branches: [ "main" ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: gradle
      - name: Grant Execute Permission
        run: chmod +x gradlew
      - name: Build Release APK
        run: ./gradlew assembleRelease
      - name: Sign APK
        uses: r0adkll/sign-android-release@v1
        id: sign_app
        with:
          releaseDirectory: app/build/outputs/apk/release
          signingKeyBase64: \${{ secrets.SIGNING_KEY }}
          alias: \${{ secrets.ALIAS }}
          keyStorePassword: \${{ secrets.KEY_STORE_PASSWORD }}
          keyPassword: \${{ secrets.KEY_PASSWORD }}
        env:
          BUILD_TOOLS_VERSION: "33.0.1"
      - name: Upload to GitHub Releases
        uses: softprops/action-gh-release@v1
        with:
          tag_name: build-\${{ github.run_number }}
          name: Release \${{ github.run_number }}
          files: app/build/outputs/apk/release/*.apk
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF

# ۴. ارسال به گیت‌هاب
git add .
git commit -m "Fix: Corrected secret variable names for signing"
git push origin main --force

