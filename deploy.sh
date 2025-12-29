#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 شروع عملیات به‌روزرسانی نهایی..."

# ۱. کپی آیکون از حافظه گوشی
SOURCE_ICON="/storage/emulated/0/pictures/ic_launcher.png"
DEST_DIR="app/src/main/res/mipmap-mdpi"
if [ -f "$SOURCE_ICON" ]; then
    mkdir -p "$DEST_DIR"
    cp "$SOURCE_ICON" "$DEST_DIR/ic_launcher.png"
    echo "✅ آیکون جدید جایگزین شد."
fi

# ۲. اصلاح خودکار MainActivity.java برای پشتیبانی از کپی و دکمه Back
MAIN_ACTIVITY="app/src/main/java/com/example/webwrapperapp/MainActivity.java"
cat <<EOF > $MAIN_ACTIVITY
package com.example.webwrapperapp;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        WebView webView = findViewById(R.id.webView);
        webView.setWebViewClient(new WebViewClient());
        
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true); // فعال‌سازی برای دکمه کپی
        webSettings.setDatabaseEnabled(true);
        webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
        
        webView.loadUrl("https://myai.kronos666.workers.dev/");
    }

    @Override
    public void onBackPressed() {
        WebView webView = findViewById(R.id.webView);
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
EOF
echo "✅ فایل MainActivity با تنظیمات مدرن به‌روزرسانی شد."

# ۳. تنظیم مانیفست
sed -i 's/android:icon="[^"]*"/android:icon="@mipmap\/ic_launcher"/g' app/src/main/AndroidManifest.xml

# ۴. ایجاد فایل بیلد GitHub Actions (تک خروجی)
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
        run: mv \${{ steps.sign_app.outputs.signedReleaseFile }} app/build/outputs/apk/release/MISTAKE619-Pro.apk
      - name: Upload to GitHub Releases
        uses: softprops/action-gh-release@v1
        with:
          tag_name: build-\${{ github.run_number }}
          name: Release \${{ github.run_number }}
          files: app/build/outputs/apk/release/MISTAKE619-Pro.apk
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
EOF

# ۵. به‌روزرسانی README
cat <<EOF > README.md
# 📱 MISTAKE619 WebWrapper Pro
اپلیکیشن هوشمند تولید پرامپت با قابلیت آپدیت آنی از طریق Cloudflare Worker.

## ✨ قابلیت‌های سیستمی
- **Full JS Support:** پشتیبانی کامل از دکمه کپی و انیمیشن‌ها.
- **Smart Navigation:** دکمه بازگشت هوشمند داخل اپلیکیشن.
- **Auto-Build:** خروجی مستقیم APK امضا شده [\`MISTAKE619-Pro.apk\`].

## 📥 دانلود
👉 [دریافت آخرین نسخه](https://github.com/Endjustice/Endjustice.github.io/releases)

---
بروزرسانی شده در: $(date +'%Y/%m/%d - %H:%M')
EOF

# ۶. ارسال نهایی
git add .
git commit -m "Final Optimization: Modern WebView & Clean Output"
git push origin main --force
echo "✨ تمام! نسخه جدید در حال بیلد در گیت‌هاب است."

