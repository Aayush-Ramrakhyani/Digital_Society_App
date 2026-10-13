# 🏘️ Griha — Society Management App

A full-stack community management app for housing societies, built with **Flutter** (frontend) and **FastAPI + SQLite** (backend). Supports two roles — **Committee** and **Member** — each with a tailored experience.

---

## ✨ Features

### 👥 Member View
| Tab | Description |
|-----|-------------|
| **Notices** | View announcements posted by the committee |
| **Complaints** | File new complaints, track status and committee feedback |
| **Profile** | View house details and family member info |

### 🏛️ Committee View
| Tab | Description |
|-----|-------------|
| **Dashboard** | Stats: total members, pending complaints, pending maintenance |
| **Members** | Browse all residents and their family details |
| **Complaints** | Manage complaints — update status, add action and feedback |
| **Notices** | Post and manage society announcements |
| **Fees** | Track maintenance payments — mark as paid, view pending dues |

### 🔐 Role-Based Login
Three committee roles: **Chairman**, **Secretary**, **Treasurer** — each gets the full committee panel. Regular residents log in as **Member**.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Frontend | Flutter · Dart · Material 3 |
| Backend | Python · FastAPI · Uvicorn |
| Database | SQLite (local, via backend) |
| Fonts | Google Fonts |
| HTTP | `http` package |

---

## 📁 Project Structure

```
digital_society/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── models.dart                      # Data models (Member, Complaint, Notice, Maintenance)
│   ├── theme.dart                       # App theme & gradient
│   ├── splash_screen.dart               # Animated splash
│   ├── login_page.dart                  # Role-based login
│   ├── member_home.dart                 # Member shell (Notices, Complaints, Profile)
│   ├── committee_home.dart              # Committee shell (Dashboard + 4 tabs)
│   ├── notices_tab.dart                 # Member: view notices
│   ├── complaints_tab.dart              # Member: view/track complaints
│   ├── add_complaint_page.dart          # Member: file a complaint
│   ├── profile_tab.dart                 # Member: profile & family
│   ├── committee_dashboard_tab.dart     # Committee: stats dashboard
│   ├── committee_members_tab.dart       # Committee: member directory
│   ├── committee_complaints_tab.dart    # Committee: manage complaints
│   ├── committee_notices_tab.dart       # Committee: post notices
│   ├── committee_maintenance_tab.dart   # Committee: fees tracker
│   ├── add_member_page.dart             # Committee: add new resident
│   └── add_notice_page.dart             # Committee: post announcement
└── backend/
    ├── main.py                          # FastAPI app — all routes
    ├── requirements.txt                 # Python dependencies
    └── society.db                       # SQLite database (auto-created)
```

---

## 🚀 Getting Started

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Flutter App

```bash
flutter pub get
flutter run
```

> Update the base URL in `lib/api_service.dart` to point to your backend IP.

---

## 🤝 Contributing

Pull requests are welcome. For major changes please open an issue first.

---

## 🎓 Internship Project

This project was built as part of an internship at **TOPS Technology**, Ahmedabad.

| Detail | Info |
|--------|------|
| **Organization** | TOPS Technology |
| **Location** | Ahmedabad, Gujarat, India |
| **Type** | Internship Project |
| **Domain** | Full-Stack Mobile Development |

The goal was to design and develop a real-world society management solution from scratch — covering requirement gathering, UI design, backend API development, database design, and final deployment-ready build.

---

*Built with Flutter & FastAPI · Offline-capable · No third-party auth*
