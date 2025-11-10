# 🏨 Hotel Search Widget

## 👨‍💻 Senior Full-Stack Developer Technical Assessment

### 🧩 Overview

Create a simplified version of a hotel search widget using **Ruby on Rails** backend and **Vue.js** frontend, integrating with the **BoomNow API**.

---

### ⚙️ Core Requirements

- Single-page application with a search widget
- Search functionality limited to:
    - City/location input
    - Number of adults selector
- API integration returning raw JSON results

**Technical Stack**
- Backend: Ruby on Rails
- Frontend: Vue.js
- API: BoomNow API

---

### 📦 Deliverables

A working application with:
- Functional search widget
- API integration
- Clean, production-ready code

**GitHub repository must include:**
- Setup instructions (`README.md`)
- Your project code

---

### 🧠 Assessment Criteria

We will evaluate:
- Code quality and organization
- API integration implementation

---

### 🚀 Suggested Implementation Steps

1. Set up a new Rails + Vue.js project
    - You may use available boilerplates
2. Implement the search widget
    - Focus on functionality over styling
3. Integrate with the BoomNow API
4. Submit your solution
    - Push to a public GitHub repository
    - Include all necessary documentation

---

### ⏱️ Time Expectation

Suggested timeframe: **~1.5 hours**  
Quality over speed is preferred.

---

### 🔐 API Authentication

Credentials are stored in: `config/credentials.yml.enc`

Keys: `boom_now.client_id`, `boom_now.client_secret`

### 📚 Reference
- Original widget: https://designedvr.bookingsboom.com/
- API Documentation: https://boomnow.stoplight.io/

### 📩 Submission
Please provide the GitHub repository URL upon completion.

---

## 🧰 Architecture
- App type: SPA
- Architecture: Monolith (planned future separation)
- Backend: Rails API with Vite Ruby integration
- Frontend: Vue components with Bootstrap styling

## Stack

- Ruby: 3.4.7
- Rails: 8.1.1
- Database: PostgreSQL
- Caching: Rails.cache (memory store, default)
- Tests: none yet (RSpec planned)

### 🎨 Frontend Tools

- Vite
- Bootstrap 5
- Vue.js 3

---

## ⚙️ Setup

### 🧱 Backend

```bash
bundle install
rails db:create
rails s
```

### Setup (after backend setup):

```bash
yarn install
yarn dev
```

---

### 🗒️ TODO
- Add Bootstrap UI components
- Add Vue.js components (search widget)
- Add markup & layout
- Add AJAX integration with BoomNow API
- Add RSpec tests

### 💡 Notes
This README documents the current setup and serves as the foundation for ongoing development.