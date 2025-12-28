#!/data/data/com.termux/files/usr/bin/bash

echo "🔍 در حال بررسی ساختار پروژه..."

# ۱. بررسی پوشه تنظیمات گیت‌هاب
if [ ! -d ".github/workflows" ]; then
    mkdir -p .github/workflows
    echo "✅ پوشه workflows ساخته شد."
fi

# ۲. اطمینان از وجود فایل اجرایی gradlew
if [ ! -f "gradlew" ]; then
    echo "⚠️ فایل gradlew یافت نشد. در حال ساخت فایل جایگزین..."
    printf "#!/usr/bin/env bash\n./gradlew \"\$@\"" > gradlew
    chmod +x gradlew
fi

# ۳. بررسی فایل تنظیمات بیلد (YAML)
if [ ! -f ".github/workflows/android_build.yml" ]; then
    echo "⚠️ فایل android_build.yml یافت نشد. در حال ایجاد..."
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

      - name: Upload to GitHub Releases
        uses: softprops/action-gh-release@v1
        with:
          tag_name: build-\${{ github.run_number }}
          name: Release \${{ github.run_number }}
          files: \${{ steps.sign_app.outputs.signedReleaseFile }}
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF
    echo "✅ فایل تنظیمات بیلد با موفقیت ایجاد شد."
fi

# ۴. عملیات گیت
echo "🚀 در حال آماده‌سازی برای ارسال به گیت‌هاب..."
git init 2>/dev/null
git remote add origin https://github.com/Endjustice/Endjustice.github.io.git 2>/dev/null

# هماهنگ‌سازی اجباری با سرور (Force Sync)
echo "📥 در حال هماهنگ‌سازی با سرور..."
git add .
git commit -m "Final check and deploy" 2>/dev/null
git branch -M main

echo "📤 در حال Push کردن (لطفاً Username و Token خود را وارد کنید)..."
git push -u origin main --force

echo "✨ تمام شد! حالا به تب Actions در گیت‌هاب بروید."
