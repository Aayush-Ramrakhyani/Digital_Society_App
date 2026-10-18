# Griha — Housing Society Management App

> Simplifying society management for committees and residents.

Griha is a full-stack app built for housing societies to manage residents, complaints, notices, and maintenance fees — all from a single platform. It supports two roles with separate, purpose-built experiences: **Committee** and **Member**.

Built for TOPS Technologys as part of a internship contract (May 2024).



---

## Real-World Impact

This app was not just built — it was deployed and actively used across Ahmedabad.

| | |
|--|--|
| 🏘️ Societies onboarded | **~15 housing societies** |
| 🏠 Households using the app | **500+** |
| 📍 Region | Ahmedabad, Gujarat, India |

Deployment involved visiting societies in person, demonstrating the app to committee members, onboarding residents, and setting up the backend for each property.

---

## Features

### Member View
| Screen | What it does |
|--------|--------------|
| **Notices** | View announcements posted by the committee |
| **Complaints** | File a complaint, track its status, and read committee feedback |
| **Profile** | View house number, family name, and family member details |

### Committee View
| Screen | What it does |
|--------|--------------|
| **Dashboard** | Overview stats — total members, pending complaints, pending fees |
| **Members** | Browse all residents and their family details |
| **Complaints** | Update complaint status, add action taken and feedback |
| **Notices** | Post and manage society-wide announcements |
| **Fees** | Track maintenance payments, mark dues as paid |

### Role-Based Login
Three committee roles — **Chairman**, **Secretary**, **Treasurer** — each gets the full committee panel. Residents log in as **Member** with a simpler, resident-focused view.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile App | Flutter · Dart · Material 3 |
| Backend | Python · FastAPI · Uvicorn |
| Database | SQLite |
| Fonts | Google Fonts |
| Networking | `http` package |

---

## Getting Started

**Backend**

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Flutter App**

```bash
flutter pub get
flutter run
```

> Update the base URL in `lib/api_service.dart` to match your backend IP address.

---

## 📄 License

This project was built as part of an internship at **TOPS Technology**. All rights reserved.
