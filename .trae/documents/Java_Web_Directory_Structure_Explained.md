# Java Web 应用目录结构解析：webapp 与 WEB-INF

在 Java Web 开发中，理解目录结构对于构建安全、规范的应用程序至关重要。本文档解释了 `webapp` 根目录与 `WEB-INF` 目录的区别及其各自的作用。

## 1. `webapp` (或 `WebContent`)：公开区域

* **定义**：这是 Web 应用程序的根目录，也是部署到服务器时的上下文根（Context Root）。

* **访问权限**：**公开**。放置在此目录下的任何文件，用户都可以通过浏览器直接请求 URL 来访问。

* **适用内容**：

  * **静态资源**：CSS 样式表、JavaScript 脚本文件、图片（Images）、字体文件等。

  * **公共页面**：不需要权限控制的入口页面，如 `index.jsp`、`login.jsp`、`error.jsp`。

* **示例**：

  * 文件路径：`src/main/webapp/css/style.css`

  * 访问方式：浏览器输入 `http://localhost:8080/your-app/css/style.css` -> **可以直接访问**。

## 2. `WEB-INF`：私有禁区

* **定义**：这是 Java Servlet 规范中定义的一个**受保护的特殊目录**，位于 `webapp` 目录下。

* **访问权限**：**私有**。浏览器**无法直接访问**此目录下的任何资源。如果用户尝试直接请求 `http://localhost:8080/your-app/WEB-INF/somefile.jsp`，服务器会返回 404 或 403 错误。

* **访问方式**：只有服务器端的代码（如 Servlet、Filter、Controller）可以通过 `RequestDispatcher.forward()` 方法将请求转发到此目录下的资源。

* **核心作用**：

  1. **安全性（Security）**：

     * 防止用户绕过控制器（Controller/Servlet）直接访问视图页面（JSP）。

     * 例如，`profile.jsp` 如果放在 `webapp` 下，用户可能在未登录的情况下直接访问。放在 `WEB-INF` 下，用户必须先经过 `LoginServlet` 的身份验证，验证通过后由 Servlet 转发显示页面。
  2. **配置中心（Configuration）**：

     * `web.xml`（部署描述符）必须存放在此目录下，用于配置 Servlet、Filter、Listener 等。
  3. **类库与代码（Code & Libraries）**：

     * `lib/`：存放项目依赖的 `.jar` 包（如 JDBC 驱动、JSTL 库）。

     * `classes/`：存放编译后的 `.class` 文件（Java 源代码编译后的结果）和资源文件（如 `.properties`、`.xml` 配置）。

## 3. 总结对比

| 特性        | `webapp` 根目录                          | `WEB-INF` 目录                             |
| :-------- | :------------------------------------ | :--------------------------------------- |
| **可见性**   | 公开 (Public)                           | 私有 (Private)                             |
| **浏览器访问** | 允许直接访问                                | **禁止直接访问**                               |
| **访问方式**  | URL 请求                                | 服务器内部转发 (Forward)                        |
| **典型内容**  | index.jsp, login.jsp, css/, js/, img/ | web.xml, lib/, classes/, views/(受保护的JSP) |
| **主要目的**  | 提供静态资源和公共入口                           | 保护核心代码、配置和需授权访问的页面                       |

## 4. 项目中的应用实例

在本项目 (PrimeGo) 中：

* **`src/main/webapp/index.jsp`**：放在根目录下，因为这是商城的首页，允许任何人（包括未登录的游客）访问。

* **`src/main/webapp/WEB-INF/views/profile/admin_profile.jsp`**：放在 `WEB-INF` 下，因为这是管理员的个人资料页，包含敏感信息。必须通过 `AdminDashboardServlet` 验证用户是否为管理员，验证通过后才转发显示，从而确保了安全性。

