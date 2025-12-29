#!/bin/bash

echo "🔍 در حال بررسی ساختار پروژه..."

# ۱. بررسی وجود فایل‌های حیاتی
FILES=(
  "app/src/main/java/com/example/webwrapperapp/MainActivity.java"
  "app/src/main/res/values/themes.xml"
  "app/src/main/res/values/strings.xml"
  "gradle.properties"
  "gradlew"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ فایل $file یافت شد."
  else
    echo "❌ خطا: فایل $file وجود ندارد!"
    exit 1
  fi
done

# ۲. بررسی غلط املایی معروف در آیدی WebView
if grep -q "R.id.webview" app/src/main/java/com/example/webwrapperapp/MainActivity.java; then
    echo "❌ خطا: کلمه webview با w کوچک نوشته شده! آن را به webView تغییر دهید."
    exit 1
else
    echo "✅ آیدی WebView در کد جاوا صحیح است."
fi

# ۳. بررسی سلامت فایل تم
if grep -q 'parent="Theme.WebWrapper"' app/src/main/res/values/themes.xml; then
    echo "❌ خطا: تم نباید از خودش ارث‌بری کند!"
    exit 1
else
    echo "✅ ساختار Themes.xml صحیح است."
fi

echo "🚀 همه چیز آماده است! می‌توانید با خیال راحت Push کنید."

