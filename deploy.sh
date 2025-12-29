#!/data/data/com.termux/files/usr/bin/bash

# انتقال آیکون
cp /storage/emulated/0/pictures/ic_launcher.png app/src/main/res/mipmap-mdpi/ic_launcher.png 2>/dev/null

# ساخت فایل YAML با نام متغیرهای صحیح
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

git add .
git commit -m "Final attempt: Correct Secrets and Key"
git push origin main --force

