<!-- Use this file to provide workspace-specific custom instructions to Copilot. -->

# DigiBoard Project Instructions

This is a full-stack DigiBoard application designed as an intelligent classroom assistant.

## 🏗️ Architecture

### Backend (Node.js + Express)
- **Entry Point:** `/backend/server.js` (Unified server)
- **Database:** MongoDB Atlas (Primary) with **Automatic Offline Fallback**.
- **Offline Mode:** If MongoDB is unreachable, the server automatically switches to serving data from `/backend/mockData.js`.
- **Port:** 5000

### Frontend (Flutter Web)
- **Location:** `/frontend`
- **Port:** 40051
- **UI Style:** Modern Dark Theme (Slate 900), Glassmorphism, 3D Carousel.
- **Key Screens:** `TimetableCarouselScreen` (V4 UI).

## ✨ Key Features (Current State)
1.  **Zero-Downtime Reliability:** Backend automatically serves mock data if the DB connection fails.
2.  **Learning Outcomes:** The "Notes" section has been renamed to "Learning Outcomes" and displays numbered lists (e.g., "1. Introduction to...").
3.  **Smart Attendance:** Visualizes attendance rates and absentee lists in real-time.
4.  **Dynamic Header:** The left header displays the current **Date and Day** (e.g., "THURSDAY, DECEMBER 18") instead of static text.
5.  **3D Carousel:** Lectures are displayed in a 3D cover-flow style carousel.

## 📂 Important Files
- `backend/server.js`: Main server logic with connection retry and fallback handling.
- `backend/mockData.js`: Static data used during offline mode.
- `frontend/lib/screens/timetable_carousel_screen.dart`: Main dashboard UI.
- `pitch_deck.html`: Interactive HTML presentation of the project.
- `DIGIBOARD_PITCH_DECK.md`: Pitch deck content.
- `PITCH_SPEAKER_NOTES.md`: Script for presenting the project.

## 🚀 Development Guidelines
- **Running Backend:** `cd backend && npm run dev` (Starts on port 5000)
- **Running Frontend:** `cd frontend && flutter run -d web-server --web-port 40051`
- **UI Changes:** When editing the dashboard, ensure you are modifying `TimetableCarouselScreen` in `timetable_carousel_screen.dart`.
- **Pitching:** Use `pitch_deck.html` for demonstrations.

## 🔗 API Endpoints
- `GET /api/schedule/today` - Returns today's lectures (from DB or Mock Data).
- `GET /api/schedule/next` - Returns the next upcoming lecture.
- `GET /api/health` - Returns server status and DB connection state.
