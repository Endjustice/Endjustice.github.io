#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 شروع عملیات به‌روزرسانی (بدون تغییر در فایل کلید)..."

# ۱. کپی آیکون از حافظه گوشی به پوشه پروژه
SOURCE_ICON="/storage/emulated/0/pictures/ic_launcher.png"
DEST_DIR="app/src/main/res/mipmap-mdpi"

if [ -f "$SOURCE_ICON" ]; then
    mkdir -p "$DEST_DIR"
    cp "$SOURCE_ICON" "$DEST_DIR/ic_launcher.png"
    echo "✅ آیکون جدید جایگزین شد."
else
    echo "⚠️ هشدار: فایل آیکون در $SOURCE_ICON یافت نشد."
fi

# ۲. تنظیم مانیفست برای اطمینان از نمایش آیکون
sed -i 's/android:icon="[^"]*"/android:icon="@mipmap\/ic_launcher"/g' app/src/main/AndroidManifest.xml

# ۳. ایجاد فایل تنظیمات بیلد تک‌فایله (تمیز)
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

      - name: Rename and Cleanup
        run: |
          mv \${{ steps.sign_app.outputs.signedReleaseFile }} app/build/outputs/apk/release/MISTAKE619-Pro.apk

      - name: Upload to GitHub Releases
        uses: softprops/action-gh-release@v1
        with:
          tag_name: build-\${{ github.run_number }}
          name: Release \${{ github.run_number }}
          files: app/build/outputs/apk/release/MISTAKE619-Pro.apk
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF

# ۴. ارسال تغییرات به گیت‌هاب
echo "📤 در حال ارسال تغییرات به مخزن..."
git add .
git commit -m "Update: App icon and optimized build workflow"
git push origin main --force

echo "✨ عملیات با موفقیت انجام شد. بیلد را در گیت‌هاب چک کنید."

