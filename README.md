# Little Achievers Academy

A Flutter-based educational app aimed at helping students (Class 5-10) with their learning journey through quizzes and study materials.

## Current Features

- **User Authentication**: Google Sign-In and Guest login
- **Student Registration**: Profile creation with school, class, and guardian details
- **Profile Management**: View and edit profile, upload profile picture
- **AI Quiz System**: Generate quizzes using Gemini AI based on selected topic and difficulty
- **Quiz History**: Track quiz attempts and scores
- **Basic Notes Section**: Placeholder for study notes (in development)

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Python (Flask) + Gemini AI
- **Database**: Firebase Firestore
- **Storage**: Firebase Storage (for profile pictures)
- **Auth**: Firebase Authentication

## Setup

1. Clone the repository
2. Run `flutter pub get`
3. Add your `google-services.json` to `android/app/`
4. Add your Firebase service account key to `backend/serviceAccountKey.json`
5. Create `backend/.env` with your `GEMINI_API_KEY`
6. Run the backend: `python backend/main.py`
7. Run the app: `flutter run`

## What's Planned (Future)

- Complete notes section with offline support
- Tutor booking feature (UI exists, backend pending)
- Quiz history page with detailed analytics
- Push notifications for study reminders
- More quiz subjects and difficulty levels

## Status

This is a work-in-progress personal project. Many features are still incomplete or placeholder. Contributions and suggestions welcome.

## Contact

Harsh Kumar Sahni  
Email: harshkumarsahni123@gmail.com
