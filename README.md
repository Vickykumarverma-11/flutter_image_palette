🎨 flutter_image_palette

A Flutter app that fetches random photos from the internet and generates a beautiful, animated gradient background using the image’s dominant color.
Smooth transitions. Cached images. BLoC architecture. Built for performance.

📹 Demo Video

 

https://github.com/user-attachments/assets/6eb95a1d-3b71-441e-9c27-64e7c9ffb971



✨ Features

🔥 Fetch random high-resolution images

🎨 Automatically extract dominant colors

🌈 Beautiful animated gradient background transitions

🖼 Smooth image fade-in animations

⚡ Blazing-fast network caching

📱 Fully responsive layout

🧱 Clean architecture (BLoC + Domain Layer + DI)

🚀 Tech Stack
Layer	Technology
UI	Flutter, Material 3
State Management	BLoC (flutter_bloc)
Networking	Dio
Image Cache	Cached Network Image
Animations	AnimatedOpacity, Custom Gradient Background
Dependency Injection	Injectable / GetIt
 
 

🏗 Installation
1️⃣ Clone the repository
git clone https://github.com/Vickykumarverma-11/flutter_image_palette.git
cd flutter_image_palette

2️⃣ Install dependencies
flutter pub get

3️⃣ Run the app
flutter run

🧪 Running Tests

(Add tests later if needed)

flutter test

📝 Usage

Tap the Another button to fetch a new random image

The app extracts its dominant color

A smooth gradient animation updates the background


🔧 Configuration

You can change the image source (e.g., Unsplash API) inside your GetRandomImage use case.

🐞 Troubleshooting
❌ New image not loading?

You may be offline or Unsplash blocked the request.
The app will automatically show the previous image + a warning toast.

❌ DioException?

Check your internet connection.

👨‍💻 Author

Vicky Kumar Verma
📧 vermavickykumar25@gmail.com

⭐ Support

If you like this project, please ⭐ the repo.
Your support motivates more open-source work!
