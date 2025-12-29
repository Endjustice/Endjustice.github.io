#!/data/data/com.termux/files/usr/bin/bash

echo "🔍 شروع عملیات با آیکون جدید..."

# دسترسی به حافظه گوشی اگر قبلاً داده نشده
termux-setup-storage -y 2>/dev/null

# ۱. کپی دقیق آیکون از مسیری که گفتی
SOURCE_ICON="/storage/emulated/0/pictures/ic_launcher.png"
DEST_DIR="app/src/main/res/mipmap-mdpi"

if [ -f "$SOURCE_ICON" ]; then
    mkdir -p "$DEST_DIR"
    cp "$SOURCE_ICON" "$DEST_DIR/ic_launcher.png"
    echo "✅ آیکون جدید از Pictures با موفقیت جایگزین شد."
else
    echo "❌ خطا: فایل در مسیر $SOURCE_ICON یافت نشد!"
    exit 1
fi

# ۲. اطمینان از تنظیم بودن مانیفست
MANIFEST="app/src/main/AndroidManifest.xml"
sed -i 's/android:icon="[^"]*"/android:icon="@mipmap\/ic_launcher"/g' "$MANIFEST"

# ۳. ایجاد فایل تنظیمات بیلد (YAML) - بدون تغییر نسبت به قبل
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
          key_store_password: \${{ secrets.KEY_STORE_PASSWORD }}
          key_password: \${{ secrets.KEY_PASSWORD }}
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
git commit -m "Fix: New icon from Pictures folder"
git push origin main --force

