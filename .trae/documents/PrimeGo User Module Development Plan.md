# PrimeGo User Module Development Plan

Based on your requirements, I have designed the following development plan to implement the User module, including database design, backend logic, and frontend pages.

## Phase 1: Database Design & Configuration
**Goal**: Set up the database schema and application connectivity.

1.  **Create SQL Script (`src/main/resources/db/schema.sql`)**:
    *   Define `users` table:
        *   `id` (PK, Auto Increment)
        *   `username` (Unique, Not Null)
        *   `password` (Encrypted, Not Null)
        *   `role` (Enum: 'ADMIN', 'CUSTOMER', 'MERCHANT')
        *   `status` (Default 1/Active)
        *   `created_at`, `updated_at`
    *   Define Profile tables with Foreign Keys to `users`:
        *   `customer_profiles` (`user_id`, `full_name`, `email`, `phone`, `address`)
        *   `merchant_profiles` (`user_id`, `store_name`, `business_license`, `contact_info`)
        *   `admin_profiles` (`user_id`, `department`, `level`)
    *   *Note*: I will provide the SQL commands for you to run on your database server (`daombledore.fun`).

2.  **Implement Database Connection (`com.primego.common.util.DBUtil`)**:
    *   Create a JDBC utility class to manage connections.
    *   **Config**:
        *   URL: `jdbc:mysql://daombledore.fun:3306/primego_db`
        *   User: `czkpgo` (Using Account 1 for app connection)
        *   Pass: `qwer1234`

## Phase 2: Model & DAO Layer (Backend)
**Goal**: Implement Data Access Objects and Entity classes using OOP.

3.  **Create Models (`com.primego.user.model`)**:
    *   `User.java`: Represents the `users` table.
    *   `CustomerProfile.java`, `MerchantProfile.java`, `AdminProfile.java`.
    *   `Role.java` (Enum).

4.  **Create DAOs (`com.primego.user.dao`)**:
    *   `UserDAO.java`:
        *   `User findByUsername(String username)`
        *   `boolean createUser(User user)`
        *   `boolean validateCredentials(String username, String password)`
    *   `ProfileDAO.java`: Handle profile CRUD operations.

5.  **Security Utility**:
    *   Implement `PasswordUtil` using `java.security.MessageDigest` (SHA-256) for password hashing (avoiding external frameworks).

## Phase 3: Servlet & Control Layer
**Goal**: Handle authentication logic and routing.

6.  **Implement Servlets (`com.primego.user.servlet`)**:
    *   `LoginServlet`:
        *   `doPost`: Validate user -> Store User object in Session -> Redirect based on Role.
        *   **Redirect Logic**:
            *   `CUSTOMER` / `ADMIN` -> `index.jsp`
            *   `MERCHANT` -> `merchant/profile.jsp`
    *   `LogoutServlet`: Invalidate session -> Redirect to login.
    *   `ProfileServlet`: Handle profile viewing and updating.

## Phase 4: Frontend (JSP & UI)
**Goal**: Create user-friendly interfaces with role-based navigation.

7.  **Create Pages (`src/main/webapp`)**:
    *   `login.jsp`: Unified login form.
    *   `index.jsp`: Main landing page.
        *   **Navbar Logic**: Use JSTL (`<c:if>`) to show "Admin Dashboard" link only if `sessionScope.user.role == 'ADMIN'`.
        *   Avatar link points to `ProfileServlet`.
    *   `WEB-INF/views/profile/`:
        *   `admin_profile.jsp`
        *   `customer_profile.jsp`
        *   `merchant_profile.jsp`
    *   `WEB-INF/views/admin/`:
        *   `dashboard.jsp`

## Phase 5: Integration & Testing
8.  **Verify Requirements**:
    *   Test login for all 3 roles.
    *   Verify redirection rules.
    *   Verify Navbar visibility (Admin Dashboard).
    *   Check database records.

---
**Next Step**: Once you approve this plan, I will start with **Phase 1: Creating the SQL schema and DBUtil class**.