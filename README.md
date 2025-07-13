# Pharma GPS

A new Flutter project made for our term ending evaluation on mobile developpement.

**Pharma GPS** is a Flutter mobile application designed to help users locate nearby pharmacies quickly and efficiently using GPS and mapping tools.

> ⚠️ **Project in early development**: This version relies heavily on `setState` for state updates and includes some business logic embedded within the UI. Although the usage of provider is present it is necessary to improve the separation of concerns and integration with state management for future versions.
> For the backend :
git clone https://github.com/Ben20222021/projet_flutter_backend.git
cd projet_flutter_backend/localisation

---

## 🧭 Features

- Locate nearby pharmacies based on the user's GPS location
- Interactive map view (MapTiler / OpenStreetMap-based)
- Basic UI for listing pharmacies
- Simple routing between pages

---

## 📦 Tech Stack

- **Flutter** (Dart)
- **MapTiler / OpenStreetMap** (for mapping)
- **Geolocator**  (for GPS access)

---

## 📌 Current Limitations

- Uses provider for state management but a great deal off the app uses setState functions(most widgets are statefull)
- Some logic is embedded in widgets — to be refactored
- UI and architecture not final — subject to change
- needs for a better roles managements when it comes to admins

---

## 🔧 Setup

1. **Clone the repo**
```bash
git clone https://github.com/Ben20222021/pharmagps.git
cd pharmagps
