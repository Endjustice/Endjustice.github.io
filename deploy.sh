# ... (بخش‌های قبلی اسکریپت مثل کپی آیکون و مانیفست ثابت بماند) ...

# ۳. اصلاح فایل YAML برای خروجی تمیز و تک‌فایل
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

      # مرحله جدید: تغییر نام فایل امضا شده برای پاکسازی خروجی
      - name: Rename Final APK
        run: mv \${{ steps.sign_app.outputs.signedReleaseFile }} app/build/outputs/apk/release/MISTAKE619-Pro.apk

      - name: Upload to GitHub Releases
        uses: softprops/action-gh-release@v1
        with:
          tag_name: build-\${{ github.run_number }}
          name: Release \${{ github.run_number }}
          # فقط فایل تغییر نام داده شده را آپلود کن
          files: app/build/outputs/apk/release/MISTAKE619-Pro.apk
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF

# ۴. ارسال به گیت‌هاب
git add .
git commit -m "Cleanup: Single Signed APK Output"
git push origin main --force

