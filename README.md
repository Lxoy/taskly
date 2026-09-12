# 📋 Taskly

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square)
![ASP.NET Core](https://img.shields.io/badge/ASP.NET%20Core-10.0-purple?style=flat-square)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue?style=flat-square)
![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Messaging-orange?style=flat-square)

A mobile application for managing personal tasks and expenses. <br>
Built with **Flutter** and **ASP.NET Core**, using **PostgreSQL** as the database.

---

## ✨ Features

📋 **Tasks**

* Create, edit, and delete tasks
* Task priorities and statuses
* Task categories
* Recurring tasks
* Manage individual occurrences of recurring tasks

💰 **Expenses**

* Add expenses to tasks
* Track personal spending
* Expense statistics

📅 **Planning**

* Calendar overview
* Upcoming tasks
* Recurring task support
* Push notifications and reminders

👤 **Authentication**

* User registration and login
* JWT authentication
* Secure token storage

---

## 🏗️ Architecture

The project consists of a Flutter mobile application and an ASP.NET Core REST API:

* **Taskly Frontend** – Flutter mobile application
* **Taskly API** – ASP.NET Core Web API
* **Taskly Services** – business logic and application services
* **Taskly Data** – Entity Framework Core, entities and database configuration

---

## 🗄️ Database

Uses **PostgreSQL** with **Entity Framework Core** and a Code First approach.

**Main entities**

* User
* Entry
* Category
* Entry Anomaliy

**Entry types**

* Once
* Daily
* Weekly
* Monthly
* Yearly

**Priorities**

* Low
* Medium
* High

---

## 🔔 Notifications

Push notifications are implemented using **Firebase Cloud Messaging (FCM)** to remind users about upcoming tasks.

---

## 🚀 Running the Project

### Backend

1. Configure the PostgreSQL connection string in `appsettings.json`.

2. Apply migrations:

```bash
dotnet ef database update
```

3. Run the API:

```bash
dotnet run
```

### Flutter

1. Navigate to the Flutter project:

```bash
cd taskly
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure the API URL.

4. Run the application:

```bash
flutter run
```

---

## 🎓 Final Thesis

Developed as part of a final thesis at **Zagreb University of Applied Sciences (TVZ)**.

**Topic:** Mobile Application for Managing Personal Tasks and Expenses
**Author:** Lovro Bilanović
**Year:** 2026
