# PrimeGo 用户模块开发计划 (UI 更新版)

根据您的设计要求和现有的 `index.jsp` 代码，我更新了开发计划。我们将先实现后端逻辑，然后按照您指定的“色块保留逻辑”创建前端页面。

## 第一阶段：后端实现 (Java)

**目标**: 建立数据库连接和数据模型。

1. **数据库连接 (`com.primego.common.util.DBUtil`)**:

   * 实现 JDBC 连接工具类，连接到 `daombledore.fun`，使用您的账号密码。

2. **数据模型 (`com.primego.user.model`)**:

   * 创建 `User`, `Role` (枚举), `CustomerProfile`, `MerchantProfile`, `AdminProfile` 实体类。

3. **数据访问层 (`com.primego.user.dao`)**:

   * 实现 `UserDAO` (处理登录验证) 和 `ProfileDAO` (获取个人资料)。

4. **控制层 (`com.primego.user.servlet`)**:

   * `LoginServlet`: 处理登录请求，根据角色重定向。

   * `LogoutServlet`: 处理注销。

   * `ProfileServlet`: 获取资料并转发到对应的 JSP 页面。

## 第二阶段：前端实现 (JSP & UI 设计)

**目标**: 创建继承 `index.jsp` 设计风格的个人资料页，并应用角色专属背景色逻辑。

1. **登录页面 (`login.jsp`)**:

   * 创建一个统一的登录页面，保持整体设计风格，严格挪用index的背景设计，不做任何更改。

2. **个人资料页面 (`WEB-INF/views/profile/`)**:

   * **核心逻辑**: 复制 `index.jsp` 的 CSS 和结构。修改 `.background-blob` 的颜色：

     * **`admin_profile.jsp`** **(管理员)**:

       * 保留 `.blob-red` (红色)。

       * 将 `.blob-yellow` 和 `.blob-orange` 改为 **白色**。

     * **`customer_profile.jsp`** **(顾客)**:

       * 保留 `.blob-orange` (橙色)。

       * 将 `.blob-red` 和 `.blob-yellow` 改为 **白色**。

     * **`merchant_profile.jsp`** **(商家)**:

       * 保留 `.blob-yellow` (黄色)。

       * 将 `.blob-red` 和 `.blob-orange` 改为 **白色**。

   * **内容**: 在 `.glass-panel` 容器中显示具体的个人资料信息（如商家的店铺名、管理员的部门等）。

3. **管理员仪表盘 (`WEB-INF/views/admin/dashboard.jsp`)**:

   * 应用 **管理员 (红色)** 背景主题。

## 第三阶段：集成与测试

1. **更新** **`index.jsp`**:

   * 确保导航栏链接 (Login/Profile/Logout) 能正确指向新的 Servlet。

***

**下一步**: 确认计划后，我将从 **DBUtil** 和 **Model** 类开始编写代码，打好后端基础。
