# Collaborators
Student name: RuntianZhou【周润恬】 GitHub Usernames: buptzrt  QMID: 231220013  
Student name: SirongQi【祁思榕】 GitHub Usernames: penguin-qsr  QMID: 231221157  
Student name: ChenyuZhang【章晨瑜】 GitHub Usernames: Charity-zcy  QMID: 231222062  
Student name: JiayiWang【王佳仪】 GitHub Usernames: lucy-wjy  QMID: 231220459  
Student name: QiutongChen【陈秋彤】 GitHub Usernames: ChenQiutong-123   QMID: 231222545   
Student name: ZichunAo【敖子淳】 GitHub Usernames: aaazcshuaige0905  QMID: 231222844  
Yuxuan:yuxuanwwang@outlook.com    (Support TA)



## ⚙️ 运行环境与配置指南
本项目采用纯净的 Jakarta EE 规范开发。为了在本地环境中顺利运行，请按照以下步骤进行配置：
### 🛠️ 环境依赖
- **JDK 版本**：最好使用Java 21版本，否则可能会产生冲突 (请务必确保 IDEA 中的 `Project Structure` 和 `Java Compiler` 的语法级别均设置为 21)。
- **构建工具**：Maven (用于自动下载相关依赖包，如 Gson、Jakarta Servlet API 等)。
- **Web 服务器**：Tomcat 10.x 及以上版本。
### ⚠️ 核心配置：修改 JSON 数据源路径
本项目采用轻量级的 JSON 文件作为本地数据库模拟。拉取代码后，**必须将后端 Dao 层中写死的绝对路径修改为你自己电脑上的真实路径**。
找到src/main/java/com/me/finaldesignproject/dao目录，依次打开 `JobDao.java`、`UserDao.java` 等4个所有负责数据持久化的 Dao 文件。
找到文件顶部的 `FILE_PATH` 常量，将其修改为你本地电脑中相关json文件的绝对路径；或者替换掉FILE_NAME/USER_JSON_FILE前面resources文件夹的绝对路径。具体操作根据dao文件情况而定。
* **修改示例**：
  ```java
  // 请将下方路径替换为你自己电脑上的实际路径，注意目录分隔符请使用正斜杠 "/"
  private static final String FILE_PATH = "D:/Your/Project/Path/data/jobs.json";
  ```
  或者替换掉FILE_NAME/USER_JSON_FILE前面的resources的路径
  ```java
  private static Path resolvePath() {
      // 使用resources目录作为存储位置
      return Paths.get("D:/Desktop/Study/three down/software_eng/Group15_TA_SYSTEM/TA_System/src/main/resources/" + FILE_NAME);
  }
  ```
### 🚀 部署与运行步骤
1. **刷新依赖**：打开 IDEA 右侧侧边栏的 `Maven` 面板，点击 `Reload All Maven Projects` 按钮，等待底层依赖下载完成。
2. **配置 Tomcat**：
- 点击 IDEA 顶部菜单栏的 `Run` -> `Edit Configurations...`。
- 点击左上角 `+` 号，选择 `Tomcat Server` -> `Local`。
- 切换到 `Deployment` 选项卡，点击 `+` 号选择 `Artifact`，添加本项目的 `wGroup15_TA_SYSTEM:war exploded` 部署包。
- *(可选)* 建议将 `Application context` 设置为 `/`，以简化访问路径。
3. **编译并启动**：
- 点击顶部菜单栏 `Build` -> `Rebuild Project` 确保全局编译无误。
- 点击绿色的 `▶️ Run` 或 `🐛 Debug` 按钮启动 Tomcat 服务器。一般直接跳转到login界面。
- 启动完成后，在浏览器访问 `http://localhost:8080/你的上下文路径/login.jsp` 即可进入系统。



## 🚀 中期检查当前项目进度与已实现功能
系统主要分为三种核心角色，目前各角色已打通的业务功能如下：
### 👨‍🏫 MO (Module Organizer / 模块负责人)
- **账号基础**：支持【注册】与【登录】。
- **岗位管理**：可【创建 / 编辑 / 关闭 / 重新开放】属于自己的新岗位需求，岗位信息会即时同步至【岗位大厅】供全员查看。
- **审批流程**：
  - 可接收来自 STU 的应聘申请。
  - 可查看应聘者的基本信息和简历详情。
  - 可对申请进行审批操作（【通过】或【拒绝】）。

### 🎓 TA/STU (Student / 助教申请者)
- **账号基础**：支持【注册】与【登录】。
- **简历管理**：可【创建】和【修改】个人的在线电子简历。
- **求职应聘**：
  - 能够在【岗位大厅】进行职位的【查找】和【筛选】。
  - 可一键向对应的 MO 发送岗位投递申请。
- **状态追踪**：可即时查看 MO 对自己简历的处理情况（状态涵盖：`已通过`、`已被拒绝`、`待处理`）。

### 🛡️ AD (Admin / 系统管理员)
- **账号基础**：支持【注册】与【登录】。
- **全局管控**：
  - 可【创建新岗位需求】并在【岗位大厅】同步展示。
  - 拥有最高管理权限，可强制【关闭 / 重开 / 删除】任何异常岗位，操作结果与 TA/MO 视图实时同步。
- **数据监控**：可即时查看全站所有岗位的状态概览（状态涵盖：`进行中`、`已截止`、`招聘完成`）。
---



## 🔑 系统测试账号
为方便功能体验与测试，系统已预置了以下角色的测试账号。
> 💡 **操作提示**：登录时，账号输入框支持使用 **`EnrollmentNo (ID)`** 或 **`Email (邮箱)`** 任意一种方式进行登录。

| 角色类型 | EnrollmentNo (ID) | Email (邮箱) | Password (密码) |
| :--- | :--- | :--- | :--- |
| **STU (学生)** | `S001` | `test@bupt.edu.cn` | `123` |
| **MO (教师 1)** | `555` | `555@qq.com` | `555` |
| **MO (教师 2)** | `MO007` | `77777@qq.com` | `77777` |
| **AD (管理员)** | `AD002` | `dao@bupt.edu.cn` | `999` |
---




# International-School-Teaching-Assistant-Recruitment-System

Team will develop a software application that will be used by BUPT International School for recruiting Teaching Assistants. Agile methods should be applied throughout all stages of development, including requirements, analysis and design, implementation, and testing. And demonstrate incremental delivery, feedback, and reflective improvement.

---

## Project Specification

### Basic Requirements
BUPT International School recruits Teaching Assistants (TA) each semester to support academic modules and various school activities. Currently, the application process relies on forms and Excel files. A software application is needed to streamline the workflow. You will act as an Agile software development team to develop a simple recruitment system.

The system should address the specific needs of BUPT International School to recruit TAs for Module Organisers (MO) and other activities (such as invigilation). While part of the task requires you to analyse the recruitment process and identify requirements using suitable techniques, here are some suggested functions to assist you in getting started. Suggested features can include the following, but not limited to:

- TA can create an applicant profile
- TA can upload CV
- TA can find available jobs
- TA can apply for jobs
- TA can check application status
- MO can post jobs
- MO can select applicants for jobs
- Admin can check TA’s overall workload

Some AI-powered features could include:
- Matching skills between jobs and applicants
- Identifying missing skills for applicants
- Balancing workload

A complete prototype of the application must be produced. While it is not required to implement fully functional code for every feature represented in the prototype, the team must implement a selected set of CORE functions. These core features should demonstrate the system’s primary value.

### Other Requirements (mandatory)
- The software must be developed as either
  a) A stand-alone Java application, OR
  b) A lightweight Java Servlet/JSP Web-based application.
- All input and output data should be stored in simple text file formats. For example plain text (.txt), CSV, JSON, or XML. Do not use a database.

> Adhering to the above restrictions is essential to ensure:
> 1. Focus remains on fundamental Software Engineering principles, rather than on the complexities of frameworks or languages. Introducing advanced tools, such as Spring Boot or database integration, could divert attention toward framework-specific features and configuration, which are not the primary learning objectives of this module.
> 2. The system remains compatible with existing data and interoperable with legacy systems.
> 3. Fairness across all students with the necessary prerequisite knowledge and skills.

Tasks include defining detailed requirements, designing, developing, and testing the software described above using Agile methodologies. You have the freedom to design the system as you see fit, provided it meets the core customer needs and the project scope is clearly defined.

---

## Key points
- Scope: specific application for international school, not a general job application, so must get the requirements right.
- First assessment online submission only
- Intermediate and final assessment need to do in person
- Only complete basic functions then consider advanced ones, not expecting a professional application, the simple the better
- 2.2 requirement must meet, can be stand alone or Java Servlet/JSP web-based, no database
- GitHub checking throughout the timeline
- Marks is group mark * individual factor
Update README
